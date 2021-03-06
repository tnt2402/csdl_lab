-- create tables
-- create regions table
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS job_history;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS countries;
DROP TABLE IF EXISTS regions;
DROP TABLE IF EXISTS job_grades;

CREATE TABLE IF NOT EXISTS regions (
    REGION_ID INT PRIMARY KEY,
    REGION_NAME VARCHAR(25) NOT NULL
);
-- create countries table
CREATE TABLE IF NOT EXISTS countries (
    COUNTRY_ID CHAR(2) UNIQUE NOT NULL,
    COUNTRY_NAME VARCHAR(40) NOT NULL,
    REGION_ID INT NOT NULL,
    PRIMARY KEY (COUNTRY_ID),
	FOREIGN KEY (REGION_ID) 
	    REFERENCES regions (REGION_ID)
);
-- create locations table
CREATE TABLE IF NOT EXISTS locations (
    LOCATION_ID INT UNIQUE NOT NULL,
    STREET_ADDRESS VARCHAR(25) NOT NULL,
    POSTAL_CODE VARCHAR(12) NOT NULL,
    CITY VARCHAR(30) NOT NULL,
    STATE_PROVINCE VARCHAR(20) NOT NULL,
    COUNTRY_ID CHAR(2) NOT NULL,
    FOREIGN KEY (COUNTRY_ID)
        REFERENCES countries (COUNTRY_ID)
);
-- create departments table
CREATE TABLE IF NOT EXISTS departments (
    DEPARTMENT_ID INT PRIMARY KEY,
    DEPARTMENT_NAME VARCHAR(30) NOT NULL,
    MANAGER_ID INT NOT NULL,
    LOCATION_ID INT NOT NULL,
    FOREIGN KEY (LOCATION_ID) 
    REFERENCES locations (LOCATION_ID)
);
-- create jobs table
CREATE TABLE IF NOT EXISTS jobs (
    JOB_ID VARCHAR(10) UNIQUE PRIMARY KEY,
    JOB_TITLE VARCHAR(35) NOT NULL,
    MIN_SALARY INT NOT NULL,
    MAX_SALARY INT NOT NULL
);
-- create job_history table
CREATE TABLE IF NOT EXISTS job_history (
    EMPLOYEE_ID INT UNIQUE NOT NULL,
    START_DATE DATE UNIQUE,
    END_DATE DATE,
    JOB_ID VARCHAR(20) NOT NULL,
    DEPARTMENT_ID INT NOT NULL,
	PRIMARY KEY (EMPLOYEE_ID, START_DATE),
	FOREIGN KEY (DEPARTMENT_ID)
		REFERENCES departments (DEPARTMENT_ID)
);
-- create employees table 
CREATE TABLE IF NOT EXISTS employees (
    EMPLOYEE_ID INT NOT NULL,
    FIRST_NAME VARCHAR(20) NOT NULL,
    LAST_NAME VARCHAR(25) NOT NULL,
    EMAIL VARCHAR(25) NOT NULL,
    PHONE_NUMBER VARCHAR(25) NOT NULL,
    HIRE_DATE DATE NOT NULL,
    JOB_ID VARCHAR(10) NOT NULL,
    SALARY INT NOT NULL,
    COMMISSION_PCT INT NOT NULL,
    MANAGER_ID INT NOT NULL,
    DEPARTMENT_ID INT NOT NULL,
    PRIMARY KEY (EMPLOYEE_ID),
    FOREIGN KEY (EMPLOYEE_ID)
    	REFERENCES job_history (EMPLOYEE_ID),
    FOREIGN KEY (DEPARTMENT_ID)
    	REFERENCES departments (DEPARTMENT_ID),
    FOREIGN KEY (JOB_ID)
    	REFERENCES jobs (JOB_ID)
);

-- create job_grades table
CREATE TABLE IF NOT EXISTS job_grades (
    GRADE_LEVEL VARCHAR(2) PRIMARY KEY,
    LOWEST_SAL INT NOT NULL,
    HIGHEST_SAL INT NOT NULL
);

