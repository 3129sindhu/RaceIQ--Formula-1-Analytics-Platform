

CREATE TABLE IF NOT EXISTS result_audit_log (
    log_id     SERIAL PRIMARY KEY,
    action     VARCHAR(10)  NOT NULL,   
    resultId   INT,
    driverId   INT,
    raceId     INT,
    points     NUMERIC(5,2),
    logged_at  TIMESTAMP    DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS driver_deletion_log (
    log_id      SERIAL PRIMARY KEY,
    driverId    INT,
    driver_name TEXT,
    deleted_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS transaction_error_log (
    log_id      SERIAL PRIMARY KEY,
    error_msg   TEXT,
    failed_at   TIMESTAMP DEFAULT NOW()
);



-- ============================================================
-- TRIGGER 1: Audit every INSERT or UPDATE on results
-- Writes the record to result_audit_log, ensuring a proper audit record 
         
CREATE OR REPLACE FUNCTION trg_audit_result()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO result_audit_log (action, resultId, driverId, raceId, points)
    VALUES (TG_OP, NEW.resultId, NEW.driverId, NEW.raceId, NEW.points);
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_results_audit
AFTER INSERT OR UPDATE ON results
FOR EACH ROW EXECUTE FUNCTION trg_audit_result();


-- ============================================================
-- TRIGGER 2: Validate points on insert into results
--   Validates that the points value does not exceed 26, the maximum achievable in F1

CREATE OR REPLACE FUNCTION trg_validate_points()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.points > 26 THEN
        RAISE EXCEPTION
            'Invalid points value: % — maximum allowed per result is 26.',
            NEW.points;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_results_validate_points
BEFORE INSERT ON results
FOR EACH ROW EXECUTE FUNCTION trg_validate_points();


-- ============================================================
-- TRIGGER 3: Logs every delete on drivers
-- Preserves the deleted driver's name and ID
CREATE OR REPLACE FUNCTION trg_log_driver_deletion()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO driver_deletion_log (driverId, driver_name)
    VALUES (OLD.driverId, OLD.forename || ' ' || OLD.surname);
    RETURN OLD;
END;
$$;

CREATE OR REPLACE TRIGGER trg_drivers_deletion_log
AFTER DELETE ON drivers
FOR EACH ROW EXECUTE FUNCTION trg_log_driver_deletion();


-- ============================================================
-- TRIGGER 4: Validate pit stop number 

CREATE OR REPLACE FUNCTION trg_validate_pit_stop()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.stop > 10 THEN
        RAISE EXCEPTION
            'Invalid pit stop number: % for driver % in race % — max 10 stops allowed.',
            NEW.stop, NEW.driverId, NEW.raceId;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_pit_stops_validate
BEFORE INSERT ON pit_stops
FOR EACH ROW EXECUTE FUNCTION trg_validate_pit_stop();


-- ============================================================
-- TRIGGER 5: Auto-refresh driver standings after insert

CREATE OR REPLACE FUNCTION trg_auto_update_standings()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    PERFORM update_driver_standings(NEW.raceId, NEW.driverId);
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_results_auto_standings
AFTER INSERT ON results
FOR EACH ROW EXECUTE FUNCTION trg_auto_update_standings();


-- ============================================================
-- TRIGGER 6: Prevent negative points after update to results

CREATE OR REPLACE FUNCTION trg_prevent_negative_points()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.points < 0 THEN
        RAISE EXCEPTION
            'Points cannot be negative: attempted to set points = % for resultId %.',
            NEW.points, NEW.resultId;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_results_no_negative_points
BEFORE UPDATE ON results
FOR EACH ROW EXECUTE FUNCTION trg_prevent_negative_points();


-- ====================
-- PART 2: Transaction failure demonstration


DO $$
BEGIN

    INSERT INTO results (raceId, driverId, constructorId,
                         grid, positionOrder, points, laps, statusId)
    VALUES (1, 1, 1, 1, 1, 25.00, 58, 1);

    RAISE NOTICE 'Step 1 succeeded — result inserted, audit logged, standings updated.';

    
    INSERT INTO results (raceId, driverId, constructorId,
                         grid, positionOrder, points, laps, statusId)
    VALUES (2, 2, 1, 2, 2, 100.00, 58, 1);

    RAISE NOTICE 'Step 2 succeeded.';

EXCEPTION
    WHEN OTHERS THEN
        
        INSERT INTO transaction_error_log (error_msg)
        VALUES ('Transaction aborted: ' || SQLERRM);

        RAISE NOTICE 'Transaction failed and rolled back. Error: %', SQLERRM;
END;
$$;


SELECT COUNT(*) AS audit_rows_after_abort FROM result_audit_log;

SELECT * FROM transaction_error_log;

