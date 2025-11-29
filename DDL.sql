SET SERVEROUTPUT ON;

-- Create All Tables (DDL)
-- Run as: CRS_ADMIN
-- Purpose: Create the database schema structure

-- CRS_TRAIN_INFO - Master train information
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CRS_TRAIN_INFO CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('CRS_TRAIN_INFO table does not exist. Skipping drop...');
END;
/

CREATE TABLE CRS_TRAIN_INFO (
    train_id            NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    train_number        VARCHAR2(20)    NOT NULL UNIQUE,
    source_station      VARCHAR2(100)   NOT NULL,
    dest_station        VARCHAR2(100)   NOT NULL,
    total_fc_seats      NUMBER          NOT NULL,
    total_econ_seats    NUMBER          NOT NULL,
    fc_seat_fare        NUMBER(10,2)    NOT NULL,
    econ_seat_fare      NUMBER(10,2)    NOT NULL,
    
    CONSTRAINT chk_fc_seats CHECK (total_fc_seats > 0),
    CONSTRAINT chk_econ_seats CHECK (total_econ_seats > 0),
    CONSTRAINT chk_fc_fare CHECK (fc_seat_fare > 0),
    CONSTRAINT chk_econ_fare CHECK (econ_seat_fare > 0),
    CONSTRAINT chk_different_stations CHECK (source_station != dest_station)
);
/

-- CRS_DAY_SCHEDULE - Day of week schedule reference
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CRS_DAY_SCHEDULE CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('CRS_DAY_SCHEDULE table does not exist. Skipping drop...');
END;
/

CREATE TABLE CRS_DAY_SCHEDULE (
    sch_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    day_of_week     VARCHAR2(10)    NOT NULL UNIQUE,
    is_week_end     CHAR(1)         NOT NULL,
    
    CONSTRAINT chk_is_week_end CHECK (is_week_end IN ('Y', 'N'))
);
/

-- CRS_TRAIN_SCHEDULE - Bridge table for train availability
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CRS_TRAIN_SCHEDULE CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('CRS_TRAIN_SCHEDULE table does not exist. Skipping drop...');
END;
/

CREATE TABLE CRS_TRAIN_SCHEDULE (
    tsch_id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sch_id          NUMBER          NOT NULL,
    train_id        NUMBER          NOT NULL,
    is_in_service   CHAR(1)         NOT NULL,
    
    CONSTRAINT chk_is_in_service CHECK (is_in_service IN ('Y', 'N')),
    CONSTRAINT fk_train_schedule_day FOREIGN KEY (sch_id) 
        REFERENCES CRS_DAY_SCHEDULE(sch_id),
    CONSTRAINT fk_train_schedule_train FOREIGN KEY (train_id) 
        REFERENCES CRS_TRAIN_INFO(train_id),
    CONSTRAINT uk_train_day UNIQUE (train_id, sch_id)
);
/

-- CRS_PASSENGER - Passenger information
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CRS_PASSENGER CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('CRS_PASSENGER table does not exist. Skipping drop...');
END;
/

CREATE TABLE CRS_PASSENGER (
    passenger_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name      VARCHAR2(50)    NOT NULL,
    middle_name     VARCHAR2(50),
    last_name       VARCHAR2(50)    NOT NULL,
    date_of_birth   DATE            NOT NULL,
    address_line1   VARCHAR2(200)   NOT NULL,
    address_city    VARCHAR2(100)   NOT NULL,
    address_state   VARCHAR2(50)    NOT NULL,
    address_zip     VARCHAR2(10)    NOT NULL,
    email           VARCHAR2(100)   NOT NULL UNIQUE,
    phone           VARCHAR2(20)    NOT NULL UNIQUE
);
/

-- CRS_RESERVATION - Ticket bookings
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CRS_RESERVATION CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('CRS_RESERVATION table does not exist. Skipping drop...');
END;
/

CREATE TABLE CRS_RESERVATION (
    booking_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    passenger_id        NUMBER          NOT NULL,
    train_id            NUMBER          NOT NULL,
    travel_date         DATE            NOT NULL,
    booking_date        DATE            NOT NULL,
    seat_class          VARCHAR2(10)    NOT NULL,
    seat_status         VARCHAR2(20)    NOT NULL,
    waitlist_position   NUMBER,
    
    CONSTRAINT chk_seat_class CHECK (seat_class IN ('FC', 'ECON')),
    CONSTRAINT chk_seat_status CHECK (seat_status IN ('CONFIRMED', 'WAITLISTED', 'CANCELLED')),
    CONSTRAINT chk_waitlist_position CHECK (waitlist_position > 0),
    CONSTRAINT fk_reservation_passenger FOREIGN KEY (passenger_id) 
        REFERENCES CRS_PASSENGER(passenger_id),
    CONSTRAINT fk_reservation_train FOREIGN KEY (train_id) 
        REFERENCES CRS_TRAIN_INFO(train_id)
);

/