-- 1. ?????i t??n b???ng countries th??nh country_new
ALTER TABLE countries
RENAME TO country_new;
-- 2. Th??m c???t region_id t???i b???ng locations 
ALTER TABLE locations
ADD COLUMN region_id INT;
-- 3. Th??m c???t ID v??o b???ng locations v???i ??i???u ki???n c???t ID l?? c???t ?????u ti??n c???a b???ng. 
CREATE TABLE tmp_table AS (SELECT * FROM locations);
DROP TABLE IF EXISTS locations CASCADE;
CREATE TABLE locations (
    ID INT NOT NULL,
    LOCATION_ID INT NOT NULL,
    STREET_ADDRESS VARCHAR(25) NOT NULL,
    POSTAL_CODE VARCHAR(12) NOT NULL,
    CITY VARCHAR(30) NOT NULL,
    STATE_PROVINCE VARCHAR(20) NOT NULL,
    COUNTRY_ID CHAR(2) NOT NULL,
    PRIMARY KEY (LOCATION_ID),
    FOREIGN KEY (COUNTRY_ID)
        REFERENCES countries (COUNTRY_ID)
);
INSERT INTO locations(LOCATION_ID, STREET_ADDRESS, POSTAL_CODE, CITY, STATE_PROVINCE, COUNTRY_ID)
SELECT LOCATION_ID, STREET_ADDRESS, POSTAL_CODE, CITY, STATE_PROVINCE, COUNTRY_ID FROM tmp_table;
DROP TABLE tmp_table CASCADE;

-- 4. Th??m c???t region_id ?????ng li???n sau c???t state_province c???a b???ng locations.
CREATE TABLE tmp_table 
	AS (SELECT * FROM locations);
DROP TABLE IF EXISTS locations CASCADE;
CREATE TABLE locations (
    ID INT NOT NULL,
    LOCATION_ID INT NOT NULL,
    STREET_ADDRESS VARCHAR(25) NOT NULL,
    POSTAL_CODE VARCHAR(12) NOT NULL,
    CITY VARCHAR(30) NOT NULL,
    STATE_PROVINCE VARCHAR(20) NOT NULL,
	region_id INT NOT NULL,
    COUNTRY_ID CHAR(2) NOT NULL,
    PRIMARY KEY (LOCATION_ID),
    FOREIGN KEY (COUNTRY_ID)
        REFERENCES countries (COUNTRY_ID)
 );
INSERT INTO locations(LOCATION_ID, STREET_ADDRESS, POSTAL_CODE, CITY, STATE_PROVINCE, COUNTRY_ID)
	SELECT LOCATION_ID, STREET_ADDRESS, POSTAL_CODE, CITY, STATE_PROVINCE, COUNTRY_ID FROM tmp_table;
DROP TABLE tmp_table CASCADE;
-- 5. Thay ?????i ki???u d??? li???u c???a c???t country_id th??nh integer trong b???ng locations. 
ALTER TABLE locations
	DROP CONSTRAINT locations_country_id_fkey;
ALTER TABLE locations
	ALTER COLUMN country_id TYPE INT USING country_id::INTEGER;
-- 6. X??a c???t city trong b???ng locations
ALTER TABLE locations
	DROP COLUMN city;
-- 7. ?????i t??n c???t state_province th??nh c???t state, gi???a nguy??n ki???u v?? k??ch th?????c 
-- c???a c???t. 
ALTER TABLE locations
	RENAME COLUMN state_province TO state;
-- 8. Th??m kh??a ch??nh cho c???t location_id trong b???ng location
ALTER TABLE locations
ADD CONSTRAINT location_id_pkey 
PRIMARY KEY (location_id);
-- 9. Th??m kh??a ch??nh l?? c???p 2 c???t (location_id, country_id) cho b???ng locations.
ALTER TABLE locations
ADD CONSTRAINT id_pkey
PRIMARY KEY (location_id, country_id);
-- 10. X??a kh??a ch??nh l?? c???p (location_id, country_id) ???? t???o.
ALTER TABLE locations
ADD CONSTRAINT id_pkey
PRIMARY KEY (location_id, country_id);

ALTER TABLE locations
DROP CONSTRAINT id_pkey;
-- 11. T???o kh??a ngo???i job_id cho b???ng job_history m?? tham chi???u t???i job_id c???a 
-- b???ng jobs.
ALTER TABLE job_history
ADD FOREIGN KEY (JOB_ID)
REFERENCES jobs (JOB_ID);
-- 12. T???o r??ng bu???c c?? t??n l?? fk_job_id v???i job_id c???a b???ng job_history tham chi???u 
-- t???i job_id c???a b???ng jobs.
ALTER TABLE job_history
ADD CONSTRAINT fk_job_id
FOREIGN KEY (JOB_ID)
REFERENCES jobs (JOB_ID);
-- 13. X??a kh??a ngo???i fk_job_id trong b???ng job_history ???? t???o. 
ALTER TABLE job_history
DROP CONSTRAINT fk_job_id;
-- 14. Th??m ch??? m???c c?? t??n indx_job_id tr??n thu???c t??nh job_id c???a b???ng job_history.
CREATE INDEX indx_job_id 
    ON job_history (job_id);
-- 15. X??a ch??? m???c indx_job_id trong b???ng job_history
DROP INDEX indx_job_id;