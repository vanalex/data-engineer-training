INSERT INTO monthly_user_site_hits
    (user_id, hit_array, month_start, first_found_date, date_partition)
WITH yesterday AS (
    SELECT *
    FROM monthly_user_site_hits
    WHERE date_partition = DATE('2023-03-02')
),
today AS (
    SELECT
        user_id,
        DATE(event_time) AS today_date,
        COUNT(1) AS num_hits
    FROM events
    WHERE event_time >= DATE('2023-03-03')
      AND event_time <  DATE('2023-03-03') + INTERVAL 1 DAY
      AND user_id IS NOT NULL
    GROUP BY user_id, DATE(event_time)
)

-- users active today (matched or brand new)
SELECT
    t.user_id,
    JSON_MERGE_PRESERVE(
        COALESCE(
            y.hit_array,
            CAST(CONCAT('[',
                        TRIM(TRAILING ',' FROM
                             REPEAT('null,', DATEDIFF(DATE('2023-03-03'),
                                                      DATE('2023-03-01')))),
                        ']') AS JSON)
        ),
        JSON_ARRAY(t.num_hits)
    ) AS hit_array,
    DATE('2023-03-01') AS month_start,
    COALESCE(LEAST(y.first_found_date, t.today_date),
             y.first_found_date,
             t.today_date) AS first_found_date,
    DATE('2023-03-03') AS date_partition
FROM today t
LEFT JOIN yesterday y
       ON y.user_id = t.user_id

UNION ALL

-- users in yesterday's snapshot with no hits today
SELECT
    y.user_id,
    JSON_MERGE_PRESERVE(y.hit_array, JSON_ARRAY(NULL)) AS hit_array,
    DATE('2023-03-01'),
    y.first_found_date,
    DATE('2023-03-03')
FROM yesterday y
WHERE NOT EXISTS (
    SELECT 1 FROM today t WHERE t.user_id = y.user_id
);