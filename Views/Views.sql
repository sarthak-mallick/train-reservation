-- Views: CRS Report Views
-- Purpose: Create reporting views for analytics
-- Owner: CRS_ADMIN

-- ============================================================
-- VIEW 1: VW_TRAIN_OCCUPANCY
-- Purpose: Analyze seat utilization and revenue optimization
-- ============================================================
CREATE OR REPLACE VIEW VW_TRAIN_OCCUPANCY AS
SELECT 
    t.train_number,
    t.source_station || ' -> ' || t.dest_station AS route,
    r.travel_date,
    -- Total seats by class
    t.total_fc_seats,
    t.total_econ_seats,
    -- Confirmed bookings by class
    COUNT(CASE WHEN r.seat_class = 'FC' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS fc_confirmed,
    COUNT(CASE WHEN r.seat_class = 'ECON' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS econ_confirmed,
    -- Available seats by class
    t.total_fc_seats - COUNT(CASE WHEN r.seat_class = 'FC' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS fc_available,
    t.total_econ_seats - COUNT(CASE WHEN r.seat_class = 'ECON' AND r.seat_status = 'CONFIRMED' THEN 1 END) AS econ_available,
    -- Waitlist count by class
    COUNT(CASE WHEN r.seat_class = 'FC' AND r.seat_status = 'WAITLISTED' THEN 1 END) AS fc_waitlisted,
    COUNT(CASE WHEN r.seat_class = 'ECON' AND r.seat_status = 'WAITLISTED' THEN 1 END) AS econ_waitlisted,
    -- Occupancy percentage by class
    ROUND(COUNT(CASE WHEN r.seat_class = 'FC' AND r.seat_status = 'CONFIRMED' THEN 1 END) / t.total_fc_seats * 100, 2) AS fc_occupancy_pct,
    ROUND(COUNT(CASE WHEN r.seat_class = 'ECON' AND r.seat_status = 'CONFIRMED' THEN 1 END) / t.total_econ_seats * 100, 2) AS econ_occupancy_pct,
    -- Revenue potential
    COUNT(CASE WHEN r.seat_class = 'FC' AND r.seat_status = 'CONFIRMED' THEN 1 END) * t.fc_seat_fare AS fc_revenue,
    COUNT(CASE WHEN r.seat_class = 'ECON' AND r.seat_status = 'CONFIRMED' THEN 1 END) * t.econ_seat_fare AS econ_revenue,
    (COUNT(CASE WHEN r.seat_class = 'FC' AND r.seat_status = 'CONFIRMED' THEN 1 END) * t.fc_seat_fare) +
    (COUNT(CASE WHEN r.seat_class = 'ECON' AND r.seat_status = 'CONFIRMED' THEN 1 END) * t.econ_seat_fare) AS total_revenue
FROM 
    CRS_TRAIN_INFO t
LEFT JOIN 
    CRS_RESERVATION r ON t.train_id = r.train_id
GROUP BY 
    t.train_number, t.source_station, t.dest_station, r.travel_date,
    t.total_fc_seats, t.total_econ_seats, t.fc_seat_fare, t.econ_seat_fare
ORDER BY 
    r.travel_date, t.train_number;
/

-- ============================================================
-- VIEW 2: VW_WAITLIST_ANALYSIS
-- Purpose: Understand waitlist patterns and conversion rates
-- ============================================================
CREATE OR REPLACE VIEW VW_WAITLIST_ANALYSIS AS
SELECT 
    t.train_number,
    t.source_station || ' -> ' || t.dest_station AS route,
    r.travel_date,
    -- Total waitlisted by class
    COUNT(CASE WHEN r.seat_class = 'FC' AND r.seat_status = 'WAITLISTED' THEN 1 END) AS fc_waitlisted,
    COUNT(CASE WHEN r.seat_class = 'ECON' AND r.seat_status = 'WAITLISTED' THEN 1 END) AS econ_waitlisted,
    COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) AS total_waitlisted,
    -- Average wait position
    ROUND(AVG(CASE WHEN r.seat_status = 'WAITLISTED' THEN r.waitlist_position END), 1) AS avg_wait_position,
    -- Max wait position
    MAX(CASE WHEN r.seat_status = 'WAITLISTED' THEN r.waitlist_position END) AS max_wait_position,
    -- Earliest waitlist booking date (longest waiting)
    MIN(CASE WHEN r.seat_status = 'WAITLISTED' THEN r.booking_date END) AS longest_waiting_since,
    -- Total confirmed
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS total_confirmed,
    -- Total cancelled
    COUNT(CASE WHEN r.seat_status = 'CANCELLED' THEN 1 END) AS total_cancelled,
    -- Historical promotion rate (cancelled / total bookings indicates potential promotions)
    CASE 
        WHEN COUNT(CASE WHEN r.seat_status = 'CANCELLED' THEN 1 END) > 0 
             AND COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) > 0 THEN
            ROUND(COUNT(CASE WHEN r.seat_status = 'CANCELLED' THEN 1 END) / 
                  NULLIF(COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END), 0) * 100, 2)
        ELSE 0 
    END AS historical_promotion_rate,
    -- High waitlist flag
    CASE 
        WHEN COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) >= 5 THEN 'Y'
        ELSE 'N'
    END AS high_waitlist_flag,
    -- Recommended capacity increase
    CASE 
        WHEN COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) >= 10 THEN 'HIGH - Add 20+ seats'
        WHEN COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) >= 5 THEN 'MEDIUM - Add 10 seats'
        WHEN COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) >= 2 THEN 'LOW - Add 5 seats'
        ELSE 'NONE'
    END AS recommended_capacity_increase
