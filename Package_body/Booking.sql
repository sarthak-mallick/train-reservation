CREATE OR REPLACE PACKAGE BODY PKG_BOOKING AS

    -- Custom Exception Codes
    C_ERR_VALIDATION_FAILED     CONSTANT NUMBER := -20001;
    C_ERR_NO_AVAILABILITY       CONSTANT NUMBER := -20002;
    C_ERR_BOOKING_NOT_FOUND     CONSTANT NUMBER := -20003;
    C_ERR_ALREADY_CANCELLED     CONSTANT NUMBER := -20004;
    C_ERR_NO_CHANGES            CONSTANT NUMBER := -20005;
    C_ERR_MODIFICATION_FAILED   CONSTANT NUMBER := -20006;

    /**
     * INTERNAL: Validate and determine booking status
     * Does NOT perform any DML - just validation and availability check
     */
    PROCEDURE validate_and_check_availability(
        p_passenger_id IN NUMBER,
        p_train_id IN NUMBER,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2,
        p_status OUT VARCHAR2,
        p_waitlist_position OUT NUMBER
    ) AS
        v_validation_result VARCHAR2(500);
        v_availability_status VARCHAR2(50);
    BEGIN
        -- Initialize
        p_status := 'FAILED';
        p_waitlist_position := NULL;
        
        -- Validate booking request
        v_validation_result := PKG_VALIDATION.validate_booking_request(
            p_train_id => p_train_id,
            p_passenger_id => p_passenger_id,
            p_travel_date => p_travel_date,
            p_seat_class => p_seat_class,
            p_booking_date => SYSDATE
        );
        
        IF v_validation_result != 'OK' THEN
            RAISE_APPLICATION_ERROR(C_ERR_VALIDATION_FAILED, v_validation_result);
        END IF;
        
        -- Check seat availability
        v_availability_status := PKG_VALIDATION.check_seat_availability(
            p_train_id => p_train_id,
            p_travel_date => p_travel_date,
            p_seat_class => p_seat_class
        );
        
        -- Determine status based on availability
        IF v_availability_status = 'AVAILABLE' THEN
            p_status := PKG_VALIDATION.C_STATUS_CONFIRMED;
            p_waitlist_position := NULL;
            
        ELSIF v_availability_status = 'WAITLIST_AVAILABLE' THEN
            p_status := PKG_VALIDATION.C_STATUS_WAITLISTED;
            p_waitlist_position := PKG_VALIDATION.get_next_waitlist_position(
                p_train_id => p_train_id,
                p_travel_date => p_travel_date,
                p_seat_class => p_seat_class
            );
            
        ELSE
            RAISE_APPLICATION_ERROR(C_ERR_NO_AVAILABILITY, 'No seats or waitlist available. Booking failed.');
        END IF;
    END validate_and_check_availability;

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
        -- Initialize OUT parameters
        p_booking_id := NULL;
        p_status := 'FAILED';
        p_waitlist_position := NULL;
        p_message := NULL;
        
        -- Validate and determine status
        validate_and_check_availability(
            p_passenger_id => p_passenger_id,
            p_train_id => p_train_id,
            p_travel_date => p_travel_date,
            p_seat_class => p_seat_class,
            p_status => p_status,
            p_waitlist_position => p_waitlist_position
        );
        
        -- Insert booking
        INSERT INTO CRS_RESERVATION (
            passenger_id,
            train_id,
            travel_date,
            booking_date,
            seat_class,
            seat_status,
            waitlist_position
        ) VALUES (
            p_passenger_id,
            p_train_id,
            p_travel_date,
            SYSDATE,
            p_seat_class,
            p_status,
            p_waitlist_position
        ) RETURNING booking_id INTO p_booking_id;
        
        -- Set message
        IF p_status = PKG_VALIDATION.C_STATUS_CONFIRMED THEN
            p_message := 'Ticket confirmed successfully.';
        ELSE
            p_message := 'Ticket waitlisted at position ' || p_waitlist_position || '.';
        END IF;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_booking_id := NULL;
            p_status := 'FAILED';
            
            CASE WHEN SQLCODE IN
                (C_ERR_VALIDATION_FAILED, C_ERR_NO_AVAILABILITY) THEN
                    p_message := SQLERRM;
                ELSE
                    p_message := 'Booking error: ' || SQLERRM;
            END CASE;
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
        v_validation_result VARCHAR2(500);
        v_train_id NUMBER;
        v_travel_date DATE;
        v_seat_class VARCHAR2(10);
        v_old_waitlist_position NUMBER;
        v_was_confirmed NUMBER;
        v_first_waitlist_id NUMBER;
        v_has_waitlist NUMBER;
        v_rows_updated NUMBER := 0;
    BEGIN
        p_success := FALSE;
        p_promoted_booking_id := NULL;
        p_message := NULL;
        
        -- Validate cancellation
        v_validation_result := PKG_VALIDATION.validate_cancellation(p_booking_id);
        IF v_validation_result != 'OK' THEN
            RAISE_APPLICATION_ERROR(C_ERR_VALIDATION_FAILED, v_validation_result);
        END IF;
        
        -- Get booking details
        SELECT 
            train_id, 
            travel_date, 
            seat_class, 
            waitlist_position,
            CASE WHEN seat_status = 'CONFIRMED' THEN 1 ELSE 0 END
        INTO 
            v_train_id, 
            v_travel_date, 
            v_seat_class, 
            v_old_waitlist_position,
            v_was_confirmed
        FROM CRS_RESERVATION
        WHERE booking_id = p_booking_id;
        
        -- Check for waitlist if was confirmed
        IF v_was_confirmed = 1 THEN
            SELECT COUNT(*), MIN(booking_id)
            INTO v_has_waitlist, v_first_waitlist_id
            FROM CRS_RESERVATION
            WHERE train_id = v_train_id
            AND travel_date = v_travel_date
            AND seat_class = v_seat_class
            AND seat_status = 'WAITLISTED'
            AND waitlist_position = 1;
        ELSE
            v_has_waitlist := 0;
        END IF;
        
        -- Cancel the booking
        UPDATE CRS_RESERVATION
        SET seat_status = 'CANCELLED',
            waitlist_position = NULL
        WHERE booking_id = p_booking_id;
        
        -- If was waitlisted, reorder remaining
        IF v_old_waitlist_position IS NOT NULL THEN
            FOR rec IN (
                SELECT booking_id, waitlist_position
                FROM CRS_RESERVATION
                WHERE train_id = v_train_id
                AND travel_date = v_travel_date
                AND seat_class = v_seat_class
                AND seat_status = 'WAITLISTED'
                AND waitlist_position > v_old_waitlist_position
                ORDER BY waitlist_position
            ) LOOP
                UPDATE CRS_RESERVATION
                SET waitlist_position = rec.waitlist_position - 1
                WHERE booking_id = rec.booking_id;
                
                v_rows_updated := v_rows_updated + 1;
            END LOOP;
            
            p_message := 'Waitlisted booking cancelled. ' || v_rows_updated || ' waitlist bookings reordered.';
            
        -- If was confirmed and has waitlist, promote
        ELSIF v_has_waitlist > 0 THEN
            p_promoted_booking_id := v_first_waitlist_id;
            
            -- Promote to confirmed
            UPDATE CRS_RESERVATION
            SET seat_status = 'CONFIRMED',
                waitlist_position = NULL
            WHERE booking_id = v_first_waitlist_id;
            
            -- Reorder remaining waitlist row-by-row
            FOR rec IN (
                SELECT booking_id, waitlist_position
                FROM CRS_RESERVATION
                WHERE train_id = v_train_id
                AND travel_date = v_travel_date
                AND seat_class = v_seat_class
                AND seat_status = 'WAITLISTED'
                ORDER BY waitlist_position
            ) LOOP
                UPDATE CRS_RESERVATION
                SET waitlist_position = rec.waitlist_position - 1
                WHERE booking_id = rec.booking_id;
                
                v_rows_updated := v_rows_updated + 1;
            END LOOP;
            
            p_message := 'Booking cancelled. Booking ' || p_promoted_booking_id || ' promoted. ' || v_rows_updated || ' waitlist bookings reordered.';
        ELSE
            p_message := 'Booking cancelled. No waitlisted passengers to promote.';
        END IF;
        
        COMMIT;
        p_success := TRUE;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_success := FALSE;
            
            CASE WHEN SQLCODE IN 
                (C_ERR_VALIDATION_FAILED, C_ERR_BOOKING_NOT_FOUND) THEN
                    p_message := SQLERRM;
                ELSE
                    p_message := 'Cancellation error: ' || SQLERRM;
            END CASE;
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
        SELECT passenger_id,
               train_id,
               travel_date,
               seat_class,
               seat_status,
               waitlist_position
        INTO p_passenger_id,
             p_train_id,
             p_travel_date,
             p_seat_class,
             p_seat_status,
             p_waitlist_position
        FROM CRS_RESERVATION
        WHERE booking_id = p_booking_id;
        
        RETURN TRUE;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            RETURN FALSE;
    END get_booking_details;

END PKG_BOOKING;
/