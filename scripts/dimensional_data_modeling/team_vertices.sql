WITH teams_deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY team_id
            ORDER BY team_id
        ) AS row_num
    FROM teams
)

SELECT
    CAST(team_id AS CHAR) AS identifier,

    'team' AS type,

    JSON_OBJECT(
        'abbreviation', abbreviation,
        'nickname', nickname,
        'city', city,
        'arena', arena,
        'year_founded', yearfounded
    ) AS properties

FROM teams_deduped
WHERE row_num = 1;