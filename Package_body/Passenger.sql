-- Package Body: PKG_PASSENGER
-- Purpose: Implementation of passenger management operations
-- Owner: CRS_ADMIN

CREATE OR REPLACE PACKAGE BODY PKG_PASSENGER AS

    -- Private Helper: Validate email format
    FUNCTION is_valid_email(p_email IN VARCHAR2) RETURN BOOLEAN AS
    BEGIN
        IF p_email IS NULL THEN
            RETURN FALSE;
        END IF;
        RETURN REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
    END is_valid_email;

    -- Private Helper: Validate phone format (min 10 digits)
    FUNCTION is_valid_phone(p_phone IN VARCHAR2) RETURN BOOLEAN AS
    BEGIN
        IF p_phone IS NULL THEN
            RETURN FALSE;
        END IF;
        RETURN LENGTH(REGEXP_REPLACE(p_phone, '[^0-9]', '')) >= 10;
    END is_valid_phone;

    -- Private Helper: Validate date of birth
    FUNCTION is_valid_dob(p_dob IN DATE) RETURN BOOLEAN AS
        v_age NUMBER;
    BEGIN
        IF p_dob IS NULL THEN
            RETURN FALSE;
        END IF;
        IF p_dob > SYSDATE THEN
            RETURN FALSE;
        END IF;
        v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, p_dob) / 12);
        RETURN v_age >= 0 AND v_age <= 150;
    END is_valid_dob;


    -- Function: register_passenger
    -- Purpose: Insert a new passenger after validating all rules
    -- Returns: passenger_id if success, -1 if failure
    FUNCTION register_passenger(
        p_first_name     IN VARCHAR2,
        p_middle_name    IN VARCHAR2,
        p_last_name      IN VARCHAR2,
        p_date_of_birth  IN DATE,
        p_address_line1  IN VARCHAR2,
        p_address_city   IN VARCHAR2,
        p_address_state  IN VARCHAR2,
        p_address_zip    IN VARCHAR2,
        p_email          IN VARCHAR2,
        p_phone          IN VARCHAR2,
        p_error_msg      OUT VARCHAR2
    ) RETURN NUMBER AS
        v_passenger_id CRS_PASSENGER.passenger_id%TYPE;
    BEGIN
        p_error_msg := NULL;

        -- 1. Validate whitespace-only values (DDL allows '   ' but we shouldn't)
        IF TRIM(p_first_name) IS NULL OR TRIM(p_last_name) IS NULL OR
           TRIM(p_address_line1) IS NULL OR TRIM(p_address_city) IS NULL OR
           TRIM(p_address_state) IS NULL OR TRIM(p_address_zip) IS NULL OR
           TRIM(p_email) IS NULL OR TRIM(p_phone) IS NULL THEN
            p_error_msg := 'Required fields cannot be empty or whitespace only.';
            RETURN -1;
        END IF;

        -- 2. Validate email format (DDL has no format check)
        IF NOT is_valid_email(TRIM(p_email)) THEN
            p_error_msg := 'Invalid email format.';
            RETURN -1;
        END IF;

        -- 3. Validate phone format (DDL has no format check)
        IF NOT is_valid_phone(TRIM(p_phone)) THEN
            p_error_msg := 'Invalid phone format. Must have at least 10 digits.';
            RETURN -1;
        END IF;

        -- 4. Validate date of birth (DDL has no future/age check)
        IF NOT is_valid_dob(p_date_of_birth) THEN
            p_error_msg := 'Invalid date of birth.';
            RETURN -1;
        END IF;

        -- 5. Insert passenger (DDL handles NOT NULL and UNIQUE constraints)
        INSERT INTO CRS_PASSENGER (
            first_name, middle_name, last_name, date_of_birth,
            address_line1, address_city, address_state, address_zip,
            email, phone
        )
        VALUES (
            TRIM(p_first_name), 
            TRIM(p_middle_name),
            TRIM(p_last_name), 
            p_date_of_birth,
            TRIM(p_address_line1), 
            TRIM(p_address_city), 
            TRIM(p_address_state), 
            TRIM(p_address_zip),
            LOWER(TRIM(p_email)),
            TRIM(p_phone)
        )
        RETURNING passenger_id INTO v_passenger_id;

        COMMIT;
        RETURN v_passenger_id;

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


    -- Function: update_passenger
    -- Purpose: Update passenger contact/address information
    -- Returns: TRUE if success, FALSE if failure
    FUNCTION update_passenger(
        p_passenger_id   IN NUMBER,
        p_address_line1  IN VARCHAR2,
        p_address_city   IN VARCHAR2,
        p_address_state  IN VARCHAR2,
        p_address_zip    IN VARCHAR2,
        p_email          IN VARCHAR2,
        p_phone          IN VARCHAR2,
        p_error_msg      OUT VARCHAR2
    ) RETURN BOOLEAN AS
        v_cnt          NUMBER;
        v_rows_updated NUMBER;
    BEGIN
        p_error_msg := NULL;

        -- 1. Validate passenger ID
        IF p_passenger_id IS NULL OR p_passenger_id <= 0 THEN
            p_error_msg := 'Valid passenger ID is required.';
            RETURN FALSE;
        END IF;

        -- 2. Check if passenger exists
        SELECT COUNT(*) INTO v_cnt
        FROM CRS_PASSENGER
        WHERE passenger_id = p_passenger_id;

        IF v_cnt = 0 THEN
            p_error_msg := 'Passenger not found with ID: ' || p_passenger_id;
            RETURN FALSE;
        END IF;

        -- 3. Validate whitespace-only values
        IF TRIM(p_address_line1) IS NULL OR TRIM(p_address_city) IS NULL OR
           TRIM(p_address_state) IS NULL OR TRIM(p_address_zip) IS NULL OR
           TRIM(p_email) IS NULL OR TRIM(p_phone) IS NULL THEN
            p_error_msg := 'Required fields cannot be empty or whitespace only.';
            RETURN FALSE;
        END IF;

        -- 4. Validate email format
        IF NOT is_valid_email(TRIM(p_email)) THEN
            p_error_msg := 'Invalid email format.';
            RETURN FALSE;
        END IF;

        -- 5. Validate phone format
        IF NOT is_valid_phone(TRIM(p_phone)) THEN
            p_error_msg := 'Invalid phone format. Must have at least 10 digits.';
            RETURN FALSE;
        END IF;

        -- 6. Perform update (DDL handles UNIQUE constraints)
        UPDATE CRS_PASSENGER
        SET address_line1 = TRIM(p_address_line1),
            address_city  = TRIM(p_address_city),
            address_state = TRIM(p_address_state),
            address_zip   = TRIM(p_address_zip),
            email         = LOWER(TRIM(p_email)),
            phone         = TRIM(p_phone)
        WHERE passenger_id = p_passenger_id;

        v_rows_updated := SQL%ROWCOUNT;
        COMMIT;

        IF v_rows_updated > 0 THEN
            RETURN TRUE;
        ELSE
            p_error_msg := 'No rows updated.';
            RETURN FALSE;
        END IF;

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


    -- Function: search_passenger
    -- Purpose: Find passenger_id by email, phone, or ID
    -- Returns: passenger_id if found, NULL otherwise
    FUNCTION search_passenger(
        p_search_type  IN VARCHAR2,
        p_search_value IN VARCHAR2
    ) RETURN NUMBER AS
        v_passenger_id NUMBER;
        v_search_type  VARCHAR2(10);
    BEGIN
        -- 1. Validate inputs
        IF p_search_type IS NULL OR TRIM(p_search_value) IS NULL THEN
            RETURN NULL;
        END IF;

        v_search_type := UPPER(TRIM(p_search_type));

        -- 2. Validate search type
        IF v_search_type NOT IN ('EMAIL', 'PHONE', 'ID') THEN
            RETURN NULL;
        END IF;

        -- 3. Search based on type
        CASE v_search_type
            WHEN 'EMAIL' THEN
                SELECT passenger_id INTO v_passenger_id
                FROM CRS_PASSENGER
                WHERE UPPER(email) = UPPER(TRIM(p_search_value));

            WHEN 'PHONE' THEN
                SELECT passenger_id INTO v_passenger_id
                FROM CRS_PASSENGER
                WHERE phone = TRIM(p_search_value);

            WHEN 'ID' THEN
                SELECT passenger_id INTO v_passenger_id
                FROM CRS_PASSENGER
                WHERE passenger_id = TO_NUMBER(TRIM(p_search_value));
        END CASE;

        RETURN v_passenger_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;

        WHEN VALUE_ERROR THEN
            RETURN NULL;

        WHEN TOO_MANY_ROWS THEN
            RETURN NULL;

        WHEN OTHERS THEN
            RETURN NULL;
    END search_passenger;


END PKG_PASSENGER;
/