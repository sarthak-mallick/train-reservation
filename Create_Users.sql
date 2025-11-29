SET SERVEROUTPUT ON;

-- Create Schemas, Roles, and Users
-- Run as: ADMIN
-- Purpose: Set up all users and roles for the CRS application

-- Create Application Admin Schema (Structure Owner)

BEGIN
    EXECUTE IMMEDIATE 'DROP USER crs_admin CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('CRS_ADMIN user does not exist. Skipping drop...');
END;
/

CREATE USER crs_admin IDENTIFIED BY Admin123!
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CREATE SESSION TO crs_admin;
GRANT CREATE TABLE TO crs_admin;
GRANT CREATE SEQUENCE TO crs_admin;
GRANT CREATE VIEW TO crs_admin;
GRANT CREATE PROCEDURE TO crs_admin;
GRANT CREATE TRIGGER TO crs_admin;
GRANT CREATE SYNONYM TO crs_admin;

DBMS_OUTPUT.PUT_LINE('User CRS_ADMIN created - Application Admin (owns schema structure).');

-- Create Data Management Schema

BEGIN
    EXECUTE IMMEDIATE 'DROP USER crs_data CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('CRS_DATA user does not exist. Skipping drop...');
END;
/

CREATE USER crs_data IDENTIFIED BY Data123!
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CREATE SESSION TO crs_data;

DBMS_OUTPUT.PUT_LINE('User CRS_DATA created - Data Manager (manages data operations).');

-- Create Application Roles

BEGIN
    EXECUTE IMMEDIATE 'DROP ROLE crs_agent_role';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE ROLE crs_agent_role;
GRANT CREATE SESSION TO crs_agent_role;
DBMS_OUTPUT.PUT_LINE('Role CRS_AGENT_ROLE created.');

BEGIN
    EXECUTE IMMEDIATE 'DROP ROLE crs_report_role';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE ROLE crs_report_role;
GRANT CREATE SESSION TO crs_report_role;
DBMS_OUTPUT.PUT_LINE('Role CRS_REPORT_ROLE created.');

BEGIN
    EXECUTE IMMEDIATE 'DROP ROLE crs_operations_role';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE ROLE crs_operations_role;
GRANT CREATE SESSION TO crs_operations_role;
DBMS_OUTPUT.PUT_LINE('Role CRS_OPERATIONS_ROLE created.');

-- Create Application Users

-- Booking Agent
BEGIN
    EXECUTE IMMEDIATE 'DROP USER crs_agent1 CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE USER crs_agent1 IDENTIFIED BY Agent123!
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 100M ON users;
GRANT crs_agent_role TO crs_agent1;
DBMS_OUTPUT.PUT_LINE('User CRS_AGENT1 created and granted CRS_AGENT_ROLE.');

-- Reports User
BEGIN
    EXECUTE IMMEDIATE 'DROP USER crs_reports CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE USER crs_reports IDENTIFIED BY Report123!
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 50M ON users;
GRANT crs_report_role TO crs_reports;
DBMS_OUTPUT.PUT_LINE('User CRS_REPORTS created and granted CRS_REPORT_ROLE.');

-- Operations User
BEGIN
    EXECUTE IMMEDIATE 'DROP USER crs_operations CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE USER crs_operations IDENTIFIED BY Ops123!
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 100M ON users;
GRANT crs_operations_role TO crs_operations;
DBMS_OUTPUT.PUT_LINE('User CRS_OPERATIONS created and granted CRS_OPERATIONS_ROLE.');
/