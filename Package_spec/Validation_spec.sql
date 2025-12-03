-- Package: PKG_VALIDATION
-- Purpose: Centralized validation logic for business rules
-- Owner: CRS_ADMIN

CREATE OR REPLACE PACKAGE PKG_VALIDATION AS

-- CONSTANTS
C_MAX_WAITLIST_PER_CLASS    CONSTANT NUMBER := 5;
C_ADVANCE_BOOKING_DAYS      CONSTANT NUMBER := 7;

C_SEAT_CLASS_FC             CONSTANT VARCHAR2(10) := 'FC';
C_SEAT_CLASS_ECON           CONSTANT VARCHAR2(10) := 'ECON';

C_STATUS_CONFIRMED          CONSTANT VARCHAR2(20) := 'CONFIRMED';
C_STATUS_WAITLISTED         CONSTANT VARCHAR2(20) := 'WAITLISTED';
C_STATUS_CANCELLED          CONSTANT VARCHAR2(20) := 'CANCELLED';

-- MAIN VALIDATION FUNCTIONS

/**
    * Comprehensive validation for booking request
    * Checks: train exists, passenger exists, date validity, train operates, seat class
    * @param p_train_id Train ID
    * @param p_passenger_id Passenger ID
    * @param p_travel_date Travel date
    * @param p_seat_class Seat class (FC/ECON)
    * @param p_booking_date Booking date (default SYSDATE)
    * @return 'OK' if valid, detailed error message otherwise
    */
FUNCTION validate_booking_request(
    p_train_id IN NUMBER,
    p_passenger_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2,
    p_booking_date IN DATE DEFAULT SYSDATE
) RETURN VARCHAR2;

/**
    * Validate cancellation request
    * Checks: booking exists, booking is not already cancelled
    * @param p_booking_id Booking ID
    * @return 'OK' if valid, error message otherwise
    */
FUNCTION validate_cancellation(
    p_booking_id IN NUMBER
) RETURN VARCHAR2;

/**
    * Check seat availability status
    * Returns: AVAILABLE, WAITLIST_AVAILABLE, or FULL
    * @param p_train_id Train ID
    * @param p_travel_date Travel date
    * @param p_seat_class Seat class
    * @return Availability status
    */
FUNCTION check_seat_availability(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN VARCHAR2;

-- HELPER FUNCTIONS
/**
    * Get available seat count (negative means overbooked)
    * @param p_train_id Train ID
    * @param p_travel_date Travel date
    * @param p_seat_class Seat class
    * @return Number of available seats
    */
FUNCTION get_available_seats(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN NUMBER;

/**
    * Get current waitlist count
    * @param p_train_id Train ID
    * @param p_travel_date Travel date
    * @param p_seat_class Seat class
    * @return Number of waitlisted bookings
    */
FUNCTION get_waitlist_count(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN NUMBER;

/**
    * Get next available waitlist position
    * @param p_train_id Train ID
    * @param p_travel_date Travel date
    * @param p_seat_class Seat class
    * @return Next waitlist position number
    */
FUNCTION get_next_waitlist_position(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_seat_class IN VARCHAR2
) RETURN NUMBER;

END PKG_VALIDATION;
/