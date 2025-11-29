-- Package Body: PKG_TRAIN
-- Purpose: Implementation of train and schedule management operations
-- Owner: CRS_ADMIN

CREATE OR REPLACE PACKAGE BODY PKG_TRAIN AS

/**
    * Add a new train
    */
FUNCTION add_train(
    p_train_number IN VARCHAR2,
    p_source_station IN VARCHAR2,
    p_dest_station IN VARCHAR2,
    p_total_fc_seats IN NUMBER,
    p_total_econ_seats IN NUMBER,
    p_fc_seat_fare IN NUMBER,
    p_econ_seat_fare IN NUMBER,
    p_error_msg OUT VARCHAR2
) RETURN NUMBER AS
    v_train_id NUMBER;
BEGIN
    -- TODO: Implement add train
    -- 1. Validate required fields
    -- 2. Validate source != destination
    -- 3. Validate seats and fares > 0
    -- 4. Check train_number uniqueness
    -- 5. INSERT into CRS_TRAIN_INFO
    -- 6. Return generated train_id
    -- 7. COMMIT
    
    RETURN -1; -- Placeholder
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        p_error_msg := 'Train number already exists.';
        RETURN -1;
    WHEN OTHERS THEN
        ROLLBACK;
        p_error_msg := 'Error: ' || SQLERRM;
        RETURN -1;
END add_train;

/**
    * Update train details (fare only)
    */
FUNCTION update_train(
    p_train_id IN NUMBER,
    p_fc_seat_fare IN NUMBER,
    p_econ_seat_fare IN NUMBER,
    p_error_msg OUT VARCHAR2
) RETURN BOOLEAN AS
    v_count NUMBER;
BEGIN
    -- TODO: Implement update train
    -- 1. Check if train exists
    -- 2. Validate fares > 0
    -- 3. UPDATE CRS_TRAIN_INFO (only fares)
    -- 4. COMMIT
    -- 5. Return TRUE if successful
    
    RETURN FALSE; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_error_msg := 'Error: ' || SQLERRM;
        RETURN FALSE;
END update_train;

/**
    * Cancel train on specific date
    */
PROCEDURE cancel_train_on_date(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_reason IN VARCHAR2,
    p_bookings_cancelled OUT NUMBER,
    p_success OUT BOOLEAN,
    p_message OUT VARCHAR2
) AS
BEGIN
    -- TODO: Implement train cancellation
    -- 1. Validate train exists
    -- 2. Validate train operates on this date
    -- 3. UPDATE all bookings for this train/date to CANCELLED
    -- 4. Set cancellation_reason (if column exists)
    -- 5. Count rows updated
    -- 6. COMMIT
    
    p_bookings_cancelled := 0; -- Placeholder
    p_success := FALSE;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_success := FALSE;
        p_message := 'Error: ' || SQLERRM;
END cancel_train_on_date;

/**
    * Mark train schedule as inactive (soft delete)
    */
PROCEDURE deactivate_train(
    p_train_id IN NUMBER,
    p_success OUT BOOLEAN,
    p_error_msg OUT VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    -- TODO: Implement deactivate train
    -- 1. Check if train exists
    -- 2. UPDATE CRS_TRAIN_SCHEDULE set is_in_service = 'N'
    --    for all schedules of this train
    -- 3. COMMIT
    
    p_success := FALSE; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_success := FALSE;
        p_error_msg := 'Error: ' || SQLERRM;
END deactivate_train;

/**
    * Search train by train number
    */
FUNCTION search_train_by_number(
    p_train_number IN VARCHAR2
) RETURN NUMBER AS
    v_train_id NUMBER;
BEGIN
    -- TODO: Implement train search
    -- 1. SELECT train_id from CRS_TRAIN_INFO
    --    WHERE train_number = p_train_number
    -- 2. Return train_id if found, NULL otherwise
    
    RETURN NULL; -- Placeholder
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END search_train_by_number;

/**
    * Add train to schedule for a single day
    */
PROCEDURE add_train_to_schedule(
    p_train_id IN NUMBER,
    p_sch_id IN NUMBER,
    p_success OUT BOOLEAN,
    p_error_msg OUT VARCHAR2
) AS
    v_train_count NUMBER;
    v_sch_count NUMBER;
    v_exists NUMBER;
BEGIN
    -- TODO: Implement add to schedule
    -- 1. Check if train exists
    -- 2. Check if schedule ID exists
    -- 3. Check if already exists in CRS_TRAIN_SCHEDULE
    -- 4. INSERT into CRS_TRAIN_SCHEDULE with is_in_service='Y'
    -- 5. COMMIT
    
    p_success := FALSE; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_success := FALSE;
        p_error_msg := 'Error: ' || SQLERRM;
END add_train_to_schedule;

/**
    * Remove train from schedule for a single day
    */
PROCEDURE remove_train_from_schedule(
    p_train_id IN NUMBER,
    p_sch_id IN NUMBER,
    p_success OUT BOOLEAN,
    p_error_msg OUT VARCHAR2
) AS
BEGIN
    -- TODO: Implement remove from schedule
    -- 1. DELETE from CRS_TRAIN_SCHEDULE
    --    WHERE train_id = p_train_id AND sch_id = p_sch_id
    -- 2. Check if any rows deleted
    -- 3. COMMIT
    
    p_success := FALSE; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_success := FALSE;
        p_error_msg := 'Error: ' || SQLERRM;
END remove_train_from_schedule;

/**
    * Check if train operates on specific date
    */
FUNCTION is_train_operating(
    p_train_id IN NUMBER,
    p_travel_date IN DATE
) RETURN BOOLEAN AS
    v_count NUMBER;
    v_day_of_week VARCHAR2(10);
BEGIN
    -- TODO: Implement operating check
    -- 1. Get day_of_week from p_travel_date using TO_CHAR(p_travel_date, 'Day')
    -- 2. Join CRS_TRAIN_SCHEDULE with CRS_DAY_SCHEDULE
    -- 3. Check if train_id exists for that day with is_in_service='Y'
    -- 4. Return TRUE if exists, FALSE otherwise
    
    RETURN FALSE; -- Placeholder
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END is_train_operating;

END PKG_TRAIN;
/