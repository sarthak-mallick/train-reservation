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
            RAISE_APPLICATION_ERROR(C_ERR_NO_AVAILABILITY, 
                'No seats or waitlist available. Booking failed.');
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
            
            CASE SQLCODE
                WHEN C_ERR_VALIDATION_FAILED THEN
                    p_message := SQLERRM;
                WHEN C_ERR_NO_AVAILABILITY THEN
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
    BEGIN
        -- Initialize OUT parameters
        p_success := FALSE;
        p_promoted_booking_id := NULL;
        p_message := NULL;
        
        -- Validate cancellation
        v_validation_result := PKG_VALIDATION.validate_cancellation(p_booking_id);
        
        IF v_validation_result != 'OK' THEN
            RAISE_APPLICATION_ERROR(C_ERR_VALIDATION_FAILED, v_validation_result);
        END IF;
        
        -- Get booking details
        BEGIN
            SELECT train_id, travel_date, seat_class, waitlist_position
            INTO v_train_id, v_travel_date, v_seat_class, v_old_waitlist_position
            FROM CRS_RESERVATION
            WHERE booking_id = p_booking_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(C_ERR_BOOKING_NOT_FOUND, 
                    'Booking ID ' || p_booking_id || ' not found.');
        END;
        
        -- Cancel the booking
        UPDATE CRS_RESERVATION
        SET seat_status = PKG_VALIDATION.C_STATUS_CANCELLED,
            waitlist_position = NULL
        WHERE booking_id = p_booking_id;
        
        -- Handle waitlist reordering or promotion
        IF v_old_waitlist_position IS NOT NULL THEN
            -- Was waitlisted - just reorder
            UPDATE CRS_RESERVATION
            SET waitlist_position = waitlist_position - 1
            WHERE train_id = v_train_id
              AND travel_date = v_travel_date
              AND seat_class = v_seat_class
              AND seat_status = PKG_VALIDATION.C_STATUS_WAITLISTED
              AND waitlist_position > v_old_waitlist_position;
            
            p_message := 'Waitlisted booking cancelled. Remaining waitlist reordered.';
        ELSE
            -- Was confirmed - promote from waitlist
            BEGIN
                SELECT booking_id
                INTO p_promoted_booking_id
                FROM CRS_RESERVATION
                WHERE train_id = v_train_id
                  AND travel_date = v_travel_date
                  AND seat_class = v_seat_class
                  AND seat_status = PKG_VALIDATION.C_STATUS_WAITLISTED
                ORDER BY waitlist_position
                FETCH FIRST 1 ROW ONLY;
                
                -- Promote
                UPDATE CRS_RESERVATION
                SET seat_status = PKG_VALIDATION.C_STATUS_CONFIRMED,
                    waitlist_position = NULL
                WHERE booking_id = p_promoted_booking_id;
                
                -- Reorder remaining
                UPDATE CRS_RESERVATION
                SET waitlist_position = waitlist_position - 1
                WHERE train_id = v_train_id
                  AND travel_date = v_travel_date
                  AND seat_class = v_seat_class
                  AND seat_status = PKG_VALIDATION.C_STATUS_WAITLISTED;
                
                p_message := 'Booking cancelled. Booking ID ' || p_promoted_booking_id || ' promoted from waitlist.';
                
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    p_message := 'Booking cancelled successfully. No waitlisted passengers to promote.';
            END;
        END IF;
        
        COMMIT;
        p_success := TRUE;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_success := FALSE;
            
            CASE SQLCODE
                WHEN C_ERR_VALIDATION_FAILED THEN
                    p_message := SQLERRM;
                WHEN C_ERR_BOOKING_NOT_FOUND THEN
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
        -- Current booking details
        v_current_passenger_id NUMBER;
        v_current_train_id NUMBER;
        v_current_travel_date DATE;
        v_current_seat_class VARCHAR2(10);
        v_current_status VARCHAR2(20);
        v_current_waitlist NUMBER;
        
        -- New booking details
        v_final_train_id NUMBER;
        v_final_travel_date DATE;
        v_final_seat_class VARCHAR2(10);
        
        v_found BOOLEAN;
    BEGIN
        -- Initialize OUT parameters
        p_success := FALSE;
        p_new_status := NULL;
        p_new_waitlist_position := NULL;
        p_message := NULL;
        
        -- Get current booking details
        v_found := get_booking_details(
            p_booking_id => p_booking_id,
            p_passenger_id => v_current_passenger_id,
            p_train_id => v_current_train_id,
            p_travel_date => v_current_travel_date,
            p_seat_class => v_current_seat_class,
            p_seat_status => v_current_status,
            p_waitlist_position => v_current_waitlist
        );
        
        IF NOT v_found THEN
            RAISE_APPLICATION_ERROR(C_ERR_BOOKING_NOT_FOUND, 
                'Booking ID ' || p_booking_id || ' not found.');
        END IF;
        
        -- Check if booking can be modified
        IF v_current_status = PKG_VALIDATION.C_STATUS_CANCELLED THEN
            RAISE_APPLICATION_ERROR(C_ERR_ALREADY_CANCELLED, 
                'Cannot modify a cancelled booking.');
        END IF;
        
        -- Determine final values
        v_final_train_id := NVL(p_new_train_id, v_current_train_id);
        v_final_travel_date := NVL(p_new_travel_date, v_current_travel_date);
        v_final_seat_class := NVL(p_new_seat_class, v_current_seat_class);
        
        -- Check if anything is changing
        IF v_final_train_id = v_current_train_id 
           AND v_final_travel_date = v_current_travel_date
           AND v_final_seat_class = v_current_seat_class THEN
            RAISE_APPLICATION_ERROR(C_ERR_NO_CHANGES, 
                'No changes detected. Booking remains unchanged.');
        END IF;
        
        -- Validate and check availability
        validate_and_check_availability(
            p_passenger_id => v_current_passenger_id,
            p_train_id => v_final_train_id,
            p_travel_date => v_final_travel_date,
            p_seat_class => v_final_seat_class,
            p_status => p_new_status,
            p_waitlist_position => p_new_waitlist_position
        );
        
        -- Update the booking
        UPDATE CRS_RESERVATION
        SET train_id = v_final_train_id,
            travel_date = v_final_travel_date,
            seat_class = v_final_seat_class,
            seat_status = p_new_status,
            waitlist_position = p_new_waitlist_position,
            booking_date = SYSDATE
        WHERE booking_id = p_booking_id;
        
        -- If old booking was confirmed, try to promote waitlist
        IF v_current_status = PKG_VALIDATION.C_STATUS_CONFIRMED 
           AND (v_final_train_id != v_current_train_id 
                OR v_final_travel_date != v_current_travel_date 
                OR v_final_seat_class != v_current_seat_class) THEN
            
            DECLARE
                v_promoted_booking_id NUMBER;
            BEGIN
                SELECT booking_id
                INTO v_promoted_booking_id
                FROM CRS_RESERVATION
                WHERE train_id = v_current_train_id
                  AND travel_date = v_current_travel_date
                  AND seat_class = v_current_seat_class
                  AND seat_status = PKG_VALIDATION.C_STATUS_WAITLISTED
                ORDER BY waitlist_position
                FETCH FIRST 1 ROW ONLY;
                
                -- Promote
                UPDATE CRS_RESERVATION
                SET seat_status = PKG_VALIDATION.C_STATUS_CONFIRMED,
                    waitlist_position = NULL
                WHERE booking_id = v_promoted_booking_id;
                
                -- Reorder remaining
                UPDATE CRS_RESERVATION
                SET waitlist_position = waitlist_position - 1
                WHERE train_id = v_current_train_id
                  AND travel_date = v_current_travel_date
                  AND seat_class = v_current_seat_class
                  AND seat_status = PKG_VALIDATION.C_STATUS_WAITLISTED;
                
                p_message := 'Booking modified. Status: ' || p_new_status || '. Booking ID ' || v_promoted_booking_id || ' promoted from old waitlist.';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    p_message := 'Booking modified successfully. Status: ' || p_new_status || '.';
            END;
        ELSE
            p_message := 'Booking modified successfully. Status: ' || p_new_status || '.';
        END IF;
        
        IF p_new_status = PKG_VALIDATION.C_STATUS_WAITLISTED THEN
            p_message := p_message || ' Waitlist position: ' || p_new_waitlist_position || '.';
        END IF;
        
        COMMIT;
        p_success := TRUE;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_success := FALSE;
            
            CASE SQLCODE
                WHEN C_ERR_BOOKING_NOT_FOUND THEN
                    p_message := SQLERRM;
                WHEN C_ERR_ALREADY_CANCELLED THEN
                    p_message := SQLERRM;
                WHEN C_ERR_NO_CHANGES THEN
                    p_success := TRUE;
                    p_new_status := v_current_status;
                    p_new_waitlist_position := v_current_waitlist;
                    p_message := SQLERRM;
                WHEN C_ERR_VALIDATION_FAILED THEN
                    p_message := SQLERRM;
                WHEN C_ERR_NO_AVAILABILITY THEN
                    p_message := SQLERRM;
                ELSE
                    p_message := 'Modification error: ' || SQLERRM;
            END CASE;
    END modify_booking;

END PKG_BOOKING;
/