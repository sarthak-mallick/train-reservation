 -- ======================================================================
-- Test Suite: PKG_TRAIN
-- Purpose : Demonstrate all features, validations, and exception scenarios
-- Module  : Train Management (Add Train, Update Fare, Scheduling, Cancellation)
-- Package : PKG_TRAIN
-- ======================================================================

 
    -- TEST 1 — add_train() 

-- Test Case 1A — Valid train

DECLARE
  v_err VARCHAR2(200);
  v_id NUMBER;
BEGIN
  v_id := PKG_TRAIN.add_train(
    p_train_number => 'A101',
    p_source_station => 'CHENNAI',
    p_dest_station => 'BANGALORE',
    p_total_fc_seats => 10,
    p_total_econ_seats => 20,
    p_fc_seat_fare => 1000,
    p_econ_seat_fare => 500,
    p_error_msg => v_err
  );

  DBMS_OUTPUT.PUT_LINE('Train ID: ' || v_id);
  DBMS_OUTPUT.PUT_LINE('Message: ' || v_err);
END;
/


-- Test Case 1B — Duplicate Train Number

DECLARE
  v_err VARCHAR2(200);
  v_id NUMBER;
BEGIN
  v_id := PKG_TRAIN.add_train(
    p_train_number => 'A101',
    p_source_station => 'CHENNAI',
    p_dest_station => 'BANGALORE',
    p_total_fc_seats => 10,
    p_total_econ_seats => 20,
    p_fc_seat_fare => 1000,
    p_econ_seat_fare => 500,
    p_error_msg => v_err
  );

  DBMS_OUTPUT.PUT_LINE('Train ID: ' || v_id);
  DBMS_OUTPUT.PUT_LINE('Message: ' || v_err);
END;
/

-- Test Case 3 Checking valid source and destinaiton

DECLARE
  v_err VARCHAR2(200);
  v_id NUMBER;
BEGIN
  v_id := PKG_TRAIN.add_train(
    p_train_number => 'A101',
    p_source_station => 'CHENNAI',
    p_dest_station => 'CHENNAI',
    p_total_fc_seats => 10,
    p_total_econ_seats => 20,
    p_fc_seat_fare => 1000,
    p_econ_seat_fare => 500,
    p_error_msg => v_err
  );

  DBMS_OUTPUT.PUT_LINE('Train ID: ' || v_id);
  DBMS_OUTPUT.PUT_LINE('Message: ' || v_err);
END;
/



    -- TEST 2 — update_fare()

-- Case 2A — Valid update 

DECLARE
  v_msg VARCHAR2(200);
  v_ok  BOOLEAN;
BEGIN
  v_ok := PKG_TRAIN.update_fare(1, 1500, 900, v_msg);

  DBMS_OUTPUT.PUT_LINE('Success: ' ||
                       CASE WHEN v_ok THEN 'TRUE'
                            ELSE 'FALSE'
                       END);

  DBMS_OUTPUT.PUT_LINE('Msg: ' || v_msg);
END;
/

-- Case 2B — Train does not exist

DECLARE
  v_msg VARCHAR2(200);
  v_ok BOOLEAN;
BEGIN
  v_ok := PKG_TRAIN.update_fare(9999, 1500, 900, v_msg);
  DBMS_OUTPUT.PUT_LINE(v_msg);
END;
/


    -- TEST 3 — add_train_to_schedule()

-- Case 3A — Valid add

DECLARE
  v_msg VARCHAR2(200);
  v_ok  BOOLEAN;
BEGIN
  PKG_TRAIN.add_train_to_schedule(1, 1, v_ok, v_msg);

  DBMS_OUTPUT.PUT_LINE(
    'Success: ' || CASE WHEN v_ok THEN 'TRUE' ELSE 'FALSE' END ||
    ', Msg: ' || v_msg
  );
END;
/


-- Case 3B — Duplicate add

DECLARE
  v_msg VARCHAR2(200);
  v_ok  BOOLEAN;
BEGIN
  PKG_TRAIN.add_train_to_schedule(1, 1, v_ok, v_msg);

  DBMS_OUTPUT.PUT_LINE(
    'Success: ' || CASE WHEN v_ok THEN 'TRUE' ELSE 'FALSE' END ||
    ', Msg: ' || v_msg
  );