FROM 
    CRS_TRAIN_INFO t
LEFT JOIN 
    CRS_RESERVATION r ON t.train_id = r.train_id
GROUP BY 
    t.train_number, t.source_station, t.dest_station, r.travel_date
ORDER BY 
    total_waitlisted DESC, r.travel_date;
/

-- ============================================================
-- VIEW 3: VW_PASSENGER_BOOKING_HISTORY
-- Purpose: Analyze passenger behavior and loyalty
-- ============================================================
CREATE OR REPLACE VIEW VW_PASSENGER_BOOKING_HISTORY AS
SELECT 
    p.passenger_id,
    p.first_name || ' ' || NVL(p.middle_name || ' ', '') || p.last_name AS passenger_name,
    p.email,
    p.phone,
    -- Total bookings
    COUNT(r.booking_id) AS total_bookings,
    -- Confirmed bookings
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS confirmed_bookings,
    -- Cancelled bookings
    COUNT(CASE WHEN r.seat_status = 'CANCELLED' THEN 1 END) AS cancelled_bookings,
    -- Cancellation rate
    CASE 
        WHEN COUNT(r.booking_id) > 0 THEN
            ROUND(COUNT(CASE WHEN r.seat_status = 'CANCELLED' THEN 1 END) / COUNT(r.booking_id) * 100, 2)
        ELSE 0 
    END AS cancellation_rate,
    -- Preferred class
    CASE 
        WHEN COUNT(CASE WHEN r.seat_class = 'FC' THEN 1 END) > COUNT(CASE WHEN r.seat_class = 'ECON' THEN 1 END) 
        THEN 'FC'
        WHEN COUNT(CASE WHEN r.seat_class = 'ECON' THEN 1 END) > COUNT(CASE WHEN r.seat_class = 'FC' THEN 1 END) 
        THEN 'ECON'
        ELSE 'NO PREFERENCE'
    END AS preferred_class,
    -- FC vs ECON count
    COUNT(CASE WHEN r.seat_class = 'FC' THEN 1 END) AS fc_bookings,
    COUNT(CASE WHEN r.seat_class = 'ECON' THEN 1 END) AS econ_bookings,
    -- Preferred route (most booked)
    (SELECT t2.source_station || ' -> ' || t2.dest_station 
     FROM CRS_RESERVATION r2 
     JOIN CRS_TRAIN_INFO t2 ON r2.train_id = t2.train_id
     WHERE r2.passenger_id = p.passenger_id
     GROUP BY t2.source_station, t2.dest_station
     ORDER BY COUNT(*) DESC
     FETCH FIRST 1 ROW ONLY) AS preferred_route,
    -- First booking date
    MIN(r.booking_date) AS first_booking_date,
    -- Last booking date
    MAX(r.booking_date) AS last_booking_date,
    -- Booking frequency per month
    CASE 
        WHEN MONTHS_BETWEEN(MAX(r.booking_date), MIN(r.booking_date)) > 0 THEN
            ROUND(COUNT(r.booking_id) / MONTHS_BETWEEN(MAX(r.booking_date), MIN(r.booking_date)), 2)
        ELSE COUNT(r.booking_id)
    END AS bookings_per_month,
    -- Average advance booking days
    ROUND(AVG(r.travel_date - r.booking_date), 1) AS avg_advance_booking_days,
    -- Customer segment
    CASE 
        WHEN COUNT(r.booking_id) >= 10 THEN 'FREQUENT'
        WHEN COUNT(r.booking_id) >= 3 THEN 'OCCASIONAL'
        WHEN COUNT(r.booking_id) >= 1 THEN 'ONE-TIME'
        ELSE 'NEW'
    END AS customer_segment
