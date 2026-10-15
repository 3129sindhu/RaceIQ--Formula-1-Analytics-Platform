

DROP TABLE IF EXISTS constructor_results    CASCADE;
DROP TABLE IF EXISTS sprint_results        CASCADE;
DROP TABLE IF EXISTS constructor_standings CASCADE;
DROP TABLE IF EXISTS driver_standings      CASCADE;
DROP TABLE IF EXISTS pit_stops             CASCADE;
DROP TABLE IF EXISTS lap_times             CASCADE;
DROP TABLE IF EXISTS qualifying            CASCADE;
DROP TABLE IF EXISTS results               CASCADE;
DROP TABLE IF EXISTS races                 CASCADE;
DROP TABLE IF EXISTS status                CASCADE;
DROP TABLE IF EXISTS drivers               CASCADE;
DROP TABLE IF EXISTS constructors          CASCADE;
DROP TABLE IF EXISTS circuits              CASCADE;
DROP TABLE IF EXISTS seasons               CASCADE;

-- ============================================================
-- 1. seasons
CREATE TABLE seasons (
    year INT         PRIMARY KEY,
    url  TEXT
);

-- ============================================================
-- 2. circuits 

CREATE TABLE circuits (
    circuitId  SERIAL        PRIMARY KEY,
    circuitRef VARCHAR(50)   NOT NULL UNIQUE,
    name       VARCHAR(100)  NOT NULL UNIQUE,
    location   VARCHAR(100),
    country    VARCHAR(60),
    lat        NUMERIC(8,5),
    lng        NUMERIC(8,5),
    alt        INT,
    url        TEXT
);

-- ============================================================
-- 3. constructors 

CREATE TABLE constructors (
    constructorId  SERIAL       PRIMARY KEY,
    constructorRef VARCHAR(50)  NOT NULL UNIQUE,
    name           VARCHAR(100) NOT NULL UNIQUE,
    nationality    VARCHAR(50),
    url            TEXT
);

-- ============================================================
-- 4. drivers 

CREATE TABLE drivers (
    driverId    SERIAL      PRIMARY KEY,
    driverRef   VARCHAR(50) NOT NULL UNIQUE,
    number      INT,
    code        CHAR(3),
    forename    VARCHAR(50) NOT NULL,
    surname     VARCHAR(50) NOT NULL,
    dob         DATE,
    nationality VARCHAR(50),
    url         TEXT
);

-- ============================================================
-- 5. status 

CREATE TABLE status (
    statusId SERIAL      PRIMARY KEY,
    status   VARCHAR(50) NOT NULL UNIQUE
);

-- ============================================================
-- 6. races 

CREATE TABLE races (
    raceId      SERIAL       PRIMARY KEY,
    year        INT          NOT NULL REFERENCES seasons(year)    ON DELETE RESTRICT,
    round       INT          NOT NULL,
    circuitId   INT          NOT NULL REFERENCES circuits(circuitId) ON DELETE RESTRICT,
    name        VARCHAR(100) NOT NULL,
    date       DATE         NOT NULL,
    time        TIME,
    url      TEXT,
    fp1_date    DATE,
    fp1_time    TIME,
    fp2_date    DATE,
    fp2_time    TIME,
    fp3_date    DATE,
    fp3_time    TIME,
    quali_date  DATE,
    quali_time  TIME,
    sprint_date DATE,
    sprint_time TIME,
    UNIQUE (year, round)
);

-- ============================================================
-- 7. results 

CREATE TABLE results (
    resultId        SERIAL        PRIMARY KEY,
    raceId          INT           NOT NULL REFERENCES races(raceId)            ON DELETE CASCADE,
    driverId        INT           NOT NULL REFERENCES drivers(driverId)        ON DELETE CASCADE,
    constructorId   INT           NOT NULL REFERENCES constructors(constructorId) ON DELETE CASCADE,
    number          INT,
    grid            INT,
    position        INT,
    positionText    VARCHAR(5),
    positionOrder   INT           NOT NULL,
    points          NUMERIC(5,2)  NOT NULL,
    laps            INT,
    time            VARCHAR(20),
    milliseconds    INT,
    fastestLap      INT,
    rank            INT,
    fastestLapTime  VARCHAR(10),
    fastestLapSpeed NUMERIC(7,3),
    statusId        INT           NOT NULL REFERENCES status(statusId) ON DELETE RESTRICT
);

