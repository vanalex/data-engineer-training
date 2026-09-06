INSERT INTO user_datelist_int (user_id, datelist_int, date)
WITH RECURSIVE max_cumulated_date AS (
    SELECT MAX(date) AS date
    FROM users_cumulated
),
date_series AS (
    SELECT DATE_SUB(date, INTERVAL 31 DAY) AS valid_date
    FROM max_cumulated_date

    UNION ALL

    SELECT DATE_ADD(valid_date, INTERVAL 1 DAY)
    FROM date_series ds
    CROSS JOIN max_cumulated_date mcd
    WHERE ds.valid_date < mcd.date
),

starter AS (
    SELECT
        JSON_CONTAINS(
            uc.dates_active,
            JSON_QUOTE(DATE_FORMAT(d.valid_date, '%Y-%m-%d'))
        ) AS is_active,

        DATEDIFF(
            mcd.date,
            d.valid_date
        ) AS days_since,

        uc.user_id

    FROM users_cumulated uc
    CROSS JOIN date_series d
    CROSS JOIN max_cumulated_date mcd

    WHERE uc.date = mcd.date
),

bits AS (
    SELECT
        user_id,

        CAST(
            SUM(
                CASE
                    WHEN is_active THEN POW(2, 31 - days_since)
                    ELSE 0
                END
            ) AS UNSIGNED
        ) AS datelist_int,

        mcd.date AS date

    FROM starter
    CROSS JOIN max_cumulated_date mcd
    GROUP BY user_id, mcd.date
)

SELECT
    user_id,
    datelist_int,
    date
FROM bits
ON DUPLICATE KEY UPDATE
    datelist_int = VALUES(datelist_int);
