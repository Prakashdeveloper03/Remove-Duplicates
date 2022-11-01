/*
 Requirement: Delete duplicate data from cars table.
 Duplicate record is identified based on the model and brand name.
 */
DROP TABLE IF EXISTS cars;

CREATE TABLE IF NOT EXISTS cars (
    id int,
    model varchar(50),
    brand varchar(40),
    color varchar(30),
    make int
);

INSERT INTO
    cars
VALUES
    (1, 'Model S', 'Tesla', 'Blue', 2018),
    (2, 'EQS', 'Mercedes-Benz', 'Black', 2022),
    (3, 'iX', 'BMW', 'Red', 2022),
    (4, 'Ioniq 5', 'Hyundai', 'White', 2021),
    (5, 'Model S', 'Tesla', 'Silver', 2018),
    (6, 'Ioniq 5', 'Hyundai', 'Green', 2021);

SELECT
    *
FROM
    cars
ORDER BY
    model,
    brand;

-->> SOLUTION 1: Delete using Unique identifier
DELETE FROM
    cars
WHERE
    id IN (
        SELECT
            max(id)
        FROM
            cars
        GROUP BY
            model,
            brand
        HAVING
            count(id) > 1
    );

-->> SOLUTION 2: Using SELF join
DELETE FROM
    cars
WHERE
    id IN (
        SELECT
            c2.id
        FROM
            cars c1
            JOIN cars c2 ON c1.model = c2.model
            AND c1.brand = c2.brand
        WHERE
            c1.id < c2.id
    );

-->> SOLUTION 3: Using Window function
DELETE FROM
    cars
WHERE
    id IN (
        SELECT
            id
        FROM
            (
                SELECT
                    *,
                    row_number() over(
                        PARTITION by model,
                        brand
                        ORDER BY
                            id
                    ) AS rn
                FROM
                    cars
            ) x
        WHERE
            x.rn > 1
    );

-->> SOLUTION 4: Using MIN function. This delete even multiple duplicate records.
DELETE FROM
    cars
WHERE
    id NOT IN (
        SELECT
            min(id)
        FROM
            cars
        GROUP BY
            model,
            brand
    );

-->> SOLUTION 5: Using backup table.
DROP TABLE IF EXISTS cars_bkp;

CREATE TABLE IF NOT EXISTS cars_bkp AS
SELECT
    *
FROM
    cars
WHERE
    1 = 0;

INSERT INTO
    cars_bkp
SELECT
    *
FROM
    cars
WHERE
    id IN (
        SELECT
            min(id)
        FROM
            cars
        GROUP BY
            model,
            brand
    );

DROP TABLE cars;

ALTER TABLE
    cars_bkp RENAME TO cars;

-->> SOLUTION 6: Using backup table without dropping the original table.
DROP TABLE IF EXISTS cars_bkp;

CREATE TABLE IF NOT EXISTS cars_bkp AS
SELECT
    *
FROM
    cars
WHERE
    1 = 0;

INSERT INTO
    cars_bkp
SELECT
    *
FROM
    cars
WHERE
    id IN (
        SELECT
            min(id)
        FROM
            cars
        GROUP BY
            model,
            brand
    );

TRUNCATE TABLE cars;

INSERT INTO
    cars
SELECT
    *
FROM
    cars_bkp;

DROP TABLE cars_bkp;

-- Requirement: Delete duplicate entry for a car in the CARS table.
DROP TABLE IF EXISTS cars;

CREATE TABLE IF NOT EXISTS cars (
    id int,
    model varchar(50),
    brand varchar(40),
    color varchar(30),
    make int
);

INSERT INTO
    cars
VALUES
    (1, 'Model S', 'Tesla', 'Blue', 2018),
    (2, 'EQS', 'Mercedes-Benz', 'Black', 2022),
    (3, 'iX', 'BMW', 'Red', 2022),
    (4, 'Ioniq 5', 'Hyundai', 'White', 2021),
    (5, 'Model S', 'Tesla', 'Silver', 2018),
    (6, 'Ioniq 5', 'Hyundai', 'Green', 2021);

SELECT
    *
FROM
    cars;

-->> SOLUTION 1: Delete using CTID / ROWID (in Oracle)
DELETE FROM
    cars
WHERE
    ctid IN (
        SELECT
            max(ctid)
        FROM
            cars
        GROUP BY
            model,
            brand
        HAVING
            count(1) > 1
    );

-->> SOLUTION 2: By creating a temporary unique id column
ALTER TABLE
    cars
ADD
    COLUMN row_num int generated always AS identity
DELETE FROM
    cars
WHERE
    row_num NOT IN (
        SELECT
            min(row_num)
        FROM
            cars
        GROUP BY
            model,
            brand
    );

ALTER TABLE
    cars DROP COLUMN row_num;

-->> SOLUTION 3: By creating a backup table.
CREATE TABLE cars_bkp AS
SELECT
    DISTINCT *
FROM
    cars;

DROP TABLE cars;

ALTER TABLE
    cars_bkp RENAME TO cars;

-->> SOLUTION 4: By creating a backup table without dropping the original table.
CREATE TABLE cars_bkp AS
SELECT
    DISTINCT *
FROM
    cars;

TRUNCATE TABLE cars;

INSERT INTO
    cars
SELECT
    DISTINCT *
FROM
    cars_bkp;

DROP TABLE cars_bkp;