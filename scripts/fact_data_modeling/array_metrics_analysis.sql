INSERT INTO array_metrics (user_id, month_start, metric_name, metric_array)
SELECT * FROM (
    WITH daily_aggregate AS (
        SELECT
            user_id,
            DATE(event_time) AS date_active,
            COUNT(1) AS num_site_hits
        FROM events
        WHERE event_time >= DATE('2023-01-01')
          AND event_time <  DATE('2023-01-01') + INTERVAL 1 DAY
          AND user_id IS NOT NULL
        GROUP BY user_id, DATE(event_time)
    ),
    yesterday_array AS (
        SELECT *
        FROM array_metrics
        WHERE month_start = DATE('2023-01-01')
    )

    -- left side of the FULL OUTER JOIN
    SELECT
        da.user_id,
        COALESCE(ya.month_start,
                 da.date_active - INTERVAL (DAYOFMONTH(da.date_active) - 1) DAY) AS month_start,
        'site_hits' AS metric_name,
        CASE
            WHEN ya.metric_array IS NOT NULL
                THEN JSON_ARRAY_APPEND(ya.metric_array, '$', da.num_site_hits)
            ELSE CAST(CONCAT('[',
                             REPEAT('0,', DAYOFMONTH(da.date_active) - 1),
                             da.num_site_hits,
                             ']') AS JSON)
        END AS metric_array
    FROM daily_aggregate da
    LEFT JOIN yesterday_array ya
           ON ya.user_id = da.user_id

    UNION ALL

    -- rows present only on the right side
    SELECT
        ya.user_id,
        ya.month_start,
        'site_hits',
        JSON_ARRAY_APPEND(ya.metric_array, '$', 0)
    FROM yesterday_array ya
    WHERE NOT EXISTS (
        SELECT 1 FROM daily_aggregate da WHERE da.user_id = ya.user_id
    )
) AS new
ON DUPLICATE KEY UPDATE
    metric_array = new.metric_array;