-- Package: PKG_BOOKING
-- Purpose: Core booking operations - book, cancel, waitlist management
-- Owner: CRS_ADMIN

CREATE OR REPLACE PACKAGE PKG_BOOKING AS

/**
    * Book a ticket with all validations
    * Handles:
    * - All validation checks (train, passenger, date, availability)
    * - Confirms if seats available
    * - Waitlists if seats full but waitlist available
    * - Enforces 40 seats + 5 waitlist per class limit
    * 
    * @param p_passenger_id Passenger ID
    * @param p_train_id Train ID
    * @param p_travel_date Travel date
    * @param p_seat_class 'FC' or 'ECON'
    * @param p_booking_id OUT - Generated booking ID if successful
    * @param p_status OUT - 'CONFIRMED', 'WAITLISTED', or 'FAILED'
    * @param p_waitlist_position OUT - Position if waitlisted, NULL otherwise
    * @param p_message OUT - Success or error message
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
);

/**
    * Cancel a ticket and promote first waitlisted passenger
    * Handles:
    * - Validates booking exists and can be cancelled
    * - Updates booking to CANCELLED
    * - Finds first waitlisted ticket for same train/date/class
    * - Promotes to CONFIRMED
    * - Reorders remaining waitlist positions
    * 
    * @param p_booking_id Booking ID to cancel
    * @param p_success OUT - TRUE if cancelled successfully
    * @param p_promoted_booking_id OUT - Booking ID that was promoted (NULL if none)
    * @param p_message OUT - Success or error message
    */
PROCEDURE cancel_ticket(
    p_booking_id IN NUMBER,
    p_success OUT BOOLEAN,
    p_promoted_booking_id OUT NUMBER,
    p_message OUT VARCHAR2
);

/**
    * Get booking details
    * @param p_booking_id Booking ID
    * @return TRUE if booking exists, FALSE otherwise
    * OUT parameters populated with booking details
    */
FUNCTION get_booking_details(
    p_booking_id IN NUMBER,
    p_passenger_id OUT NUMBER,
    p_train_id OUT NUMBER,
    p_travel_date OUT DATE,
    p_seat_class OUT VARCHAR2,
    p_seat_status OUT VARCHAR2,
    p_waitlist_position OUT NUMBER
) RETURN BOOLEAN;

END PKG_BOOKING;
/