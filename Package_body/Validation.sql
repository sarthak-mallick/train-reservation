CREATE OR REPLACE PACKAGE BODY PKG_VALIDATION AS

/* ============================================================
   VALIDATE BOOKING REQUEST
   ============================================================ */
FUNCTION validate_booking_request(
    p_train_id IN NUMBER,
    p_passenger_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2,
    p_booking_date IN DATE DEFAULT SYSDATE
) RETURN VARCHAR2 AS
    v_train_count       NUMBER;
    v_passenger_count   NUMBER;
    v_day_of_week       VARCHAR2(10);
    v_sched_count       NUMBER;
    v_duplicate_count   NUMBER;
BEGIN
    --------------------------------------------------------------------
    -- 1. Check if train exists
    --------------------------------------------------------------------
    SELECT COUNT(*) INTO v_train_count
    FROM CRS_TRAIN_INFO
    WHERE train_id = p_train_id;

    IF v_train_count = 0 THEN
        RETURN 'Train does not exist.';
    END IF;

    --------------------------------------------------------------------
    -- 2. Check if passenger exists
    --------------------------------------------------------------------
    SELECT COUNT(*) INTO v_passenger_count
    FROM CRS_PASSENGER
    WHERE passenger_id = p_passenger_id;

    IF v_passenger_count = 0 THEN
        RETURN 'Passenger does not exist.';
    END IF;

    --------------------------------------------------------------------
    -- 3. Validate seat class
    --------------------------------------------------------------------
    IF p_seat_class NOT IN ('FC', 'ECON') THEN
        RETURN 'Invalid seat class.';
    END IF;

    --------------------------------------------------------------------
    -- 4. Check if travel date is in future
    --------------------------------------------------------------------
    IF TRUNC(p_travel_date) < TRUNC(p_booking_date) THEN
        RETURN 'Travel date must be in the future.';
    END IF;

    --------------------------------------------------------------------
    -- 5. Travel date within 7-day booking window
    --------------------------------------------------------------------
    IF TRUNC(p_travel_date) > TRUNC(p_booking_date) + C_ADVANCE_BOOKING_DAYS THEN
        RETURN 'Travel date exceeds 7-day booking window.';
    END IF;

    --------------------------------------------------------------------
    -- 6. Check train runs on the travel day
    --------------------------------------------------------------------
    IF NOT is_train_operating(p_train_id, p_travel_date) THEN
        RETURN 'Train does not operate on this day.';
    END IF;

    --------------------------------------------------------------------
    -- 7: Check for duplicate booking
    --------------------------------------------------------------------
    SELECT COUNT(*) INTO v_duplicate_count
    FROM CRS_RESERVATION
    WHERE passenger_id = p_passenger_id
      AND train_id = p_train_id
      AND travel_date = p_travel_date
      AND seat_status IN ('CONFIRMED', 'WAITLISTED');
    
    IF v_duplicate_count > 0 THEN
        RETURN 'Passenger already has a booking for this train and date.';
    END IF;

    RETURN 'OK';

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END validate_booking_request;


/* ============================================================
   VALIDATE CANCELLATION
   ============================================================ */
FUNCTION validate_cancellation(
    p_booking_id IN NUMBER
) RETURN VARCHAR2 AS
    v_seat_status   VARCHAR2(20);
    v_travel_date   DATE;
BEGIN
    --------------------------------------------------------------------
    -- 1. Check if booking exists
    --------------------------------------------------------------------
    SELECT seat_status, travel_date INTO v_seat_status, v_travel_date
    FROM CRS_RESERVATION
    WHERE booking_id = p_booking_id;

    --------------------------------------------------------------------
    -- 2. Check if already cancelled
    --------------------------------------------------------------------
    IF v_seat_status = 'CANCELLED' THEN
        RETURN 'Booking already cancelled.';
    END IF;

    --------------------------------------------------------------------
    -- 3: Check cancellation deadline
    --------------------------------------------------------------------
    IF TRUNC(v_travel_date) = TRUNC(SYSDATE) THEN
        RETURN 'Cannot cancel on the day of travel.';
    END IF;

    RETURN 'OK';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Booking does not exist.';
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END validate_cancellation;


/* ============================================================
   CHECK SEAT AVAILABILITY
   ============================================================ */
FUNCTION check_seat_availability(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN VARCHAR2 AS
    v_available_seats NUMBER;
    v_waitlist NUMBER;
BEGIN
    v_available_seats := get_available_seats(p_train_id, p_travel_date, p_seat_class);

    IF v_available_seats > 0 THEN
        RETURN 'AVAILABLE';
    END IF;

    v_waitlist := get_waitlist_count(p_train_id, p_travel_date, p_seat_class);

    IF v_waitlist < C_MAX_WAITLIST_PER_CLASS THEN
        RETURN 'WAITLIST_AVAILABLE';
    ELSE
        RETURN 'FULL';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'FULL';
END check_seat_availability;


/* ============================================================
   GET AVAILABLE SEATS
   ============================================================ */
FUNCTION get_available_seats(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN NUMBER AS
    v_total_seats NUMBER;
    v_confirmed NUMBER;
BEGIN
    --------------------------------------------------------------------
    -- 1. Get total seats from train master
    --------------------------------------------------------------------
    IF p_seat_class = 'FC' THEN
        SELECT total_fc_seats INTO v_total_seats
        FROM CRS_TRAIN_INFO WHERE train_id = p_train_id;
    ELSE
        SELECT total_econ_seats INTO v_total_seats
        FROM CRS_TRAIN_INFO WHERE train_id = p_train_id;
    END IF;

    --------------------------------------------------------------------
    -- 2. Count confirmed seats
    --------------------------------------------------------------------
    SELECT COUNT(*) INTO v_confirmed
    FROM CRS_RESERVATION
    WHERE train_id = p_train_id
      AND travel_date = p_travel_date
      AND seat_class = p_seat_class
      AND seat_status = 'CONFIRMED';

    RETURN v_total_seats - v_confirmed;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END get_available_seats;


/* ============================================================
   GET WAITLIST COUNT
   ============================================================ */
FUNCTION get_waitlist_count(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN NUMBER AS
    v_wait NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_wait
    FROM CRS_RESERVATION
    WHERE train_id = p_train_id
      AND travel_date = p_travel_date
      AND seat_class = p_seat_class
      AND seat_status = 'WAITLISTED';

    RETURN v_wait;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END get_waitlist_count;


/* ============================================================
   GET NEXT WAITLIST POSITION
   ============================================================ */
FUNCTION get_next_waitlist_position(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN NUMBER AS
    v_max_position NUMBER;
BEGIN
    SELECT NVL(MAX(waitlist_position), 0) + 1
    INTO v_max_position
    FROM CRS_RESERVATION
    WHERE train_id = p_train_id
      AND travel_date = p_travel_date
      AND seat_class = p_seat_class
      AND seat_status = 'WAITLISTED';

    RETURN v_max_position;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 1;
END get_next_waitlist_position;

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
      AND UPPER(ds.day_of_week) = UPPER(v_day)
      AND ts.is_in_service = 'Y';

    RETURN (v_count > 0);

EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END is_train_operating;

END PKG_VALIDATION;
/
