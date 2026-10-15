


-- ====================
-- 1. add_race_result()
--    Add a new result for driver 1 (Hamilton) in race 1

SELECT add_race_result(1, 1, 1, 1, 1, 25.00, 58, 1) AS new_result_id;


-- =============================
-- 2. update_driver_standings()
--    Recalculate standings for driver 1 after race 1

SELECT update_driver_standings(1, 1);


-- ============================
-- 3. delete_driver()
--    Trying to  delete Hamilton because he has race results on record

SELECT delete_driver(1);


-- ==============================
-- 4. get_driver_career_stats()
--    Full career summary for driverId=30

SELECT * FROM get_driver_career_stats(30);


-- ============================================================
-- 5. get_constructor_season_summary()
--    Race by race breakdown constructorId=13
SELECT * FROM get_constructor_season_summary(131, 2021);
