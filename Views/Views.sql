-- Views: CRS Report Views
-- Purpose: Create reporting views for analytics
-- Owner: CRS_ADMIN

-- VIEW 1: VW_TRAIN_OCCUPANCY
-- Purpose: Analyze seat utilization and revenue
CREATE OR REPLACE VIEW VW_TRAIN_OCCUPANCY AS
SELECT 
    t.train_number,
    t.source_station || ' -> ' || t.dest_station AS route,
    r.travel_date,
    t.total_fc_seats,
    t.total_econ_seats,
    COUNT(CASE WHEN r.seat_class = 'FC' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS fc_confirmed,
    COUNT(CASE WHEN r.seat_class = 'ECON' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS econ_confirmed,
    t.total_fc_seats - COUNT(CASE WHEN r.seat_class = 'FC' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS fc_available,
    t.total_econ_seats - COUNT(CASE WHEN r.seat_class = 'ECON' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS econ_available,
    COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) AS waitlist_count,
    ROUND(COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) / (t.total_fc_seats + t.total_econ_seats) * 100, 2) AS occupancy_pct,
    SUM(CASE WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'FC' THEN t.fc_seat_fare
             WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'ECON' THEN t.econ_seat_fare
             ELSE 0 END) AS total_revenue
FROM 
    CRS_TRAIN_INFO t
LEFT JOIN 
    CRS_RESERVATION r ON t.train_id = r.train_id
LEFT JOIN
    CRS_TRAIN_SCHEDULE ts ON t.train_id = ts.train_id
LEFT JOIN
    CRS_DAY_SCHEDULE ds ON ts.sch_id = ds.sch_id
GROUP BY 
    t.train_number, t.source_station, t.dest_station, r.travel_date,
    t.total_fc_seats, t.total_econ_seats, t.fc_seat_fare, t.econ_seat_fare;
/

-- VIEW 2: VW_WAITLIST_SUMMARY
-- Purpose: Quick overview of waitlisted bookings
CREATE OR REPLACE VIEW VW_WAITLIST_SUMMARY AS
SELECT 
    t.train_number,
    t.source_station || ' -> ' || t.dest_station AS route,
    r.travel_date,
    r.seat_class,
    COUNT(r.booking_id) AS waitlist_count,
    MIN(r.waitlist_position) AS first_position,
    MAX(r.waitlist_position) AS last_position
FROM 
    CRS_RESERVATION r
JOIN 
    CRS_TRAIN_INFO t ON r.train_id = t.train_id
WHERE 
    r.seat_status = 'WAITLISTED'
GROUP BY 
    t.train_number, t.source_station, t.dest_station, r.travel_date, r.seat_class;
/

-- VIEW 3: VW_PASSENGER_BOOKINGS
-- Purpose: Passenger booking summary
CREATE OR REPLACE VIEW VW_PASSENGER_BOOKINGS AS
SELECT 
    p.passenger_id,
    p.first_name || ' ' || p.last_name AS passenger_name,
    p.email,
    p.phone,
    COUNT(r.booking_id) AS total_bookings,
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS confirmed,
    COUNT(CASE WHEN r.seat_status = 'CANCELLED' THEN 1 END) AS cancelled,
    COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) AS waitlisted
FROM 
    CRS_PASSENGER p
LEFT JOIN 
    CRS_RESERVATION r ON p.passenger_id = r.passenger_id
GROUP BY 
    p.passenger_id, p.first_name, p.last_name, p.email, p.phone;
/

-- VIEW 4: VW_REVENUE_BY_TRAIN
-- Purpose: Revenue summary per train
CREATE OR REPLACE VIEW VW_REVENUE_BY_TRAIN AS
SELECT 
    t.train_number,
    t.source_station || ' -> ' || t.dest_station AS route,
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS total_confirmed,
    SUM(CASE WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'FC' THEN t.fc_seat_fare ELSE 0 END) AS fc_revenue,
    SUM(CASE WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'ECON' THEN t.econ_seat_fare ELSE 0 END) AS econ_revenue,
    SUM(CASE WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'FC' THEN t.fc_seat_fare
             WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'ECON' THEN t.econ_seat_fare
             ELSE 0 END) AS total_revenue
FROM 
    CRS_TRAIN_INFO t
LEFT JOIN 
    CRS_RESERVATION r ON t.train_id = r.train_id
GROUP BY 
    t.train_number, t.source_station, t.dest_station;
/

-- VIEW 5: VW_BOOKING_STATUS_SUMMARY
-- Purpose: Overall booking status counts
CREATE OR REPLACE VIEW VW_BOOKING_STATUS_SUMMARY AS
SELECT 
    travel_date,
    seat_class,
    seat_status,
    COUNT(booking_id) AS booking_count
FROM 
    CRS_RESERVATION
GROUP BY 
    travel_date, seat_class, seat_status
ORDER BY 
    travel_date, seat_class;
/

-- Grant SELECT on views to roles
GRANT SELECT ON VW_TRAIN_OCCUPANCY TO crs_report_role;
GRANT SELECT ON VW_WAITLIST_SUMMARY TO crs_report_role;
GRANT SELECT ON VW_PASSENGER_BOOKINGS TO crs_report_role;
GRANT SELECT ON VW_REVENUE_BY_TRAIN TO crs_report_role;
GRANT SELECT ON VW_BOOKING_STATUS_SUMMARY TO crs_report_role;