END;
/

-- Test Case 3C — Schedule does not exist --

DECLARE
  v_msg VARCHAR2(200);
  v_ok  BOOLEAN;
BEGIN
  PKG_TRAIN.add_train_to_schedule(1, 999, v_ok, v_msg);

  DBMS_OUTPUT.PUT_LINE('Success: ' || CASE WHEN v_ok THEN 'TRUE' ELSE 'FALSE' END);
  DBMS_OUTPUT.PUT_LINE('Msg: ' || v_msg);
END;
/

-- TEST 4 — cancel_train_on_date()

DECLARE
  v_cnt NUMBER;
  v_ok  BOOLEAN;
  v_msg VARCHAR2(200);
BEGIN
  PKG_TRAIN.cancel_train_on_date(
    p_train_id => 1,
    p_travel_date => DATE '2025-12-10',
    p_reason => 'Maintenance',
    p_bookings_cancelled => v_cnt,
    p_success => v_ok,
    p_message => v_msg
  );

  DBMS_OUTPUT.PUT_LINE(
    'Success: ' || CASE WHEN v_ok THEN 'TRUE' ELSE 'FALSE' END
  );
  DBMS_OUTPUT.PUT_LINE('Cancelled: ' || v_cnt);
  DBMS_OUTPUT.PUT_LINE('Msg: ' || v_msg);
END;
/


-- TEST 5 — remove_train_from_schedule()

DECLARE
  v_msg VARCHAR2(200);
  v_ok  BOOLEAN;
BEGIN
  PKG_TRAIN.remove_train_from_schedule(
    p_train_id => 1,
    p_sch_id => 1,
    p_success => v_ok,
    p_error_msg => v_msg
  );

  DBMS_OUTPUT.PUT_LINE(
    'Success: ' || CASE WHEN v_ok THEN 'TRUE' ELSE 'FALSE' END
  );
  DBMS_OUTPUT.PUT_LINE('Msg: ' || v_msg);
END;
/

    -- TEST 6 — add_train_to_schedule() Negative Cases

-- 6A — Train does not exist

DECLARE
  v_msg VARCHAR2(200);
  v_ok  BOOLEAN;
BEGIN
  PKG_TRAIN.add_train_to_schedule(9999, 1, v_ok, v_msg);
  DBMS_OUTPUT.PUT_LINE('Add Schedule (Invalid Train) → ' || v_msg);
END;
/

-- 6B — Invalid schedule ID

DECLARE
  v_msg VARCHAR2(200);
  v_ok  BOOLEAN;
BEGIN
  PKG_TRAIN.add_train_to_schedule(1, 99, v_ok, v_msg);
  DBMS_OUTPUT.PUT_LINE('Add Schedule (Invalid Sch ID) → ' || v_msg);
END;
/


-- TEST 7 — cancel_train_on_date() Negative Cases

-- 7A — Train does not exist

DECLARE
  v_cnt NUMBER;
  v_ok  BOOLEAN;
  v_msg VARCHAR2(200);
BEGIN
  PKG_TRAIN.cancel_train_on_date(9999, DATE '2025-12-10', 'Test', v_cnt, v_ok, v_msg);
  DBMS_OUTPUT.PUT_LINE('Cancel (Invalid Train) → ' || v_msg);
END;
/


-- 7B — Train not scheduled on that date
DECLARE
  v_cnt NUMBER;
  v_ok  BOOLEAN;
  v_msg VARCHAR2(200);
BEGIN
  PKG_TRAIN.cancel_train_on_date(1, DATE '2030-01-01', 'Test', v_cnt, v_ok, v_msg);
  DBMS_OUTPUT.PUT_LINE('Cancel (Not Scheduled) → ' || v_msg);
END;
/


-- TEST 8 — remove_train_from_schedule() Negative Cases

-- 8A — Schedule ID not found

DECLARE
  v_msg VARCHAR2(200);
  v_ok  BOOLEAN;
BEGIN
  PKG_TRAIN.remove_train_from_schedule(1, 9999, v_ok, v_msg);
  DBMS_OUTPUT.PUT_LINE('Remove Schedule (Invalid Sch ID) → ' || v_msg);
END;
/

-- 8B — Train has active bookings (should fail)