FROM 
    CRS_PASSENGER p
LEFT JOIN 
    CRS_RESERVATION r ON p.passenger_id = r.passenger_id
GROUP BY 
    p.passenger_id, p.first_name, p.middle_name, p.last_name, p.email, p.phone
ORDER BY 
    total_bookings DESC;
/

-- ============================================================
-- VIEW 4: VW_MONTHLY_REVENUE_TRENDS
-- Purpose: Financial performance tracking and forecasting
-- ============================================================
CREATE OR REPLACE VIEW VW_MONTHLY_REVENUE_TRENDS AS
SELECT 
    year,
    month,
    month_name,
    total_bookings,
    confirmed_bookings,
    total_revenue,
    fc_revenue,
    econ_revenue,
    avg_booking_value,
    -- Revenue growth percentage (month-over-month)
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY year, month)) / 
        NULLIF(LAG(total_revenue) OVER (ORDER BY year, month), 0) * 100, 2
    ) AS revenue_growth_pct,
    -- Bookings growth percentage (month-over-month)
    ROUND(
        (total_bookings - LAG(total_bookings) OVER (ORDER BY year, month)) / 
        NULLIF(LAG(total_bookings) OVER (ORDER BY year, month), 0) * 100, 2
    ) AS bookings_growth_pct,
    peak_revenue_day,
    lowest_revenue_day,
    weekday_revenue,
    weekend_revenue,
    cancellation_loss,
    -- Forecast next month (simple: current + growth trend)
    ROUND(
        total_revenue * (1 + NVL(
            (total_revenue - LAG(total_revenue) OVER (ORDER BY year, month)) / 
            NULLIF(LAG(total_revenue) OVER (ORDER BY year, month), 0), 0
        )), 2
    ) AS forecast_next_month
