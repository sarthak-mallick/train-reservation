-- Package: PKG_PASSENGER
-- Purpose: Manage passenger registration and information
-- Owner: CRS_ADMIN

CREATE OR REPLACE PACKAGE PKG_PASSENGER AS

/**
    * Register a new passenger
    * @return passenger_id if successful, -1 if error
    */
FUNCTION register_passenger(
    p_first_name IN VARCHAR2,
    p_middle_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_date_of_birth IN DATE,
    p_address_line1 IN VARCHAR2,
    p_address_city IN VARCHAR2,
    p_address_state IN VARCHAR2,
    p_address_zip IN VARCHAR2,
    p_email IN VARCHAR2,
    p_phone IN VARCHAR2,
    p_error_msg OUT VARCHAR2
) RETURN NUMBER;

/**
    * Update passenger information (DOB, names cannot be changed)
    * @return TRUE if successful, FALSE otherwise
    */
FUNCTION update_passenger(
    p_passenger_id IN NUMBER,
    p_address_line1 IN VARCHAR2,
    p_address_city IN VARCHAR2,
    p_address_state IN VARCHAR2,
    p_address_zip IN VARCHAR2,
    p_email IN VARCHAR2,
    p_phone IN VARCHAR2,
    p_error_msg OUT VARCHAR2
) RETURN BOOLEAN;

/**
    * Search passenger by email, phone, or ID
    * @param p_search_type 'EMAIL', 'PHONE', or 'ID'
    * @param p_search_value the value to search for
    * @return passenger_id if found, NULL otherwise
    */
FUNCTION search_passenger(
    p_search_type IN VARCHAR2,
    p_search_value IN VARCHAR2
) RETURN NUMBER;

END PKG_PASSENGER;
/