DECLARE
  v_msg VARCHAR2(200);
  v_ok  BOOLEAN;
BEGIN
  PKG_TRAIN.remove_train_from_schedule(1, 1, v_ok, v_msg);
  DBMS_OUTPUT.PUT_LINE('Remove Schedule (Bookings Active) → ' || v_msg);
END;
/



-- TEST 9 — delete_train

-- Test Case 9A — Missing mandatory fields

DECLARE
  v_err VARCHAR2(200);
  v_id NUMBER;
BEGIN
  v_id := PKG_TRAIN.add_train(
    NULL, 'CHENNAI', 'BANGALORE',
    10, 20, 1000, 500,
    v_err
  );

  DBMS_OUTPUT.PUT_LINE('ID: ' || v_id);
  DBMS_OUTPUT.PUT_LINE('Msg: ' || v_err);
END;
/


-- Test Case 9B — Invalid seat counts --

DECLARE
  v_err VARCHAR2(200);
  v_id NUMBER;
BEGIN
  v_id := PKG_TRAIN.add_train(
    'A102', 'CHENNAI', 'BANGALORE',
    0, 20, 1000, 500,
    v_err
  );

  DBMS_OUTPUT.PUT_LINE('ID: ' || v_id);
  DBMS_OUTPUT.PUT_LINE('Msg: ' || v_err);
END;
/

-- Test Case 9C — Invalid fare --

DECLARE
  v_err VARCHAR2(200);
  v_id NUMBER;
BEGIN
  v_id := PKG_TRAIN.add_train(
    'A103', 'CHENNAI', 'BANGALORE',
    10, 20, -100, 500,
    v_err
  );

  DBMS_OUTPUT.PUT_LINE('ID: ' || v_id);
  DBMS_OUTPUT.PUT_LINE('Msg: ' || v_err);
END;
/


    -- 10. Add missing negative cases for update_fare --

-- 10A Invalid new fare --

DECLARE
  v_ok BOOLEAN;
  v_msg VARCHAR2(200);
BEGIN
  v_ok := PKG_TRAIN.update_fare(1, -200, 100, v_msg);

  DBMS_OUTPUT.PUT_LINE('Success: ' || CASE WHEN v_ok THEN 'TRUE' ELSE 'FALSE' END);
  DBMS_OUTPUT.PUT_LINE('Msg: ' || v_msg);
END;
/


-- 11. Add missing cases for cancel_train_on_date --

-- 11A. Train does not exist --

DECLARE
  v_cnt NUMBER;
  v_ok  BOOLEAN;
  v_msg VARCHAR2(200);
BEGIN
  PKG_TRAIN.cancel_train_on_date(
    9999,
    DATE '2025-12-10',
    'Check',
    v_cnt,
    v_ok,
    v_msg
  );

  DBMS_OUTPUT.PUT_LINE('Success: ' ||
                       CASE WHEN v_ok THEN 'TRUE' ELSE 'FALSE' END);

  DBMS_OUTPUT.PUT_LINE('Bookings Cancelled: ' || v_cnt);
  DBMS_OUTPUT.PUT_LINE('Msg: ' || v_msg);
END;
/

-- 11B. Train does NOT operate on that date --

DECLARE
  v_cnt NUMBER;
  v_ok BOOLEAN;
  v_msg VARCHAR2(200);
BEGIN
  PKG_TRAIN.cancel_train_on_date(
    1,
    DATE '2025-12-11',  -- choose wrong weekday
    'Not operating',
    v_cnt,
    v_ok,
    v_msg
  );

  DBMS_OUTPUT.PUT_LINE('Msg: ' || v_msg);
END;
/



    -- 12. Add required tests for remove_train_from_schedule --
    
    
-- 12A. Removing non-existent schedule --

DECLARE
  v_ok  BOOLEAN;
  v_msg VARCHAR2(200);
BEGIN
  PKG_TRAIN.remove_train_from_schedule(1, 999, v_ok, v_msg);

  DBMS_OUTPUT.PUT_LINE(
    'Success: ' || CASE WHEN v_ok THEN 'TRUE' ELSE 'FALSE' END
  );

  DBMS_OUTPUT.PUT_LINE('Msg: ' || v_msg);
END;
/





























