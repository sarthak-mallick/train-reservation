-- Package Body: PKG_BOOKING
-- Purpose: Implementation of core booking operations
-- Owner: CRS_ADMIN

CREATE OR REPLACE PACKAGE BODY PKG_BOOKING AS

/**
    * Book a ticket with all validations
    */
PROCEDURE book_ticket(
    p_passenger_id IN NUMBER,
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2,
    p_booking_id OUT NUMBER,
    p_status OUT VARCHAR2,
    p_waitlist_position OUT NUMBER,
    p_message OUT VARCHAR2
) AS
BEGIN
    -- TODO: Implement booking logic
    -- 1. Validate using PKG_VALIDATION.validate_booking_request
    -- 2. Check availability using PKG_VALIDATION.check_seat_availability
    -- 3. Insert booking as CONFIRMED or WAITLISTED
    -- 4. Set waitlist position if needed
    -- 5. Return booking_id and status
    
    NULL; -- Placeholder
END book_ticket;

/**
    * Cancel a ticket and promote first waitlisted passenger
    */
PROCEDURE cancel_ticket(
    p_booking_id IN NUMBER,
    p_success OUT BOOLEAN,
    p_promoted_booking_id OUT NUMBER,
    p_message OUT VARCHAR2
) AS
BEGIN
    -- TODO: Implement cancellation logic
    -- 1. Validate using PKG_VALIDATION.validate_cancellation
    -- 2. Get booking details (train_id, travel_date, seat_class)
    -- 3. Update booking status to CANCELLED
    -- 4. Find first waitlisted booking (ORDER BY waitlist_position)
    -- 5. Promote to CONFIRMED
    -- 6. Reorder remaining waitlist positions
    -- 7. COMMIT
    
    NULL; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_success := FALSE;
        p_message := 'Error: ' || SQLERRM;
END cancel_ticket;

/**
    * Get booking details
    */
FUNCTION get_booking_details(
    p_booking_id IN NUMBER,
    p_passenger_id OUT NUMBER,
    p_train_id OUT NUMBER,
    p_travel_date OUT DATE,
    p_seat_class OUT VARCHAR2,
    p_seat_status OUT VARCHAR2,
    p_waitlist_position OUT NUMBER
) RETURN BOOLEAN AS
BEGIN
    -- TODO: Implement get booking details
    -- 1. SELECT booking from CRS_RESERVATION
    -- 2. Populate OUT parameters
    -- 3. Return TRUE if found, FALSE otherwise
    
    RETURN FALSE; -- Placeholder
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        RETURN FALSE;
END get_booking_details;

/**
    * Modify an existing booking
    */
PROCEDURE modify_booking(
    p_booking_id IN NUMBER,
    p_new_train_id IN NUMBER DEFAULT NULL,
    p_new_travel_date IN DATE DEFAULT NULL,
    p_new_seat_class IN VARCHAR2 DEFAULT NULL,
    p_success OUT BOOLEAN,
    p_new_status OUT VARCHAR2,
    p_new_waitlist_position OUT NUMBER,
    p_message OUT VARCHAR2
) AS
BEGIN
    -- TODO: Implement modify booking logic
    -- 1. Get current booking details
    -- 2. Validate at least one parameter is changing
    -- 3. Cancel existing booking (don't promote waitlist yet)
    -- 4. Try to book with new parameters
    -- 5. If new booking fails, restore original booking
    -- 6. COMMIT if successful
    
    NULL; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_success := FALSE;
        p_message := 'Error: ' || SQLERRM;
END modify_booking;

END PKG_BOOKING;
/