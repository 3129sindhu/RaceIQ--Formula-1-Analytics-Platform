
-- he file responsible for populating the database with all the F1 data. 
--It reads through all 14 CSV files and loads them one by one into the database in the correct order.

\copy seasons (year, url) FROM 'seasons.csv' CSV HEADER NULL '\N'

\copy circuits (circuitId, circuitRef, name, location, country, lat, lng, alt, url) FROM 'circuits.csv' CSV HEADER NULL '\N'

\copy constructors (constructorId, constructorRef, name, nationality, url) FROM 'constructors.csv' CSV HEADER NULL '\N'

\copy drivers (driverId, driverRef, number, code, forename, surname, dob, nationality, url) FROM 'drivers.csv' CSV HEADER NULL '\N'

\copy status (statusId, status) FROM 'status.csv' CSV HEADER NULL '\N'

\copy races (raceId, year, round, circuitId, name, date, time, url, fp1_date, fp1_time, fp2_date, fp2_time, fp3_date, fp3_time, quali_date, quali_time, sprint_date, sprint_time) FROM 'races.csv' CSV HEADER NULL '\N'





\copy results (resultId, raceId, driverId, constructorId, number, grid, position, positionText, positionOrder, points, laps, time, milliseconds, fastestLap, rank, fastestLapTime, fastestLapSpeed, statusId) FROM 'results.csv' CSV HEADER NULL '\N'

\copy qualifying (qualifyId, raceId, driverId, constructorId, number, position, q1, q2, q3) FROM 'qualifying.csv' CSV HEADER NULL '\N'

\copy lap_times (raceId, driverId, lap, position, time, milliseconds) FROM 'lap_times.csv' CSV HEADER NULL '\N'

\copy pit_stops (raceId, driverId, stop, lap, time, duration, milliseconds) FROM 'pit_stops.csv' CSV HEADER NULL '\N'

\copy sprint_results (resultId, raceId, driverId, constructorId, number, grid, position, positionText, positionOrder, points, laps, time, milliseconds, fastestLap, fastestLapTime, statusId) FROM 'sprint_results.csv' CSV HEADER NULL '\N'

\copy constructor_results (constructorResultsId, raceId, constructorId, points, status) FROM 'constructor_results.csv' CSV HEADER NULL '\N'


-- driver_standings 


CREATE TEMP TABLE driver_standings_staging (
    driverStandingsId INT,
    raceId            INT,
    driverId          INT,
    points            NUMERIC(6,2),
    position          INT,
    positionText      VARCHAR(5),
    wins              INT
);

\copy driver_standings_staging (driverStandingsId, raceId, driverId, points, position, positionText, wins) FROM 'driver_standings.csv' CSV HEADER NULL '\N'

INSERT INTO driver_standings (driverStandingsId, raceId, driverId, points, position, wins, is_disqualified)
SELECT driverStandingsId, raceId, driverId, points, position, wins, (positionText = 'D')
FROM driver_standings_staging;

DROP TABLE driver_standings_staging;


-- Constructor standings 


CREATE TEMP TABLE constructor_standings_staging (
    constructorStandingsId INT,
    raceId                 INT,
    constructorId          INT,
    points                 NUMERIC(6,2),
    position               INT,
    positionText           VARCHAR(5),
    wins                   INT
);

\copy constructor_standings_staging (constructorStandingsId, raceId, constructorId, points, position, positionText, wins) FROM 'constructor_standings.csv' CSV HEADER NULL '\N'

INSERT INTO constructor_standings (constructorStandingsId, raceId, constructorId, points, position, wins, is_excluded)
SELECT constructorStandingsId, raceId, constructorId, points, position, wins, (positionText = 'E')
FROM constructor_standings_staging;

DROP TABLE constructor_standings_staging;




SELECT setval('circuits_circuitid_seq',          (SELECT MAX(circuitId)               FROM circuits));
SELECT setval('constructors_constructorid_seq',   (SELECT MAX(constructorId)           FROM constructors));
SELECT setval('drivers_driverid_seq',             (SELECT MAX(driverId)                FROM drivers));
SELECT setval('status_statusid_seq',              (SELECT MAX(statusId)                FROM status));
SELECT setval('races_raceid_seq',                 (SELECT MAX(raceId)                  FROM races));
SELECT setval('results_resultid_seq',             (SELECT MAX(resultId)                FROM results));
SELECT setval('qualifying_qualifyid_seq',         (SELECT MAX(qualifyId)               FROM qualifying));
SELECT setval('driver_standings_driverstandingsid_seq',             (SELECT MAX(driverStandingsId)       FROM driver_standings));
SELECT setval('constructor_standings_constructorstandingsid_seq',   (SELECT MAX(constructorStandingsId)  FROM constructor_standings));
SELECT setval('sprint_results_resultid_seq',      (SELECT MAX(resultId)                FROM sprint_results));
SELECT setval('constructor_results_constructorresultsid_seq',       (SELECT MAX(constructorResultsId)    FROM constructor_results));
