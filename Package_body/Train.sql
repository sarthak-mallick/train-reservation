CREATE OR REPLACE PACKAGE BODY PKG_TRAIN AS

/*******************************************************************
 *  ADD TRAIN
 *******************************************************************/
FUNCTION add_train(
    p_train_number IN VARCHAR2,
    p_source_station IN VARCHAR2,
    p_dest_station IN VARCHAR2,
    p_total_fc_seats IN NUMBER,
    p_total_econ_seats IN NUMBER,
    p_fc_seat_fare IN NUMBER,
    p_econ_seat_fare IN NUMBER,
    p_error_msg OUT VARCHAR2
) RETURN NUMBER AS
    v_train_id NUMBER;
BEGIN
    -- Basic validations
    IF p_train_number IS NULL OR
       p_source_station IS NULL OR
       p_dest_station IS NULL THEN
        p_error_msg := 'Required fields missing.';
        RETURN -1;
    END IF;

    IF p_source_station = p_dest_station THEN
        p_error_msg := 'Source and destination cannot be same.';
        RETURN -1;
    END IF;

    IF p_total_fc_seats <= 0 OR p_total_econ_seats <= 0 THEN
        p_error_msg := 'Seat counts must be greater than zero.';
        RETURN -1;
    END IF;

    IF p_fc_seat_fare <= 0 OR p_econ_seat_fare <= 0 THEN
        p_error_msg := 'Fares must be greater than zero.';
        RETURN -1;
    END IF;

    -- Insert train
    INSERT INTO CRS_TRAIN_INFO (
        train_number, source_station, dest_station,
        total_fc_seats, total_econ_seats,
        fc_seat_fare, econ_seat_fare
    )
    VALUES (
        p_train_number, p_source_station, p_dest_station,
        p_total_fc_seats, p_total_econ_seats,
        p_fc_seat_fare, p_econ_seat_fare
    )
    RETURNING train_id INTO v_train_id;

    COMMIT;
    p_error_msg := NULL;
    RETURN v_train_id;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        p_error_msg := 'Train number already exists.';
        RETURN -1;
    WHEN OTHERS THEN
        ROLLBACK;
        p_error_msg := SQLERRM;
        RETURN -1;
END add_train;


/******************************************************************
 *  UPDATE TRAIN (FARES ONLY)
 ******************************************************************/
FUNCTION update_train(
    p_train_id IN NUMBER,
    p_fc_seat_fare IN NUMBER,
    p_econ_seat_fare IN NUMBER,
    p_error_msg OUT VARCHAR2
) RETURN BOOLEAN AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM CRS_TRAIN_INFO
    WHERE train_id = p_train_id;

    IF v_count = 0 THEN
        p_error_msg := 'Train does not exist.';
        RETURN FALSE;
    END IF;

    IF p_fc_seat_fare <= 0 OR p_econ_seat_fare <= 0 THEN
        p_error_msg := 'Fares must be > 0.';
        RETURN FALSE;
    END IF;

    UPDATE CRS_TRAIN_INFO
    SET fc_seat_fare = p_fc_seat_fare,
        econ_seat_fare = p_econ_seat_fare
    WHERE train_id = p_train_id;

    COMMIT;
    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_error_msg := SQLERRM;
        RETURN FALSE;
END update_train;


/******************************************************************
 *  CANCEL TRAIN ON SPECIFIC DATE
 ******************************************************************/
PROCEDURE cancel_train_on_date(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_reason IN VARCHAR2,
    p_bookings_cancelled OUT NUMBER,
    p_success OUT BOOLEAN,
    p_message OUT VARCHAR2
) AS
    v_exists NUMBER;
BEGIN
    p_success := FALSE;

    -- Check train exists
    SELECT COUNT(*) INTO v_exists
    FROM CRS_TRAIN_INFO
    WHERE train_id = p_train_id;

    IF v_exists = 0 THEN
        p_message := 'Train does not exist.';
        RETURN;
    END IF;

    -- Cancel bookings
    UPDATE CRS_RESERVATION
    SET seat_status = 'CANCELLED'
    WHERE train_id = p_train_id
      AND travel_date = p_travel_date
      AND seat_status <> 'CANCELLED';

    p_bookings_cancelled := SQL%ROWCOUNT;
    COMMIT;
    p_success := TRUE;
    p_message := 'Train cancelled successfully.';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_success := FALSE;
        p_message := SQLERRM;
END cancel_train_on_date;


/******************************************************************
 *  DEACTIVATE TRAIN (SOFT DELETE)
 ******************************************************************/
