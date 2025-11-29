SET SERVEROUTPUT ON;

-- Insert Sample Data (DML)
-- Run as: CRS_DATA
-- Purpose: Populate all tables with sample data

-- Populate CRS_DAY_SCHEDULE (7 rows for days of week)
INSERT INTO crs_admin.CRS_DAY_SCHEDULE (day_of_week, is_week_end) VALUES ('Monday', 'N');
INSERT INTO crs_admin.CRS_DAY_SCHEDULE (day_of_week, is_week_end) VALUES ('Tuesday', 'N');
INSERT INTO crs_admin.CRS_DAY_SCHEDULE (day_of_week, is_week_end) VALUES ('Wednesday', 'N');
INSERT INTO crs_admin.CRS_DAY_SCHEDULE (day_of_week, is_week_end) VALUES ('Thursday', 'N');
INSERT INTO crs_admin.CRS_DAY_SCHEDULE (day_of_week, is_week_end) VALUES ('Friday', 'N');
INSERT INTO crs_admin.CRS_DAY_SCHEDULE (day_of_week, is_week_end) VALUES ('Saturday', 'Y');
INSERT INTO crs_admin.CRS_DAY_SCHEDULE (day_of_week, is_week_end) VALUES ('Sunday', 'Y');
COMMIT;

