-- Package Body: PKG_VALIDATION
-- Purpose: Implementation of validation logic for business rules
-- Owner: CRS_ADMIN

CREATE OR REPLACE PACKAGE BODY PKG_VALIDATION AS

/**
    * Comprehensive validation for booking request
    */
FUNCTION validate_booking_request(
    p_train_id IN NUMBER,
    p_passenger_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2,
    p_booking_date IN DATE DEFAULT SYSDATE
) RETURN VARCHAR2 AS
    v_train_count NUMBER;
    v_passenger_count NUMBER;
    v_day_of_week VARCHAR2(10);
    v_schedule_count NUMBER;
BEGIN
    -- TODO: Implement comprehensive validation
    -- 1. Check if train exists
    -- 2. Check if passenger exists
    -- 3. Check if seat class is valid (FC or ECON)
    -- 4. Check if travel date is in the future
    -- 5. Check if travel date is within booking window (7 days)
    -- 6. Check if train operates on that day
    -- 7. Return 'OK' if all validations pass, error message otherwise
    
    RETURN 'OK'; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END validate_booking_request;

/**
    * Validate cancellation request
    */
FUNCTION validate_cancellation(
    p_booking_id IN NUMBER
) RETURN VARCHAR2 AS
    v_booking_count NUMBER;
    v_seat_status VARCHAR2(20);
BEGIN
    -- TODO: Implement cancellation validation
    -- 1. Check if booking exists
    -- 2. Check if booking is not already CANCELLED
    -- 3. Return 'OK' if valid, error message otherwise
    
    RETURN 'OK'; -- Placeholder
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Booking does not exist.';
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END validate_cancellation;

/**
    * Check seat availability status
    */
FUNCTION check_seat_availability(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN VARCHAR2 AS
    v_available_seats NUMBER;
    v_waitlist_count NUMBER;
BEGIN
    -- TODO: Implement availability check
    -- 1. Get available seats using get_available_seats
    -- 2. If available_seats > 0, return 'AVAILABLE'
    -- 3. Get waitlist count using get_waitlist_count
    -- 4. If waitlist < C_MAX_WAITLIST_PER_CLASS, return 'WAITLIST_AVAILABLE'
    -- 5. Otherwise return 'FULL'
    
    RETURN 'AVAILABLE'; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'FULL';
END check_seat_availability;

/**
    * Get available seat count
    */
FUNCTION get_available_seats(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN NUMBER AS
    v_total_seats NUMBER;
    v_confirmed_count NUMBER;
BEGIN
    -- TODO: Implement get available seats
    -- 1. Get total seats for the class from CRS_TRAIN_INFO
    --    (total_fc_seats or total_econ_seats based on p_seat_class)
    -- 2. Count CONFIRMED bookings for this train/date/class
    -- 3. Return (total_seats - confirmed_count)
    
    RETURN 0; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END get_available_seats;

/**
    * Get current waitlist count
    */
FUNCTION get_waitlist_count(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN NUMBER AS
    v_waitlist_count NUMBER;
BEGIN
    -- TODO: Implement get waitlist count
    -- 1. COUNT bookings WHERE:
    --    train_id = p_train_id
    --    travel_date = p_travel_date
    --    seat_class = p_seat_class
    --    seat_status = 'WAITLISTED'
    -- 2. Return count
    
    RETURN 0; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END get_waitlist_count;

/**
    * Get next available waitlist position
    */
FUNCTION get_next_waitlist_position(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN NUMBER AS
    v_max_position NUMBER;
BEGIN
    -- TODO: Implement get next waitlist position
    -- 1. SELECT NVL(MAX(waitlist_position), 0) + 1
    --    FROM CRS_RESERVATION
    --    WHERE train_id = p_train_id
    --    AND travel_date = p_travel_date
    --    AND seat_class = p_seat_class
    --    AND seat_status = 'WAITLISTED'
    -- 2. Return next position
    
    RETURN 1; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        RETURN 1;
END get_next_waitlist_position;

END PKG_VALIDATION;
/