FROM (
    SELECT 
        EXTRACT(YEAR FROM r.travel_date) AS year,
        EXTRACT(MONTH FROM r.travel_date) AS month,
        TRIM(TO_CHAR(r.travel_date, 'Month')) AS month_name,
        -- Total bookings
        COUNT(r.booking_id) AS total_bookings,
        COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS confirmed_bookings,
        -- Total revenue (confirmed only)
        NVL(SUM(CASE WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'FC' THEN t.fc_seat_fare
                     WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'ECON' THEN t.econ_seat_fare
                     ELSE 0 END), 0) AS total_revenue,
        -- FC revenue
        NVL(SUM(CASE WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'FC' THEN t.fc_seat_fare ELSE 0 END), 0) AS fc_revenue,
        -- ECON revenue
        NVL(SUM(CASE WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'ECON' THEN t.econ_seat_fare ELSE 0 END), 0) AS econ_revenue,
        -- Average booking value
        ROUND(NVL(AVG(CASE WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'FC' THEN t.fc_seat_fare
                           WHEN r.seat_status = 'CONFIRMED' AND r.seat_class = 'ECON' THEN t.econ_seat_fare END), 0), 2) AS avg_booking_value,
        -- Peak revenue day
        (SELECT EXTRACT(DAY FROM r2.travel_date)
         FROM CRS_RESERVATION r2
         JOIN CRS_TRAIN_INFO t2 ON r2.train_id = t2.train_id
         WHERE EXTRACT(YEAR FROM r2.travel_date) = EXTRACT(YEAR FROM r.travel_date)
           AND EXTRACT(MONTH FROM r2.travel_date) = EXTRACT(MONTH FROM r.travel_date)
           AND r2.seat_status = 'CONFIRMED'
         GROUP BY EXTRACT(DAY FROM r2.travel_date)
         ORDER BY SUM(CASE WHEN r2.seat_class = 'FC' THEN t2.fc_seat_fare ELSE t2.econ_seat_fare END) DESC
         FETCH FIRST 1 ROW ONLY) AS peak_revenue_day,
        -- Lowest revenue day
        (SELECT EXTRACT(DAY FROM r2.travel_date)
         FROM CRS_RESERVATION r2
         JOIN CRS_TRAIN_INFO t2 ON r2.train_id = t2.train_id
         WHERE EXTRACT(YEAR FROM r2.travel_date) = EXTRACT(YEAR FROM r.travel_date)
           AND EXTRACT(MONTH FROM r2.travel_date) = EXTRACT(MONTH FROM r.travel_date)
           AND r2.seat_status = 'CONFIRMED'
         GROUP BY EXTRACT(DAY FROM r2.travel_date)
         ORDER BY SUM(CASE WHEN r2.seat_class = 'FC' THEN t2.fc_seat_fare ELSE t2.econ_seat_fare END) ASC
         FETCH FIRST 1 ROW ONLY) AS lowest_revenue_day,
        -- Weekday revenue
        NVL(SUM(CASE WHEN r.seat_status = 'CONFIRMED' 
                     AND TO_CHAR(r.travel_date, 'DY') NOT IN ('SAT', 'SUN')
                     THEN CASE WHEN r.seat_class = 'FC' THEN t.fc_seat_fare ELSE t.econ_seat_fare END
                     ELSE 0 END), 0) AS weekday_revenue,
        -- Weekend revenue
        NVL(SUM(CASE WHEN r.seat_status = 'CONFIRMED' 
                     AND TO_CHAR(r.travel_date, 'DY') IN ('SAT', 'SUN')
                     THEN CASE WHEN r.seat_class = 'FC' THEN t.fc_seat_fare ELSE t.econ_seat_fare END
                     ELSE 0 END), 0) AS weekend_revenue,
        -- Cancellation loss
        NVL(SUM(CASE WHEN r.seat_status = 'CANCELLED' AND r.seat_class = 'FC' THEN t.fc_seat_fare
                     WHEN r.seat_status = 'CANCELLED' AND r.seat_class = 'ECON' THEN t.econ_seat_fare
                     ELSE 0 END), 0) AS cancellation_loss
    FROM 
        CRS_RESERVATION r
    JOIN 
        CRS_TRAIN_INFO t ON r.train_id = t.train_id
    GROUP BY 
        EXTRACT(YEAR FROM r.travel_date),
        EXTRACT(MONTH FROM r.travel_date),
        TRIM(TO_CHAR(r.travel_date, 'Month'))
)
ORDER BY 
    year, month;
/

-- ============================================================
-- VIEW 5: VW_PEAK_TRAVEL_PATTERNS
-- Purpose: Understand demand patterns by time, day, and season
-- ============================================================
CREATE OR REPLACE VIEW VW_PEAK_TRAVEL_PATTERNS AS
SELECT 
    travel_day_of_week,
    day_number,
    travel_week_number,
    travel_month,
    travel_month_name,
    is_weekend,
    total_bookings,
    confirmed_bookings,
    fc_bookings,
    econ_bookings,
    -- Average daily bookings
    ROUND(total_bookings / NULLIF(day_count, 0), 2) AS avg_daily_bookings,
    -- Business route bookings (weekday-heavy routes)
    business_route_bookings,
    -- Leisure route bookings (weekend-heavy routes)
    leisure_route_bookings,
    advance_booking_rate,
    last_minute_rate,
    -- Occupancy rate
    ROUND(confirmed_bookings / NULLIF(total_seats, 0) * 100, 2) AS occupancy_rate,
    demand_intensity,
    pricing_recommendation
