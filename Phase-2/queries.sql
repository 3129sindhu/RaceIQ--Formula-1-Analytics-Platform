

-- ===================================
-- 1: INSERT — Add a new fictional test driver

INSERT INTO drivers (driverRef, number, code, forename, surname, dob, nationality, url)
VALUES ('test_driver', 99, 'TST', 'Test', 'Driver', '2000-01-15', 'British',
        'http://en.wikipedia.org/wiki/Test_Driver');


-- ================================
-- 2: INSERT — Add a race result for the test driver
--     Uses subquery to look up the new driverId dynamically
INSERT INTO results (raceId, driverId, constructorId, number, grid,
                     position, positionText, positionOrder, points,
                     laps, statusId)
VALUES (
    1,
    (SELECT driverId FROM drivers WHERE driverRef = 'test_driver'),
    1,99, 20, 20, '20', 20,0.00, 50,
    (SELECT statusId FROM status WHERE status = 'Finished')
);


-- ============================================================
-- 3: DELETE — Remove the test driver
--     ON DELETE CASCADE automatically removes their result too
-- ============================================================
DELETE FROM drivers
WHERE driverRef = 'test_driver';


-- ============================================================
-- 4: DELETE — Remove pit stop records that are bad sensor data
-- ============================================================
DELETE FROM pit_stops
WHERE milliseconds > 120000;


-- ============================================================
-- Q5: update  — Assign  numbers to drivers who have
--     raced but never had a number recorded
UPDATE drivers
SET    number = driverId + 800
WHERE  number IS NULL
  AND  driverId IN (SELECT DISTINCT driverId FROM results);


-- ============================================================
-- Q6: Update - Assign  zero out points for any
--     result where the driver was flagged Disqualified
UPDATE results
SET    points = 0.00
WHERE  statusId = (SELECT statusId FROM status WHERE status = 'Disqualified')
  AND  points > 0;


-- ============================================================
-- Q7: Select — All-time driver career stats
SELECT
    d.forename || ' ' || d.surname          AS driver_name,
    d.nationality,
    COUNT(r.resultId)                        AS races_entered,
    SUM(r.points)                            AS total_points,
    SUM(CASE WHEN r.position = 1 THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN r.position <= 3 THEN 1 ELSE 0 END) AS podiums,
    ROUND(AVG(r.points), 2)                  AS avg_points_per_race
FROM drivers d
JOIN results r ON d.driverId = r.driverId
GROUP BY d.driverId, d.forename, d.surname, d.nationality
ORDER BY total_points DESC
LIMIT 20;


-- ============================================================
-- Q8: SELECT — Constructor results

WITH decade_totals AS (
    SELECT
        (FLOOR(ra.year / 10.0) * 10)::INT  AS decade,
        co.name                             AS constructor_name,
        SUM(cr.points)                      AS total_points
    FROM constructor_results cr
    JOIN races        ra ON cr.raceId        = ra.raceId
    JOIN constructors co ON cr.constructorId = co.constructorId
    WHERE cr.points IS NOT NULL
    GROUP BY (FLOOR(ra.year / 10.0) * 10)::INT, co.constructorId, co.name
)
SELECT
    decade,
    constructor_name,
    total_points
FROM (
    SELECT
        decade,
        constructor_name,
        total_points,
        RANK() OVER (PARTITION BY decade ORDER BY total_points DESC) AS rnk
    FROM decade_totals
) ranked
WHERE rnk = 1
ORDER BY decade;


-- ============================================================
-- Q9:  Average qualifying-to-race position gain/loss

SELECT
    ra.year,
    d.forename || ' ' || d.surname                  AS driver_name,
    ROUND(AVG(q.position::NUMERIC - r.positionOrder), 2) AS avg_positions_gained,
    COUNT(*)                                         AS races_with_data
FROM qualifying q
JOIN results r  ON q.raceId   = r.raceId   AND q.driverId = r.driverId
JOIN drivers d  ON q.driverId = d.driverId
JOIN races   ra ON q.raceId   = ra.raceId
WHERE q.position IS NOT NULL
  AND r.positionOrder IS NOT NULL
GROUP BY ra.year, d.driverId, d.forename, d.surname
HAVING COUNT(*) >= 5
ORDER BY ra.year DESC, avg_positions_gained DESC
LIMIT 30;


-- ============================================================
-- Q10: Pit stop efficiency per constructor per season

SELECT
    ra.year,
    co.name                                     AS constructor_name,
    COUNT(ps.milliseconds)                       AS total_stops,
    ROUND(AVG(ps.milliseconds) / 1000.0, 3)     AS avg_stop_sec,
    ROUND(MIN(ps.milliseconds) / 1000.0, 3)     AS fastest_stop_sec
FROM pit_stops   ps
JOIN races       ra ON ps.raceId        = ra.raceId
JOIN results     re ON ps.raceId        = re.raceId
                   AND ps.driverId      = re.driverId
JOIN constructors co ON re.constructorId = co.constructorId
WHERE ps.milliseconds BETWEEN 1500 AND 60000
GROUP BY ra.year, co.constructorId, co.name
ORDER BY ra.year DESC, avg_stop_sec ASC
LIMIT 30;


-- ============================================================
-- Q11: Running championship standings after each race
--      in the 2021 season 
-- ============================================================
WITH cumulative AS (
    SELECT
        r.driverId,
        ra.round,
        ra.name                        AS race_name,
        r.points                       AS race_points,
        SUM(r.points) OVER (
            PARTITION BY r.driverId
            ORDER BY ra.round
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                              AS cumulative_points
    FROM results r
    JOIN races ra ON r.raceId = ra.raceId
    WHERE ra.year = 2021
)
SELECT
    c.round,
    c.race_name,
    d.forename || ' ' || d.surname  AS driver_name,
    c.race_points,
    c.cumulative_points,
    RANK() OVER (
        PARTITION BY c.round
        ORDER BY c.cumulative_points DESC
    )                               AS championship_position
FROM cumulative c
JOIN drivers d ON c.driverId = d.driverId
ORDER BY c.round, championship_position;


-- ============================================================
-- Q12: SELECT 
-- ============================================================

SELECT
    r.year,
    r.name                   AS race_name,
    ds.points                AS cumulative_points,
    ds.position              AS championship_position,
    ds.wins
FROM driver_standings ds
JOIN races r ON ds.raceId = r.raceId
WHERE ds.driverId = 1
ORDER BY r.year, r.round;


