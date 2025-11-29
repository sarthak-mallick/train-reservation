SET SERVEROUTPUT ON;

-- Master Script: Create All Packages and Grant Permissions
-- Run as: CRS_ADMIN
-- Purpose: Create packages (specs + bodies) and grant execute permissions

-- Create Package Specifications
@@Package_spec/Booking_spec.sql
@@Package_spec/Passenger_spec.sql
@@Package_spec/Train_spec.sql
@@Package_spec/Validation_spec.sql

-- Create Package Bodies
@@Package_body/Booking.sql
@@Package_body/Passenger.sql
@@Package_body/Train.sql
@@Package_body/Validation.sql
/

-- Grant Package Execute Permissions to CRS_AGENT_ROLE
GRANT EXECUTE ON PKG_VALIDATION TO crs_agent_role;
GRANT EXECUTE ON PKG_PASSENGER TO crs_agent_role;
GRANT EXECUTE ON PKG_BOOKING TO crs_agent_role;
/

-- Grant Package Execute Permissions to CRS_OPERATIONS_ROLE
GRANT EXECUTE ON PKG_TRAIN TO crs_operations_role;
/