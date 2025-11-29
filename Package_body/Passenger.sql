-- Package Body: PKG_PASSENGER
-- Purpose: Implementation of passenger management operations
-- Owner: CRS_ADMIN

CREATE OR REPLACE PACKAGE BODY PKG_PASSENGER AS

/**
    * Register a new passenger
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
) RETURN NUMBER AS
    v_passenger_id NUMBER;
BEGIN
    -- TODO: Implement passenger registration
    -- 1. Validate required fields are not null
    -- 2. Check email uniqueness
    -- 3. Check phone uniqueness
    -- 4. INSERT into CRS_PASSENGER
    -- 5. Return generated passenger_id
    -- 6. COMMIT
    
    RETURN -1; -- Placeholder
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        p_error_msg := 'Email or phone already exists.';
        RETURN -1;
    WHEN OTHERS THEN
        ROLLBACK;
        p_error_msg := 'Error: ' || SQLERRM;
        RETURN -1;
END register_passenger;

/**
    * Update passenger information (DOB, names cannot be changed)
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
) RETURN BOOLEAN AS
    v_count NUMBER;
BEGIN
    -- TODO: Implement passenger update
    -- 1. Check if passenger exists
    -- 2. Validate email/phone not taken by another passenger
    -- 3. UPDATE CRS_PASSENGER (only address, email, phone)
    -- 4. COMMIT
    -- 5. Return TRUE if successful
    
    RETURN FALSE; -- Placeholder
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        p_error_msg := 'Email or phone already exists.';
        RETURN FALSE;
    WHEN OTHERS THEN
        ROLLBACK;
        p_error_msg := 'Error: ' || SQLERRM;
        RETURN FALSE;
END update_passenger;

/**
    * Search passenger by email, phone, or ID
    */
FUNCTION search_passenger(
    p_search_type IN VARCHAR2,
    p_search_value IN VARCHAR2
) RETURN NUMBER AS
    v_passenger_id NUMBER;
BEGIN
    -- TODO: Implement passenger search
    -- 1. Validate search_type is 'EMAIL', 'PHONE', or 'ID'
    -- 2. Query CRS_PASSENGER based on search type
    -- 3. Return passenger_id if found, NULL otherwise
    
    RETURN NULL; -- Placeholder
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END search_passenger;

END PKG_PASSENGER;
/