

-- ============================================================
-- 1. add_race_result()
--    Inserts a new row into results and returns the new resultId
-- ============================================================
CREATE OR REPLACE FUNCTION add_race_result(
    p_raceId      INT,
    p_driverId    INT,
    p_constructorId INT,
    p_grid       INT,
    p_positionOrder INT,
    p_points     NUMERIC(5,2),
    p_laps      INT,
    p_statusId INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_resultId INT;
BEGIN
    INSERT INTO results (
        raceId, driverId, constructorId,
        grid, positionOrder, points, laps, statusId
    )
    VALUES (
        p_raceId, p_driverId, p_constructorId,
        p_grid, p_positionOrder, p_points, p_laps, p_statusId
    )
    RETURNING resultId INTO v_resultId;

    RETURN v_resultId;
END;
$$;


-- ============================================================
-- 2. update_driver_standings()
--    Recomputes cumulative points + wins

CREATE OR REPLACE FUNCTION update_driver_standings(
    p_raceId   INT,
    p_driverId INT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_year          INT;
    v_cumPoints     NUMERIC(6,2);
    v_wins          INT;
BEGIN
    SELECT ra.year INTO v_year
    FROM races ra
    WHERE ra.raceId = p_raceId;

    SELECT
        COALESCE(SUM(r.points), 0),
        COALESCE(SUM(CASE WHEN r.position = 1 THEN 1 ELSE 0 END), 0)
    INTO v_cumPoints, v_wins
    FROM results r
    JOIN races   ra ON r.raceId = ra.raceId
    WHERE r.driverId = p_driverId
      AND ra.year    = v_year
      AND ra.raceId <= p_raceId;

    INSERT INTO driver_standings (raceId, driverId, points, wins, is_disqualified)
    VALUES (p_raceId, p_driverId, v_cumPoints, v_wins, FALSE)
    ON CONFLICT (raceId, driverId)
    DO UPDATE SET
        points = EXCLUDED.points,
        wins   = EXCLUDED.wins;
END;
$$;


-- ============================================================
-- 3. delete_driver()
--    Does not  delete a driver who has race results.

CREATE OR REPLACE FUNCTION delete_driver(p_driverId INT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_race_count INT;
    v_name       TEXT;
BEGIN
    SELECT forename || ' ' || surname INTO v_name
    FROM drivers
    WHERE driverId = p_driverId;

    IF v_name IS NULL THEN
        RAISE EXCEPTION 'Driver with id % does not exist.', p_driverId;
    END IF;

    SELECT COUNT(*) INTO v_race_count
    FROM results
    WHERE driverId = p_driverId;

    IF v_race_count > 0 THEN
        RAISE EXCEPTION
            'Cannot delete driver "%" (id=%) — they have % race result(s) on record.',
            v_name, p_driverId, v_race_count;
    END IF;

    DELETE FROM drivers WHERE driverId = p_driverId;

    RETURN 'Deleted driver: ' || v_name;
END;
$$;


-- ============================================================
-- 4. get_driver_career_stats()
--    Returns a single-row summary of a driver's F1 career.
-- ============================================================
CREATE OR REPLACE FUNCTION get_driver_career_stats(p_driverId INT)
RETURNS TABLE (
    driver_name     TEXT,
    nationality     VARCHAR(50),
    total_races     BIGINT,
    total_points    NUMERIC,
    total_wins      BIGINT,
    total_podiums   BIGINT,
    best_finish     INT,
    first_season    INT,
    last_season     INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.forename || ' ' || d.surname,
        d.nationality,
        COUNT(r.resultId),
        SUM(r.points),
        SUM(CASE WHEN r.position = 1 THEN 1 ELSE 0 END),
        SUM(CASE WHEN r.position <= 3 THEN 1 ELSE 0 END),
        MIN(r.positionOrder),
        MIN(ra.year),
        MAX(ra.year)
    FROM drivers d
    JOIN results r  ON d.driverId = r.driverId
    JOIN races   ra ON r.raceId   = ra.raceId
    WHERE d.driverId = p_driverId
    GROUP BY d.driverId, d.forename, d.surname, d.nationality;
END;
$$;


-- ============================================================
-- 5. get_constructor_season_summary()
--    Returns race-by-race points and standing position for a
--    constructor in a given season.

CREATE OR REPLACE FUNCTION get_constructor_season_summary(
    p_constructorId INT,
    p_year          INT
)
RETURNS TABLE (
    round           INT,
    race_name       VARCHAR(100),
    race_date       DATE,
    points_scored   NUMERIC,
    standing_pos    INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ra.round,
        ra.name,
        ra.date,
        COALESCE(SUM(cr.points), 0),
        cs.position
    FROM races ra
    LEFT JOIN constructor_results  cr ON ra.raceId        = cr.raceId
                                     AND cr.constructorId = p_constructorId
    LEFT JOIN constructor_standings cs ON ra.raceId        = cs.raceId
                                      AND cs.constructorId = p_constructorId
    WHERE ra.year = p_year
    GROUP BY ra.round, ra.name, ra.date, cs.position
    ORDER BY ra.round;
END;
$$;


