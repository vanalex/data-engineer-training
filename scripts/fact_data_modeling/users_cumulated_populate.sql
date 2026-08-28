INSERT INTO users_cumulated (user_id, dates_active, date)
WITH RECURSIVE date_series AS (
    SELECT MIN(DATE(event_time)) AS date
    FROM events
    WHERE user_id IS NOT NULL

    UNION ALL

    SELECT DATE_ADD(date, INTERVAL 1 DAY)
    FROM date_series
    WHERE date < (
        SELECT MAX(DATE(event_time))
        FROM events
        WHERE user_id IS NOT NULL
    )
),
daily_user_activity AS (
    SELECT DISTINCT
        user_id,
        DATE(event_time) AS date_active
    FROM events
    WHERE user_id IS NOT NULL
),
user_first_activity AS (
    SELECT
        user_id,
        MIN(date_active) AS first_active_date
    FROM daily_user_activity
    GROUP BY user_id
)
SELECT
    ufa.user_id,
    CAST(
        CONCAT(
            '[',
            GROUP_CONCAT(JSON_QUOTE(CAST(dua.date_active AS CHAR)) ORDER BY dua.date_active),
            ']'
        ) AS JSON
    ) AS dates_active,
    ds.date
FROM date_series ds
JOIN user_first_activity ufa
    ON ufa.first_active_date <= ds.date
JOIN daily_user_activity dua
    ON dua.user_id = ufa.user_id
   AND dua.date_active <= ds.date
GROUP BY ufa.user_id, ds.date
ON DUPLICATE KEY UPDATE
    dates_active = VALUES(dates_active);
