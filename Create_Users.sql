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

CREATE USER crs_admin IDENTIFIED BY "Admin123!Pass"
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


-- Create Data Management Schema

BEGIN
    EXECUTE IMMEDIATE 'DROP USER crs_data CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('CRS_DATA user does not exist. Skipping drop...');
END;
/

CREATE USER crs_data IDENTIFIED BY "Data123!Pass1"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;

GRANT CREATE SESSION TO crs_data;


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

BEGIN
    EXECUTE IMMEDIATE 'DROP ROLE crs_report_role';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE ROLE crs_report_role;
GRANT CREATE SESSION TO crs_report_role;

BEGIN
    EXECUTE IMMEDIATE 'DROP ROLE crs_operations_role';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE ROLE crs_operations_role;
GRANT CREATE SESSION TO crs_operations_role;

-- Create Application Users

-- Booking Agent
BEGIN
    EXECUTE IMMEDIATE 'DROP USER crs_agent CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE USER crs_agent IDENTIFIED BY "Agent123!Pass"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 100M ON users;
GRANT crs_agent_role TO crs_agent;

-- Reports User
BEGIN
    EXECUTE IMMEDIATE 'DROP USER crs_reports CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE USER crs_reports IDENTIFIED BY "Report123!@#"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 50M ON users;
GRANT crs_report_role TO crs_reports;

-- Operations User
BEGIN
    EXECUTE IMMEDIATE 'DROP USER crs_operations CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE USER crs_operations IDENTIFIED BY "Ops123!Pass12"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA 100M ON users;
GRANT crs_operations_role TO crs_operations;
/