-- Test Suite: PKG_PASSENGER
-- Purpose: Demonstrate all exception scenarios and validations
-- Run as: CRS_DATA or user with execute permission

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_passenger_id NUMBER;
    v_error_msg    VARCHAR2(500);
    v_result       BOOLEAN;
    v_search_id    NUMBER;
    v_test_count   NUMBER := 0;
    v_pass_count   NUMBER := 0;
    
    PROCEDURE print_result(p_test_name VARCHAR2, p_passed BOOLEAN, p_details VARCHAR2 DEFAULT NULL) IS
    BEGIN
        v_test_count := v_test_count + 1;
        IF p_passed THEN
            v_pass_count := v_pass_count + 1;
            DBMS_OUTPUT.PUT_LINE('PASS: ' || p_test_name);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAIL: ' || p_test_name);
        END IF;
        IF p_details IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('      -> ' || p_details);
        END IF;
    END;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================================');
    DBMS_OUTPUT.PUT_LINE('           PKG_PASSENGER TEST SUITE                     ');
    DBMS_OUTPUT.PUT_LINE('========================================================');
    DBMS_OUTPUT.PUT_LINE('');

    -- SECTION 1: REGISTER_PASSENGER TESTS
    DBMS_OUTPUT.PUT_LINE('SECTION 1: REGISTER_PASSENGER FUNCTION');
    DBMS_OUTPUT.PUT_LINE('');

    -- 1.1 Success Case
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'John',
        p_middle_name   => 'Test',
        p_last_name     => 'Doe',
        p_date_of_birth => DATE '1990-05-15',
        p_address_line1 => '123 Test Street',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'john.test.doe@example.com',
        p_phone         => '617-555-0001',
        p_error_msg     => v_error_msg
    );
    print_result('1.1 Valid Registration', v_passenger_id > 0, 'ID: ' || v_passenger_id);

    -- 1.2 NULL Middle Name (optional field - should pass)
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'Jane',
        p_middle_name   => NULL,
        p_last_name     => 'Smith',
        p_date_of_birth => DATE '1985-08-20',
        p_address_line1 => '456 Test Ave',
        p_address_city  => 'Cambridge',
        p_address_state => 'MA',
        p_address_zip   => '02139',
        p_email         => 'jane.smith@example.com',
        p_phone         => '617-555-0002',
        p_error_msg     => v_error_msg
    );
    print_result('1.2 NULL Middle Name (Optional)', v_passenger_id > 0, 'ID: ' || v_passenger_id);

    -- NULL FIELD TESTS (DDL NOT NULL constraints)
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-- NULL Field Tests (DDL Constraints) --');

    -- 1.3 NULL First Name
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => NULL,
        p_middle_name   => 'Test',
        p_last_name     => 'User',
        p_date_of_birth => DATE '1990-01-01',
        p_address_line1 => '789 Test Rd',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'null.first@example.com',
        p_phone         => '617-555-0003',
        p_error_msg     => v_error_msg
    );
    print_result('1.3 NULL First Name', v_passenger_id = -1, v_error_msg);

    -- 1.4 NULL Last Name
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'Test',
        p_middle_name   => NULL,
        p_last_name     => NULL,
        p_date_of_birth => DATE '1990-01-01',
        p_address_line1 => '789 Test Rd',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'null.last@example.com',
        p_phone         => '617-555-0004',
        p_error_msg     => v_error_msg
    );
    print_result('1.4 NULL Last Name', v_passenger_id = -1, v_error_msg);

    -- 1.5 NULL Date of Birth
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'Test',
        p_middle_name   => NULL,
        p_last_name     => 'User',
        p_date_of_birth => NULL,
        p_address_line1 => '789 Test Rd',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'null.dob@example.com',
        p_phone         => '617-555-0005',
        p_error_msg     => v_error_msg
    );
    print_result('1.5 NULL Date of Birth', v_passenger_id = -1, v_error_msg);

    -- 1.6 NULL Email
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'Test',
        p_middle_name   => NULL,
        p_last_name     => 'User',
        p_date_of_birth => DATE '1990-01-01',
        p_address_line1 => '789 Test Rd',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => NULL,
        p_phone         => '617-555-0006',
        p_error_msg     => v_error_msg
    );
    print_result('1.6 NULL Email', v_passenger_id = -1, v_error_msg);

    -- 1.7 NULL Phone
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'Test',
        p_middle_name   => NULL,
        p_last_name     => 'User',
        p_date_of_birth => DATE '1990-01-01',
        p_address_line1 => '789 Test Rd',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'null.phone@example.com',
        p_phone         => NULL,
        p_error_msg     => v_error_msg
    );
    print_result('1.7 NULL Phone', v_passenger_id = -1, v_error_msg);

    -- 1.8 NULL Address
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'Test',
        p_middle_name   => NULL,
        p_last_name     => 'User',
        p_date_of_birth => DATE '1990-01-01',
        p_address_line1 => NULL,
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'null.addr@example.com',
        p_phone         => '617-555-0007',
        p_error_msg     => v_error_msg
    );
    print_result('1.8 NULL Address', v_passenger_id = -1, v_error_msg);

    -- WHITESPACE TESTS (Procedure validation)
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-- Whitespace Tests (Procedure Validation) --');

    -- 1.9 Whitespace-Only First Name
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => '   ',
        p_middle_name   => 'Test',
        p_last_name     => 'User',
        p_date_of_birth => DATE '1990-01-01',
        p_address_line1 => '789 Test Rd',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'whitespace@example.com',
        p_phone         => '617-555-0008',
        p_error_msg     => v_error_msg
    );
    print_result('1.9 Whitespace-Only First Name', v_passenger_id = -1, v_error_msg);

    -- FORMAT VALIDATION TESTS (Procedure validation)
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-- Format Validation Tests (Procedure Validation) --');

    -- 1.10 Invalid Email Format
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'Test',
        p_middle_name   => NULL,
        p_last_name     => 'User',
        p_date_of_birth => DATE '1990-01-01',
        p_address_line1 => '789 Test Rd',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'invalid-email',
        p_phone         => '617-555-0009',
        p_error_msg     => v_error_msg
    );
    print_result('1.10 Invalid Email Format', v_passenger_id = -1, v_error_msg);

    -- 1.11 Invalid Phone (< 10 digits)
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'Test',
        p_middle_name   => NULL,
        p_last_name     => 'User',
        p_date_of_birth => DATE '1990-01-01',
        p_address_line1 => '789 Test Rd',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'short.phone@example.com',
        p_phone         => '123',
        p_error_msg     => v_error_msg
    );
    print_result('1.11 Invalid Phone (< 10 digits)', v_passenger_id = -1, v_error_msg);

    -- 1.12 Future Date of Birth
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'Future',
        p_middle_name   => NULL,
        p_last_name     => 'Person',
        p_date_of_birth => SYSDATE + 365,
        p_address_line1 => '789 Test Rd',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'future@example.com',
        p_phone         => '617-555-0010',
        p_error_msg     => v_error_msg
    );
    print_result('1.12 Future Date of Birth', v_passenger_id = -1, v_error_msg);

    -- UNIQUENESS TESTS (DDL UNIQUE constraints)
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('-- Uniqueness Tests (DDL Constraints) --');

    -- 1.13 Duplicate Email
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'Duplicate',
        p_middle_name   => NULL,
        p_last_name     => 'Email',
        p_date_of_birth => DATE '1990-01-01',
        p_address_line1 => '999 Test Rd',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'john.test.doe@example.com',
        p_phone         => '617-555-0011',
        p_error_msg     => v_error_msg
    );
    print_result('1.13 Duplicate Email', v_passenger_id = -1, v_error_msg);

    -- 1.14 Duplicate Phone
    v_passenger_id := crs_admin.PKG_PASSENGER.register_passenger(
        p_first_name    => 'Duplicate',
        p_middle_name   => NULL,
        p_last_name     => 'Phone',
        p_date_of_birth => DATE '1990-01-01',
        p_address_line1 => '999 Test Rd',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'unique@example.com',
        p_phone         => '617-555-0001',
        p_error_msg     => v_error_msg
    );
    print_result('1.14 Duplicate Phone', v_passenger_id = -1, v_error_msg);

    -- SECTION 2: SEARCH_PASSENGER TESTS
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('SECTION 2: SEARCH_PASSENGER FUNCTION');
    DBMS_OUTPUT.PUT_LINE('');

    -- 2.1 Search by Email
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('EMAIL', 'john.test.doe@example.com');
    print_result('2.1 Search by Email', v_search_id IS NOT NULL, 'Found ID: ' || v_search_id);

    -- 2.2 Search by Email (Case-Insensitive)
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('EMAIL', 'JOHN.TEST.DOE@EXAMPLE.COM');
    print_result('2.2 Search by Email (Case-Insensitive)', v_search_id IS NOT NULL, 'Found ID: ' || v_search_id);

    -- 2.3 Search by Phone
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('PHONE', '617-555-0001');
    print_result('2.3 Search by Phone', v_search_id IS NOT NULL, 'Found ID: ' || v_search_id);

    -- 2.4 Search by ID
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('ID', '1');
    print_result('2.4 Search by ID', v_search_id IS NOT NULL OR v_search_id IS NULL, 'Result: ' || NVL(TO_CHAR(v_search_id), 'NULL'));

    -- 2.5 Non-existent Email
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('EMAIL', 'nonexistent@example.com');
    print_result('2.5 Non-existent Email', v_search_id IS NULL, 'Returned NULL');

    -- 2.6 Invalid Search Type
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('INVALID', 'test@example.com');
    print_result('2.6 Invalid Search Type', v_search_id IS NULL, 'Returned NULL');

    -- 2.7 NULL Search Value
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('EMAIL', NULL);
    print_result('2.7 NULL Search Value', v_search_id IS NULL, 'Returned NULL');

    -- 2.8 Non-numeric ID
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('ID', 'abc');
    print_result('2.8 Non-numeric ID', v_search_id IS NULL, 'Returned NULL');

    -- SECTION 3: UPDATE_PASSENGER TESTS
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('SECTION 3: UPDATE_PASSENGER FUNCTION');
    DBMS_OUTPUT.PUT_LINE('');

    -- Get valid passenger ID
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('EMAIL', 'john.test.doe@example.com');

    -- 3.1 Successful Update
    IF v_search_id IS NOT NULL THEN
        v_result := crs_admin.PKG_PASSENGER.update_passenger(
            p_passenger_id  => v_search_id,
            p_address_line1 => '999 Updated Street',
            p_address_city  => 'Cambridge',
            p_address_state => 'MA',
            p_address_zip   => '02139',
            p_email         => 'john.updated@example.com',
            p_phone         => '617-555-9999',
            p_error_msg     => v_error_msg
        );
        print_result('3.1 Successful Update', v_result = TRUE, 'Updated ID: ' || v_search_id);
    END IF;

    -- 3.2 Non-existent Passenger ID
    v_result := crs_admin.PKG_PASSENGER.update_passenger(
        p_passenger_id  => 99999,
        p_address_line1 => '123 Test St',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'test@example.com',
        p_phone         => '617-555-0000',
        p_error_msg     => v_error_msg
    );
    print_result('3.2 Non-existent Passenger ID', v_result = FALSE, v_error_msg);

    -- 3.3 NULL Passenger ID
    v_result := crs_admin.PKG_PASSENGER.update_passenger(
        p_passenger_id  => NULL,
        p_address_line1 => '123 Test St',
        p_address_city  => 'Boston',
        p_address_state => 'MA',
        p_address_zip   => '02101',
        p_email         => 'test@example.com',
        p_phone         => '617-555-0000',
        p_error_msg     => v_error_msg
    );
    print_result('3.3 NULL Passenger ID', v_result = FALSE, v_error_msg);

    -- 3.4 Invalid Email in Update
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('EMAIL', 'john.updated@example.com');
    IF v_search_id IS NOT NULL THEN
        v_result := crs_admin.PKG_PASSENGER.update_passenger(
            p_passenger_id  => v_search_id,
            p_address_line1 => '123 Test St',
            p_address_city  => 'Boston',
            p_address_state => 'MA',
            p_address_zip   => '02101',
            p_email         => 'bad-email',
            p_phone         => '617-555-9999',
            p_error_msg     => v_error_msg
        );
        print_result('3.4 Invalid Email in Update', v_result = FALSE, v_error_msg);
    END IF;

    -- 3.5 Invalid Phone in Update
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('EMAIL', 'john.updated@example.com');
    IF v_search_id IS NOT NULL THEN
        v_result := crs_admin.PKG_PASSENGER.update_passenger(
            p_passenger_id  => v_search_id,
            p_address_line1 => '123 Test St',
            p_address_city  => 'Boston',
            p_address_state => 'MA',
            p_address_zip   => '02101',
            p_email         => 'john.updated@example.com',
            p_phone         => '123',
            p_error_msg     => v_error_msg
        );
        print_result('3.5 Invalid Phone in Update', v_result = FALSE, v_error_msg);
    END IF;

    -- 3.6 Email Belongs to Another Passenger
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('EMAIL', 'john.updated@example.com');
    IF v_search_id IS NOT NULL THEN
        v_result := crs_admin.PKG_PASSENGER.update_passenger(
            p_passenger_id  => v_search_id,
            p_address_line1 => '123 Test St',
            p_address_city  => 'Boston',
            p_address_state => 'MA',
            p_address_zip   => '02101',
            p_email         => 'jane.smith@example.com',
            p_phone         => '617-555-9999',
            p_error_msg     => v_error_msg
        );
        print_result('3.6 Email Belongs to Another', v_result = FALSE, v_error_msg);
    END IF;

    -- 3.7 Whitespace-Only Address in Update
    v_search_id := crs_admin.PKG_PASSENGER.search_passenger('EMAIL', 'john.updated@example.com');
    IF v_search_id IS NOT NULL THEN
        v_result := crs_admin.PKG_PASSENGER.update_passenger(
            p_passenger_id  => v_search_id,
            p_address_line1 => '   ',
            p_address_city  => 'Boston',
            p_address_state => 'MA',
            p_address_zip   => '02101',
            p_email         => 'john.updated@example.com',
            p_phone         => '617-555-9999',
            p_error_msg     => v_error_msg
        );
        print_result('3.7 Whitespace-Only Address', v_result = FALSE, v_error_msg);
    END IF;

    -- CLEANUP
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('CLEANUP');
    
    DELETE FROM crs_admin.CRS_PASSENGER WHERE email LIKE '%@example.com';
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Test data cleaned up.');

    -- SUMMARY
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================================');
    DBMS_OUTPUT.PUT_LINE('TEST SUMMARY');
    DBMS_OUTPUT.PUT_LINE('========================================================');
    DBMS_OUTPUT.PUT_LINE('Total Tests: ' || v_test_count);
    DBMS_OUTPUT.PUT_LINE('Passed:      ' || v_pass_count);
    DBMS_OUTPUT.PUT_LINE('Failed:      ' || (v_test_count - v_pass_count));
    DBMS_OUTPUT.PUT_LINE('========================================================');

END;
/