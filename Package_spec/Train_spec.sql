-- Package: PKG_TRAIN
-- Purpose: Manage train information and schedules
-- Owner: CRS_ADMIN

CREATE OR REPLACE PACKAGE PKG_TRAIN AS

/**
    * Add a new train
    * @return train_id if successful, -1 if error
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
) RETURN NUMBER;

/**
* Update train fare
* @return TRUE if successful, FALSE otherwise
*/
FUNCTION update_fare(
    p_train_id IN NUMBER,
    p_fc_seat_fare IN NUMBER,
    p_econ_seat_fare IN NUMBER,
    p_error_msg OUT VARCHAR2
) RETURN BOOLEAN;

/**
 * Cancel train on specific date
 * Marks all bookings as cancelled for that train/date
 * Does NOT automatically rebook passengers (manual intervention required)
 * @param p_reason Cancellation reason (e.g., 'Weather', 'Maintenance')
 */
PROCEDURE cancel_train_on_date(
    p_train_id IN NUMBER,
    p_travel_date IN DATE,
    p_reason IN VARCHAR2,
    p_bookings_cancelled OUT NUMBER,
    p_success OUT BOOLEAN,
    p_message OUT VARCHAR2
);

/**
 * Add train to schedule for a single day
 * @param p_sch_id The schedule ID (1-7 for Mon-Sun)
 */
PROCEDURE add_train_to_schedule(
    p_train_id IN NUMBER,
    p_sch_id IN NUMBER,
    p_success OUT BOOLEAN,
    p_error_msg OUT VARCHAR2
);

/**
 * Remove train from schedule for a single day
 * @param p_sch_id The schedule ID (1-7 for Mon-Sun)
 */
PROCEDURE remove_train_from_schedule(
    p_train_id IN NUMBER,
    p_sch_id IN NUMBER,
    p_success OUT BOOLEAN,
    p_error_msg OUT VARCHAR2
);

END PKG_TRAIN;
/