FROM (
    SELECT 
        TO_CHAR(r.travel_date, 'Day') AS travel_day_of_week,
        TO_NUMBER(TO_CHAR(r.travel_date, 'D')) AS day_number,
        TO_NUMBER(TO_CHAR(r.travel_date, 'IW')) AS travel_week_number,
        EXTRACT(MONTH FROM r.travel_date) AS travel_month,
        TRIM(TO_CHAR(r.travel_date, 'Month')) AS travel_month_name,
        CASE WHEN TO_CHAR(r.travel_date, 'DY') IN ('SAT', 'SUN') THEN 'Y' ELSE 'N' END AS is_weekend,
        COUNT(r.booking_id) AS total_bookings,
        COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS confirmed_bookings,
        COUNT(CASE WHEN r.seat_class = 'FC' THEN 1 END) AS fc_bookings,
        COUNT(CASE WHEN r.seat_class = 'ECON' THEN 1 END) AS econ_bookings,
        COUNT(DISTINCT r.travel_date) AS day_count,
        -- Business route bookings (trains running on weekdays)
        COUNT(CASE WHEN EXISTS (
            SELECT 1 FROM CRS_TRAIN_SCHEDULE ts 
            JOIN CRS_DAY_SCHEDULE ds ON ts.sch_id = ds.sch_id 
            WHERE ts.train_id = r.train_id AND ds.is_week_end = 'N' AND ts.is_in_service = 'Y'
        ) THEN 1 END) AS business_route_bookings,
        -- Leisure route bookings (trains running on weekends)
        COUNT(CASE WHEN EXISTS (
            SELECT 1 FROM CRS_TRAIN_SCHEDULE ts 
            JOIN CRS_DAY_SCHEDULE ds ON ts.sch_id = ds.sch_id 
            WHERE ts.train_id = r.train_id AND ds.is_week_end = 'Y' AND ts.is_in_service = 'Y'
        ) THEN 1 END) AS leisure_route_bookings,
        -- Advance booking rate
        ROUND(COUNT(CASE WHEN (r.travel_date - r.booking_date) > 3 THEN 1 END) / 
              NULLIF(COUNT(r.booking_id), 0) * 100, 2) AS advance_booking_rate,
        -- Last minute rate
        ROUND(COUNT(CASE WHEN (r.travel_date - r.booking_date) <= 1 THEN 1 END) / 
              NULLIF(COUNT(r.booking_id), 0) * 100, 2) AS last_minute_rate,
        -- Total seats for occupancy calculation
        (SELECT SUM(total_fc_seats + total_econ_seats) FROM CRS_TRAIN_INFO) AS total_seats,
        -- Demand intensity
        CASE 
            WHEN COUNT(r.booking_id) >= 20 THEN 'HIGH'
            WHEN COUNT(r.booking_id) >= 10 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS demand_intensity,
        -- Pricing recommendation
        CASE 
            WHEN COUNT(r.booking_id) >= 20 THEN 'INCREASE'
            WHEN COUNT(r.booking_id) >= 10 THEN 'MAINTAIN'
            ELSE 'DECREASE'
        END AS pricing_recommendation
    FROM 
        CRS_RESERVATION r
    GROUP BY 
        TO_CHAR(r.travel_date, 'Day'),
        TO_NUMBER(TO_CHAR(r.travel_date, 'D')),
        TO_NUMBER(TO_CHAR(r.travel_date, 'IW')),
        EXTRACT(MONTH FROM r.travel_date),
        TRIM(TO_CHAR(r.travel_date, 'Month')),
        CASE WHEN TO_CHAR(r.travel_date, 'DY') IN ('SAT', 'SUN') THEN 'Y' ELSE 'N' END
)
ORDER BY 
    travel_month, day_number;
/

-- Grant SELECT on views to roles
GRANT SELECT ON VW_TRAIN_OCCUPANCY TO crs_report_role;
GRANT SELECT ON VW_WAITLIST_ANALYSIS TO crs_report_role;
GRANT SELECT ON VW_PASSENGER_BOOKING_HISTORY TO crs_report_role;
GRANT SELECT ON VW_MONTHLY_REVENUE_TRENDS TO crs_report_role;
GRANT SELECT ON VW_PEAK_TRAVEL_PATTERNS TO crs_report_role;

GRANT SELECT ON VW_TRAIN_OCCUPANCY TO crs_operations_role;
GRANT SELECT ON VW_WAITLIST_ANALYSIS TO crs_operations_role;
GRANT SELECT ON VW_PEAK_TRAVEL_PATTERNS TO crs_operations_role;

-- Verify views created
SELECT view_name FROM user_views ORDER BY view_name;
/