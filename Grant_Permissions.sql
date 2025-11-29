SET SERVEROUTPUT ON;

-- Grant All Permissions
-- Run as: CRS_ADMIN
-- Purpose: Grant DML to CRS_DATA and table access to roles

-- Grant DML Privileges to CRS_DATA

GRANT SELECT, INSERT, UPDATE, DELETE ON CRS_TRAIN_INFO TO crs_data;
GRANT SELECT, INSERT, UPDATE, DELETE ON CRS_DAY_SCHEDULE TO crs_data;
GRANT SELECT, INSERT, UPDATE, DELETE ON CRS_TRAIN_SCHEDULE TO crs_data;
GRANT SELECT, INSERT, UPDATE, DELETE ON CRS_PASSENGER TO crs_data;
GRANT SELECT, INSERT, UPDATE, DELETE ON CRS_RESERVATION TO crs_data;

-- Grant Privileges to CRS_AGENT_ROLE

-- Agents can view train information
GRANT SELECT ON CRS_TRAIN_INFO TO crs_agent_role;
GRANT SELECT ON CRS_DAY_SCHEDULE TO crs_agent_role;
GRANT SELECT ON CRS_TRAIN_SCHEDULE TO crs_agent_role;

-- Agents can manage passengers and reservations
GRANT SELECT, INSERT, UPDATE ON CRS_PASSENGER TO crs_agent_role;
GRANT SELECT, INSERT, UPDATE ON CRS_RESERVATION TO crs_agent_role;

-- Grant Privileges to CRS_REPORT_ROLE

-- Reports users have read-only access to all tables
GRANT SELECT ON CRS_TRAIN_INFO TO crs_report_role;
GRANT SELECT ON CRS_DAY_SCHEDULE TO crs_report_role;
GRANT SELECT ON CRS_TRAIN_SCHEDULE TO crs_report_role;
GRANT SELECT ON CRS_PASSENGER TO crs_report_role;
GRANT SELECT ON CRS_RESERVATION TO crs_report_role;

-- Grant Privileges to CRS_OPERATIONS_ROLE

-- Operations can manage trains and schedules
GRANT SELECT, INSERT, UPDATE ON CRS_TRAIN_INFO TO crs_operations_role;
GRANT SELECT, INSERT, UPDATE ON CRS_TRAIN_SCHEDULE TO crs_operations_role;

-- Operations can view day schedules and reservations (read-only)
GRANT SELECT ON CRS_DAY_SCHEDULE TO crs_operations_role;
GRANT SELECT ON CRS_RESERVATION TO crs_operations_role;
/