-- Populate CRS_TRAIN_INFO
INSERT INTO crs_admin.CRS_TRAIN_INFO (train_number, source_station, dest_station, total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES ('TR001', 'New York Penn Station', 'Boston South Station', 40, 40, 150.00, 75.00);

INSERT INTO crs_admin.CRS_TRAIN_INFO (train_number, source_station, dest_station, total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES ('TR002', 'Chicago Union Station', 'Detroit Michigan Central', 40, 40, 120.00, 60.00);

INSERT INTO crs_admin.CRS_TRAIN_INFO (train_number, source_station, dest_station, total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES ('TR003', 'Los Angeles Union Station', 'San Diego Santa Fe', 40, 40, 100.00, 50.00);

INSERT INTO crs_admin.CRS_TRAIN_INFO (train_number, source_station, dest_station, total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES ('TR004', 'Washington DC Union Station', 'Philadelphia 30th Street', 40, 40, 110.00, 55.00);

INSERT INTO crs_admin.CRS_TRAIN_INFO (train_number, source_station, dest_station, total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES ('TR005', 'San Francisco Caltrain', 'San Jose Diridon', 40, 40, 80.00, 40.00);

INSERT INTO crs_admin.CRS_TRAIN_INFO (train_number, source_station, dest_station, total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES ('TR006', 'Seattle King Street', 'Portland Union Station', 40, 40, 130.00, 65.00);

INSERT INTO crs_admin.CRS_TRAIN_INFO (train_number, source_station, dest_station, total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES ('TR007', 'Miami Central', 'Orlando Amtrak', 40, 40, 140.00, 70.00);

INSERT INTO crs_admin.CRS_TRAIN_INFO (train_number, source_station, dest_station, total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES ('TR008', 'Denver Union Station', 'Colorado Springs', 40, 40, 90.00, 45.00);

INSERT INTO crs_admin.CRS_TRAIN_INFO (train_number, source_station, dest_station, total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES ('TR009', 'Atlanta Peachtree', 'Charlotte Gateway', 40, 40, 125.00, 62.50);

INSERT INTO crs_admin.CRS_TRAIN_INFO (train_number, source_station, dest_station, total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES ('TR010', 'Dallas Union Station', 'Houston Amtrak', 40, 40, 135.00, 67.50);

COMMIT;

-- Populate CRS_TRAIN_SCHEDULE
-- Mixed schedules: weekdays only, weekends only, all days

-- TR001: All days (Monday-Sunday)
INSERT INTO crs_admin.CRS_TRAIN_SCHEDULE (sch_id, train_id, is_in_service)
SELECT sch_id, 1, 'Y' FROM crs_admin.CRS_DAY_SCHEDULE;

-- TR002: Weekdays only (Monday-Friday)
INSERT INTO crs_admin.CRS_TRAIN_SCHEDULE (sch_id, train_id, is_in_service)
SELECT sch_id, 2, 'Y' FROM crs_admin.CRS_DAY_SCHEDULE WHERE is_week_end = 'N';

-- TR003: All days
INSERT INTO crs_admin.CRS_TRAIN_SCHEDULE (sch_id, train_id, is_in_service)
SELECT sch_id, 3, 'Y' FROM crs_admin.CRS_DAY_SCHEDULE;

-- TR004: Weekdays only
INSERT INTO crs_admin.CRS_TRAIN_SCHEDULE (sch_id, train_id, is_in_service)
SELECT sch_id, 4, 'Y' FROM crs_admin.CRS_DAY_SCHEDULE WHERE is_week_end = 'N';

-- TR005: All days
INSERT INTO crs_admin.CRS_TRAIN_SCHEDULE (sch_id, train_id, is_in_service)
SELECT sch_id, 5, 'Y' FROM crs_admin.CRS_DAY_SCHEDULE;

-- TR006: Weekends only (Saturday-Sunday)
INSERT INTO crs_admin.CRS_TRAIN_SCHEDULE (sch_id, train_id, is_in_service)
SELECT sch_id, 6, 'Y' FROM crs_admin.CRS_DAY_SCHEDULE WHERE is_week_end = 'Y';

-- TR007: All days
INSERT INTO crs_admin.CRS_TRAIN_SCHEDULE (sch_id, train_id, is_in_service)
SELECT sch_id, 7, 'Y' FROM crs_admin.CRS_DAY_SCHEDULE;

-- TR008: Weekdays only
INSERT INTO crs_admin.CRS_TRAIN_SCHEDULE (sch_id, train_id, is_in_service)
SELECT sch_id, 8, 'Y' FROM crs_admin.CRS_DAY_SCHEDULE WHERE is_week_end = 'N';

-- TR009: Weekends only
INSERT INTO crs_admin.CRS_TRAIN_SCHEDULE (sch_id, train_id, is_in_service)
SELECT sch_id, 9, 'Y' FROM crs_admin.CRS_DAY_SCHEDULE WHERE is_week_end = 'Y';

-- TR010: All days
INSERT INTO crs_admin.CRS_TRAIN_SCHEDULE (sch_id, train_id, is_in_service)
SELECT sch_id, 10, 'Y' FROM crs_admin.CRS_DAY_SCHEDULE;

COMMIT;

-- Populate CRS_PASSENGER
INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('John', 'Michael', 'Smith', DATE '1985-03-15', '123 Main St', 'New York', 'NY', '10001', 'john.smith@email.com', '212-555-0101');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('Sarah', 'Anne', 'Johnson', DATE '1990-07-22', '456 Oak Ave', 'Boston', 'MA', '02101', 'sarah.johnson@email.com', '617-555-0102');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('Michael', NULL, 'Williams', DATE '1978-11-30', '789 Pine Rd', 'Chicago', 'IL', '60601', 'michael.williams@email.com', '312-555-0103');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('Emily', 'Grace', 'Brown', DATE '1995-05-18', '321 Elm St', 'Los Angeles', 'CA', '90001', 'emily.brown@email.com', '213-555-0104');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('David', 'James', 'Jones', DATE '1982-09-08', '654 Maple Dr', 'Philadelphia', 'PA', '19101', 'david.jones@email.com', '215-555-0105');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('Jennifer', 'Marie', 'Garcia', DATE '1988-12-25', '987 Cedar Ln', 'San Francisco', 'CA', '94101', 'jennifer.garcia@email.com', '415-555-0106');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('Robert', 'Lee', 'Martinez', DATE '1975-04-12', '147 Birch Ct', 'Seattle', 'WA', '98101', 'robert.martinez@email.com', '206-555-0107');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('Lisa', 'Ann', 'Rodriguez', DATE '1992-08-05', '258 Spruce Way', 'Miami', 'FL', '33101', 'lisa.rodriguez@email.com', '305-555-0108');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('James', 'Patrick', 'Wilson', DATE '1980-02-28', '369 Willow Pl', 'Denver', 'CO', '80201', 'james.wilson@email.com', '303-555-0109');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('Mary', 'Elizabeth', 'Anderson', DATE '1987-06-14', '741 Ash Blvd', 'Atlanta', 'GA', '30301', 'mary.anderson@email.com', '404-555-0110');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('William', 'Thomas', 'Taylor', DATE '1993-10-20', '852 Cherry Ave', 'Dallas', 'TX', '75201', 'william.taylor@email.com', '214-555-0111');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('Patricia', NULL, 'Moore', DATE '1979-01-09', '963 Poplar St', 'Houston', 'TX', '77001', 'patricia.moore@email.com', '713-555-0112');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('Charles', 'Edward', 'Jackson', DATE '1991-03-17', '159 Hickory Dr', 'Phoenix', 'AZ', '85001', 'charles.jackson@email.com', '602-555-0113');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('Linda', 'Sue', 'White', DATE '1986-07-23', '357 Sycamore Rd', 'San Diego', 'CA', '92101', 'linda.white@email.com', '619-555-0114');

INSERT INTO crs_admin.CRS_PASSENGER (first_name, middle_name, last_name, date_of_birth, address_line1, address_city, address_state, address_zip, email, phone)
VALUES ('Christopher', 'Alan', 'Harris', DATE '1994-11-11', '486 Redwood Ln', 'Portland', 'OR', '97201', 'christopher.harris@email.com', '503-555-0115');

COMMIT;

-- Populate CRS_RESERVATION (Sample bookings)
-- Mix of CONFIRMED, WAITLISTED, and CANCELLED

-- Train TR001 (New York to Boston) - Future dates
INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (1, 1, DATE '2025-12-05', DATE '2025-11-28', 'FC', 'CONFIRMED', NULL);

INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (2, 1, DATE '2025-12-05', DATE '2025-11-28', 'ECON', 'CONFIRMED', NULL);

INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (3, 1, DATE '2025-12-05', DATE '2025-11-29', 'FC', 'CONFIRMED', NULL);

-- Train TR002 (Chicago to Detroit) - Weekday train
INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (4, 2, DATE '2025-12-01', DATE '2025-11-28', 'ECON', 'CONFIRMED', NULL);

INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (5, 2, DATE '2025-12-01', DATE '2025-11-28', 'FC', 'CONFIRMED', NULL);

-- Train TR003 (LA to San Diego)
INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (6, 3, DATE '2025-12-03', DATE '2025-11-28', 'ECON', 'CONFIRMED', NULL);

INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (7, 3, DATE '2025-12-03', DATE '2025-11-28', 'FC', 'CONFIRMED', NULL);

-- Train TR006 (Seattle to Portland) - Weekend only train
INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (8, 6, DATE '2025-11-30', DATE '2025-11-28', 'ECON', 'CONFIRMED', NULL);

INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (9, 6, DATE '2025-11-30', DATE '2025-11-28', 'FC', 'CONFIRMED', NULL);

-- Waitlisted bookings
INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (10, 1, DATE '2025-12-05', DATE '2025-11-29', 'FC', 'WAITLISTED', 1);

INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (11, 1, DATE '2025-12-05', DATE '2025-11-29', 'FC', 'WAITLISTED', 2);

-- Cancelled bookings
INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (12, 3, DATE '2025-12-02', DATE '2025-11-27', 'ECON', 'CANCELLED', NULL);

INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (13, 2, DATE '2025-12-01', DATE '2025-11-27', 'FC', 'CANCELLED', NULL);

-- More bookings for different trains
INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (14, 7, DATE '2025-12-04', DATE '2025-11-28', 'ECON', 'CONFIRMED', NULL);

INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (15, 10, DATE '2025-12-06', DATE '2025-11-28', 'FC', 'CONFIRMED', NULL);

INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (1, 5, DATE '2025-12-02', DATE '2025-11-28', 'ECON', 'CONFIRMED', NULL);

INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (2, 8, DATE '2025-12-02', DATE '2025-11-28', 'FC', 'CONFIRMED', NULL);

INSERT INTO crs_admin.CRS_RESERVATION (passenger_id, train_id, travel_date, booking_date, seat_class, seat_status, waitlist_position)
VALUES (3, 9, DATE '2025-11-30', DATE '2025-11-28', 'ECON', 'CONFIRMED', NULL);

COMMIT;
/