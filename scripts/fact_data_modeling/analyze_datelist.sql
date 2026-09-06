WITH RECURSIVE d (valid_date) AS (
    SELECT DATE('2023-02-28')
    UNION ALL
    SELECT valid_date + INTERVAL 1 DAY
    FROM d
    WHERE valid_date < DATE('2023-03-31')
),
starter AS (
    SELECT
        uc.user_id,
        JSON_CONTAINS(uc.dates_active, JSON_QUOTE(CAST(d.valid_date AS CHAR))) AS is_active,
        DATEDIFF(DATE('2023-03-31'), d.valid_date) AS days_since
    FROM users_cumulated uc
    CROSS JOIN d
    WHERE uc.`date` = DATE('2023-03-31')
),
bits AS (
    SELECT
        user_id,
        CAST(SUM(CASE WHEN is_active THEN 1 << (32 - days_since) ELSE 0 END) AS UNSIGNED)
            & 4294967295 AS datelist_int          -- & 0xFFFFFFFF, i.e. ::bit(32)
    FROM starter
    GROUP BY user_id
)
SELECT
    user_id,
    LPAD(BIN(datelist_int), 32, '0') AS datelist_int,
    BIT_COUNT(datelist_int) > 0 AS monthly_active,
    BIT_COUNT(datelist_int) AS l32,
    BIT_COUNT(datelist_int & 4261412864) > 0 AS weekly_active,               -- 11111110...
    BIT_COUNT(datelist_int & 4261412864) AS l7,
    BIT_COUNT(datelist_int & 33292288) > 0 AS weekly_active_previous_week    -- 00000001111111...
FROM bits;