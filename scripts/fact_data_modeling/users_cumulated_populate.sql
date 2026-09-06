INSERT INTO users_cumulated (user_id, dates_active, `date`)
SELECT * FROM (
    WITH RECURSIVE bounds AS (
        SELECT MIN(DATE(event_time)) AS min_date,
               MAX(DATE(event_time)) AS max_date
        FROM events
        WHERE user_id IS NOT NULL
    ),
    date_series AS (
        SELECT min_date AS valid_date
        FROM bounds

        UNION ALL

        SELECT ds.valid_date + INTERVAL 1 DAY
        FROM date_series ds
        JOIN bounds b
          ON ds.valid_date < b.max_date
    ),
    daily_user_activity AS (
        SELECT DISTINCT
            user_id,
            DATE(event_time) AS date_active
        FROM events
        WHERE user_id IS NOT NULL
    )
    SELECT
        dua.user_id,
        JSON_ARRAYAGG(CAST(dua.date_active AS CHAR)) AS dates_active,
        ds.valid_date AS `date`
    FROM date_series ds
    JOIN daily_user_activity dua
      ON dua.date_active <= ds.valid_date
    GROUP BY dua.user_id, ds.valid_date
) AS new
ON DUPLICATE KEY UPDATE
    dates_active = new.dates_active;