PROCEDURE deactivate_train(
    p_train_id IN NUMBER,
    p_success OUT BOOLEAN,
    p_error_msg OUT VARCHAR2
) AS
    v_exists NUMBER;
BEGIN
    p_success := FALSE;

    SELECT COUNT(*) INTO v_exists
    FROM CRS_TRAIN_INFO
    WHERE train_id = p_train_id;

    IF v_exists = 0 THEN
        p_error_msg := 'Train does not exist.';
        RETURN;
    END IF;

    UPDATE CRS_TRAIN_SCHEDULE
    SET is_in_service = 'N'
    WHERE train_id = p_train_id;

    COMMIT;
    p_success := TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_error_msg := SQLERRM;
        p_success := FALSE;
END deactivate_train;


/******************************************************************
 *  SEARCH TRAIN BY TRAIN NUMBER
 ******************************************************************/
FUNCTION search_train_by_number(
    p_train_number IN VARCHAR2
) RETURN NUMBER AS
    v_train_id NUMBER;
BEGIN
    SELECT train_id INTO v_train_id
    FROM CRS_TRAIN_INFO
    WHERE train_number = p_train_number;

    RETURN v_train_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END search_train_by_number;


/******************************************************************
 *  ADD TRAIN TO SCHEDULE (DAY OF WEEK)
 ******************************************************************/
PROCEDURE add_train_to_schedule(
    p_train_id IN NUMBER,
    p_sch_id IN NUMBER,
    p_success OUT BOOLEAN,
    p_error_msg OUT VARCHAR2
) AS
    v_train_count NUMBER;
    v_sch_count NUMBER;
    v_exists NUMBER;
BEGIN
    p_success := FALSE;

    SELECT COUNT(*) INTO v_train_count
    FROM CRS_TRAIN_INFO
    WHERE train_id = p_train_id;

    SELECT COUNT(*) INTO v_sch_count
    FROM CRS_DAY_SCHEDULE
    WHERE sch_id = p_sch_id;

    IF v_train_count = 0 THEN
        p_error_msg := 'Train does not exist.';
        RETURN;
    END IF;

    IF v_sch_count = 0 THEN
        p_error_msg := 'Schedule ID does not exist.';
        RETURN;
    END IF;

    -- Check if already exists
    SELECT COUNT(*) INTO v_exists
    FROM CRS_TRAIN_SCHEDULE
    WHERE train_id = p_train_id AND sch_id = p_sch_id;

    IF v_exists > 0 THEN
        p_error_msg := 'Train already added to this schedule.';
        RETURN;
    END IF;

    INSERT INTO CRS_TRAIN_SCHEDULE(train_id, sch_id, is_in_service)
    VALUES (p_train_id, p_sch_id, 'Y');

    COMMIT;
    p_success := TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_error_msg := SQLERRM;
        p_success := FALSE;
END add_train_to_schedule;


/******************************************************************
 *  REMOVE TRAIN FROM SCHEDULE
 ******************************************************************/
PROCEDURE remove_train_from_schedule(
    p_train_id IN NUMBER,
    p_sch_id IN NUMBER,
    p_success OUT BOOLEAN,
    p_error_msg OUT VARCHAR2
) AS
BEGIN
    DELETE FROM CRS_TRAIN_SCHEDULE
    WHERE train_id = p_train_id
      AND sch_id = p_sch_id;

    IF SQL%ROWCOUNT = 0 THEN
        p_error_msg := 'Train not found in schedule.';
        p_success := FALSE;
        RETURN;
    END IF;

    COMMIT;
    p_success := TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_error_msg := SQLERRM;
        p_success := FALSE;
END remove_train_from_schedule;


/******************************************************************
 *  CHECK TRAIN OPERATING ON DATE
 ******************************************************************/
FUNCTION is_train_operating(
    p_train_id IN NUMBER,
    p_travel_date IN DATE
) RETURN BOOLEAN AS
    v_count NUMBER;
    v_day VARCHAR2(10);
BEGIN
    v_day := TRIM(TO_CHAR(p_travel_date, 'DAY'));

    SELECT COUNT(*) INTO v_count
    FROM CRS_TRAIN_SCHEDULE ts
    JOIN CRS_DAY_SCHEDULE ds ON ts.sch_id = ds.sch_id
    WHERE ts.train_id = p_train_id
      AND ds.day_of_week = v_day
      AND ts.is_in_service = 'Y';

    RETURN (v_count > 0);

EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END is_train_operating;

END PKG_TRAIN;
/
