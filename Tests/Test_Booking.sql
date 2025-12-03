SET SERVEROUTPUT ON;

-- Test Script: PKG_BOOKING - Comprehensive Test Cases
-- Run as: CRS_ADMIN (or user with EXECUTE on PKG_BOOKING)
-- Purpose: Test all booking scenarios

-- TEST 1: Book a ticket - CONFIRMED status
DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
    v_waitlist_position NUMBER;
    v_message VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 1: Book Ticket - Should be CONFIRMED');
    
    CRS_ADMIN.PKG_BOOKING.book_ticket(
        p_passenger_id => 1,
        p_train_id => 1,
        p_travel_date => DATE '2025-12-08',  -- Future date within 7 days
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status,
        p_waitlist_position => v_waitlist_position,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Booking ID: ' || NVL(TO_CHAR(v_booking_id), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Waitlist Position: ' || NVL(TO_CHAR(v_waitlist_position), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 3: Fill all seats to test WAITLIST
DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
    v_waitlist_position NUMBER;
    v_message VARCHAR2(500);
    v_passenger_id NUMBER := 3;
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 3: Fill Seats (book 38 more tickets)');
    
    -- Book 39 more tickets to fill 40 FC seats
    FOR i IN 1..39 LOOP
        CRS_ADMIN.PKG_BOOKING.book_ticket(
            p_passenger_id => MOD(v_passenger_id, 15) + 1, -- Cycle through passengers 1-15
            p_train_id => 1,
            p_travel_date => DATE '2025-12-08',
            p_seat_class => 'FC',
            p_booking_id => v_booking_id,
            p_status => v_status,
            p_waitlist_position => v_waitlist_position,
            p_message => v_message
        );
        v_passenger_id := v_passenger_id + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Booked 39 more tickets. Last booking:');
    DBMS_OUTPUT.PUT_LINE('Booking ID: ' || v_booking_id);
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Total FC seats should now be 40/40 (FULL)');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 4: Book ticket - Should be WAITLISTED
DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
    v_waitlist_position NUMBER;
    v_message VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 4: Book Ticket - Should be WAITLISTED');
    
    CRS_ADMIN.PKG_BOOKING.book_ticket(
        p_passenger_id => 5,
        p_train_id => 1,
        p_travel_date => DATE '2025-12-08',
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status,
        p_waitlist_position => v_waitlist_position,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Booking ID: ' || NVL(TO_CHAR(v_booking_id), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Waitlist Position: ' || NVL(TO_CHAR(v_waitlist_position), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    DBMS_OUTPUT.PUT_LINE('Expected: Status=WAITLISTED, Position=1');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 5: Book more waitlisted tickets (positions 2-5)
DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
    v_waitlist_position NUMBER;
    v_message VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 5: Book 4 More Waitlisted Tickets');
    
    FOR i IN 6..9 LOOP
        CRS_ADMIN.PKG_BOOKING.book_ticket(
            p_passenger_id => i,
            p_train_id => 1,
            p_travel_date => DATE '2025-12-08',
            p_seat_class => 'FC',
            p_booking_id => v_booking_id,
            p_status => v_status,
            p_waitlist_position => v_waitlist_position,
            p_message => v_message
        );
        
        DBMS_OUTPUT.PUT_LINE('Passenger ' || i || ': Waitlist Position ' || v_waitlist_position);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Expected: 5 passengers waitlisted (positions 1-5)');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 6: Try to book when waitlist is FULL
DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
    v_waitlist_position NUMBER;
    v_message VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 6: Book Ticket - Waitlist FULL (Should FAIL)');
    
    CRS_ADMIN.PKG_BOOKING.book_ticket(
        p_passenger_id => 10,
        p_train_id => 1,
        p_travel_date => DATE '2025-12-08',
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status,
        p_waitlist_position => v_waitlist_position,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Booking ID: ' || NVL(TO_CHAR(v_booking_id), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    DBMS_OUTPUT.PUT_LINE('Expected: Status=FAILED, Message about no availability');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 7: Cancel a CONFIRMED ticket
DECLARE
    v_success BOOLEAN;
    v_promoted_booking_id NUMBER;
    v_message VARCHAR2(500);
    v_first_booking_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 7: Cancel CONFIRMED Ticket');
    
    -- Get the first confirmed booking
    SELECT MIN(booking_id) INTO v_first_booking_id
    FROM CRS_ADMIN.CRS_RESERVATION
    WHERE train_id = 1
      AND travel_date = DATE '2025-12-08'
      AND seat_class = 'FC'
      AND seat_status = 'CONFIRMED';
    
    DBMS_OUTPUT.PUT_LINE('Cancelling Booking ID: ' || v_first_booking_id);
    
    CRS_ADMIN.PKG_BOOKING.cancel_ticket(
        p_booking_id => v_first_booking_id,
        p_success => v_success,
        p_promoted_booking_id => v_promoted_booking_id,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Success: ' || CASE WHEN v_success THEN 'TRUE' ELSE 'FALSE' END);
    DBMS_OUTPUT.PUT_LINE('Promoted Booking ID: ' || NVL(TO_CHAR(v_promoted_booking_id), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    DBMS_OUTPUT.PUT_LINE('Expected: Waitlist position 1 promoted to CONFIRMED');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 8: Verify automatic waitlist promotion
DECLARE
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 8: Verify Waitlist Promotion');
    
    -- Count confirmed bookings
    SELECT COUNT(*) INTO v_count
    FROM CRS_ADMIN.CRS_RESERVATION
    WHERE train_id = 1
      AND travel_date = DATE '2025-12-08'
      AND seat_class = 'FC'
      AND seat_status = 'CONFIRMED';
    
    DBMS_OUTPUT.PUT_LINE('Confirmed bookings: ' || v_count);
    
    -- Count waitlisted bookings
    SELECT COUNT(*) INTO v_count
    FROM CRS_ADMIN.CRS_RESERVATION
    WHERE train_id = 1
      AND travel_date = DATE '2025-12-08'
      AND seat_class = 'FC'
      AND seat_status = 'WAITLISTED';
    
    DBMS_OUTPUT.PUT_LINE('Waitlisted bookings: ' || v_count);
    
    -- Show waitlist positions
    DBMS_OUTPUT.PUT_LINE('Current waitlist positions:');
    FOR rec IN (
        SELECT booking_id, passenger_id, waitlist_position
        FROM CRS_ADMIN.CRS_RESERVATION
        WHERE train_id = 1
          AND travel_date = DATE '2025-12-08'
          AND seat_class = 'FC'
          AND seat_status = 'WAITLISTED'
        ORDER BY waitlist_position
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  Booking ' || rec.booking_id || 
                           ' (Passenger ' || rec.passenger_id || 
                           '): Position ' || rec.waitlist_position);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 9: Cancel a WAITLISTED ticket
DECLARE
    v_success BOOLEAN;
    v_promoted_booking_id NUMBER;
    v_message VARCHAR2(500);
    v_waitlist_booking_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 9: Cancel WAITLISTED Ticket (Position 2)');
    
    -- Get a waitlisted booking at position 2
    SELECT booking_id INTO v_waitlist_booking_id
    FROM CRS_ADMIN.CRS_RESERVATION
    WHERE train_id = 1
      AND travel_date = DATE '2025-12-08'
      AND seat_class = 'FC'
      AND seat_status = 'WAITLISTED'
      AND waitlist_position = 2;
    
    DBMS_OUTPUT.PUT_LINE('Cancelling Waitlisted Booking ID: ' || v_waitlist_booking_id);
    
    CRS_ADMIN.PKG_BOOKING.cancel_ticket(
        p_booking_id => v_waitlist_booking_id,
        p_success => v_success,
        p_promoted_booking_id => v_promoted_booking_id,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Success: ' || CASE WHEN v_success THEN 'TRUE' ELSE 'FALSE' END);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    DBMS_OUTPUT.PUT_LINE('Expected: Positions 3, 4 reordered to 2, 3');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 12: Error Handling - Invalid train ID
DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
    v_waitlist_position NUMBER;
    v_message VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 12: Error - Invalid Train ID');
    
    CRS_ADMIN.PKG_BOOKING.book_ticket(
        p_passenger_id => 1,
        p_train_id => 9999,  -- Invalid train
        p_travel_date => DATE '2025-12-08',
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status,
        p_waitlist_position => v_waitlist_position,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    DBMS_OUTPUT.PUT_LINE('Expected: FAILED with train not found error');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 13: Error Handling - Past date
DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
    v_waitlist_position NUMBER;
    v_message VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 13: Error - Past Travel Date');
    
    CRS_ADMIN.PKG_BOOKING.book_ticket(
        p_passenger_id => 1,
        p_train_id => 1,
        p_travel_date => DATE '2020-01-01',  -- Past date
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status,
        p_waitlist_position => v_waitlist_position,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    DBMS_OUTPUT.PUT_LINE('Expected: FAILED with past date error');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 14: Error Handling - Cancel already cancelled booking
DECLARE
    v_success BOOLEAN;
    v_promoted_booking_id NUMBER;
    v_message VARCHAR2(500);
    v_cancelled_booking_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('TEST 14: Error - Cancel Already Cancelled Booking');
    
    -- Get a cancelled booking
    SELECT booking_id INTO v_cancelled_booking_id
    FROM CRS_ADMIN.CRS_RESERVATION
    WHERE seat_status = 'CANCELLED'
      AND ROWNUM = 1;
    
    DBMS_OUTPUT.PUT_LINE('Attempting to cancel Booking ID: ' || v_cancelled_booking_id);
    
    CRS_ADMIN.PKG_BOOKING.cancel_ticket(
        p_booking_id => v_cancelled_booking_id,
        p_success => v_success,
        p_promoted_booking_id => v_promoted_booking_id,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Success: ' || CASE WHEN v_success THEN 'TRUE' ELSE 'FALSE' END);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    DBMS_OUTPUT.PUT_LINE('Expected: FALSE with already cancelled error');
    DBMS_OUTPUT.PUT_LINE('');
END;
/