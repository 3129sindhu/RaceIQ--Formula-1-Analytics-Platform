
-- ============================================================
-- Query-11
-- ============================================================
EXPLAIN ANALYZE
SELECT
    ra.year,
    co.name       AS constructor_name,
    COUNT(ps.milliseconds)         AS total_stops,
    ROUND(AVG(ps.milliseconds) / 1000.0, 3)     AS avg_stop_sec,
    ROUND(MIN(ps.milliseconds) / 1000.0, 3)     AS fastest_stop_sec
FROM pit_stops  ps
JOIN races    ra ON ps.raceId     = ra.raceId
JOIN results   re ON ps.raceId  = re.raceId
AND ps.driverId   = re.driverId
JOIN constructors co ON re.constructorId = co.constructorId
WHERE ps.milliseconds BETWEEN 1500 AND 60000
GROUP BY ra.year, co.constructorId, co.name
ORDER BY ra.year DESC, avg_stop_sec ASC
LIMIT 30;


-- ============================================================
-- Optimize 1: Index on results(raceId, driverId)
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_results_raceid_driverid
ON results (raceId, driverId);


-- ============================================================
-- Optimze 2: Composite index on pit_stops(raceId, driverId, milliseconds)
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_pit_stops_raceid_driverid_ms
ON pit_stops (raceId, driverId, milliseconds);



-- ============================================================
-- Query-11
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_pit_stops_raceid_driverid_ms
ON pit_stops (raceId, driverId, milliseconds);

EXPLAIN ANALYZE
SELECT
    r.year,
    r.name      AS race_name,
    ds.points    AS cumulative_points,
    ds.position     AS championship_position,
    ds.wins
FROM driver_standings ds
JOIN races r ON ds.raceId = r.raceId
WHERE ds.driverId = 1
ORDER BY r.year, r.round;
Index:

-- ============================================================
-- Optimze 1
-- ============================================================

CREATE INDEX idx_driver_standings_driverid ON driver_standings(driverId);

-- ============================================================
-- Query-9
-- ============================================================

EXPLAIN ANALYZE
SELECT
    ra.year,
    d.forename || ' ' || d.surname     AS driver_name,
    ROUND(AVG(q.position::NUMERIC - r.positionOrder), 2) AS avg_positions_gained,
    COUNT(*)  AS races_with_data
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
-- Optimze 
-- ============================================================


CREATE INDEX IF NOT EXISTS idx_results_raceid_driverid
    ON results(raceId, driverId);