-- ============================================================
-- 8. qualifying

CREATE TABLE qualifying (
    qualifyId     SERIAL      PRIMARY KEY,
    raceId        INT         NOT NULL REFERENCES races(raceId)            ON DELETE CASCADE,
    driverId      INT         NOT NULL REFERENCES drivers(driverId)        ON DELETE CASCADE,
    constructorId INT         NOT NULL REFERENCES constructors(constructorId) ON DELETE CASCADE,
    number        INT,
    position      INT,
    q1            VARCHAR(10),
    q2            VARCHAR(10),
    q3            VARCHAR(10),
    UNIQUE (raceId, driverId)
);

-- ============================================================
-- 9. lap times 
CREATE TABLE lap_times (
    raceId       INT         NOT NULL REFERENCES races(raceId)     ON DELETE CASCADE,
    driverId     INT         NOT NULL REFERENCES drivers(driverId)  ON DELETE CASCADE,
    lap          INT         NOT NULL,
    position     INT,
    time         VARCHAR(15),
    milliseconds INT,
    PRIMARY KEY (raceId, driverId, lap)
);

-- ============================================================
-- 10. Pit stops 

CREATE TABLE pit_stops (
    raceId       INT     NOT NULL REFERENCES races(raceId)     ON DELETE CASCADE,
    driverId     INT     NOT NULL REFERENCES drivers(driverId)  ON DELETE CASCADE,
    stop         INT     NOT NULL,
    lap          INT     NOT NULL,
    time         TIME,
    duration     VARCHAR(10),
    milliseconds INT,
    PRIMARY KEY (raceId, driverId, stop)
);

-- ============================================================
-- 11. driver_standings 

CREATE TABLE driver_standings (
    driverStandingsId SERIAL       PRIMARY KEY,
    raceId            INT          NOT NULL REFERENCES races(raceId)     ON DELETE CASCADE,
    driverId          INT          NOT NULL REFERENCES drivers(driverId)  ON DELETE CASCADE,
    points            NUMERIC(6,2) NOT NULL,
    position          INT,
    wins              INT          NOT NULL,
    is_disqualified   BOOLEAN      NOT NULL DEFAULT FALSE,
    UNIQUE (raceId, driverId)
);

-- ============================================================
-- 12. constructor_standings 
CREATE TABLE constructor_standings (
    constructorStandingsId SERIAL       PRIMARY KEY,
    raceId                 INT          NOT NULL REFERENCES races(raceId)               ON DELETE CASCADE,
    constructorId          INT          NOT NULL REFERENCES constructors(constructorId)  ON DELETE CASCADE,
    points                 NUMERIC(6,2) NOT NULL,
    position               INT,
    wins                   INT          NOT NULL,
    is_excluded            BOOLEAN      NOT NULL DEFAULT FALSE,
    UNIQUE (raceId, constructorId)
);

-- ============================================================
-- 13. Sprint results

CREATE TABLE sprint_results (
    resultId      SERIAL       PRIMARY KEY,
    raceId        INT          NOT NULL REFERENCES races(raceId)               ON DELETE CASCADE,
    driverId      INT          NOT NULL REFERENCES drivers(driverId)            ON DELETE CASCADE,
    constructorId INT          NOT NULL REFERENCES constructors(constructorId)  ON DELETE CASCADE,
    number        INT,
    grid          INT,
    position      INT,
    positionText  VARCHAR(5),
    positionOrder INT          NOT NULL,
    points        NUMERIC(4,2) NOT NULL,
    laps          INT,
    time          VARCHAR(20),
    milliseconds  INT,
    fastestLap    INT,
    fastestLapTime VARCHAR(10),
    statusId      INT          NOT NULL REFERENCES status(statusId) ON DELETE RESTRICT,
    UNIQUE (raceId, driverId)
);

-- ============================================================
-- 14. constructor_results 

CREATE TABLE constructor_results (
    constructorResultsId SERIAL       PRIMARY KEY,
    raceId               INT          NOT NULL REFERENCES races(raceId)               ON DELETE CASCADE,
    constructorId        INT          NOT NULL REFERENCES constructors(constructorId)  ON DELETE CASCADE,
    points               NUMERIC(5,2),
    status               CHAR(1)
);
