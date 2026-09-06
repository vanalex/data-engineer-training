SELECT
    month_start,
    SUM(CAST(JSON_UNQUOTE(JSON_EXTRACT(hit_array, '$[0]')) AS SIGNED)) AS num_hits_mar_1,
    SUM(CAST(JSON_UNQUOTE(JSON_EXTRACT(hit_array, '$[1]')) AS SIGNED)) AS num_hits_mar_2
FROM monthly_user_site_hits
WHERE date_partition = DATE('2023-03-03')
GROUP BY month_start;