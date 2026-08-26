WITH streak_started AS (
    SELECT
        player_name,
        current_season,
        scoring_class,
        CASE
            WHEN LAG(scoring_class, 1) OVER (
                PARTITION BY player_name
                ORDER BY current_season
            ) IS NULL THEN 1

            WHEN LAG(scoring_class, 1) OVER (
                PARTITION BY player_name
                ORDER BY current_season
            ) <> scoring_class THEN 1

            ELSE 0
        END AS did_change

    FROM players
),

streak_identified AS (
    SELECT
        player_name,
        scoring_class,
        current_season,

        SUM(did_change) OVER (
            PARTITION BY player_name
            ORDER BY current_season
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS streak_identifier

    FROM streak_started
),

aggregated AS (
    SELECT
        player_name,
        scoring_class,
        streak_identifier,
        MIN(current_season) AS start_season,
        MAX(current_season) AS end_season

    FROM streak_identified

    GROUP BY
        player_name,
        scoring_class,
        streak_identifier
)

SELECT
    player_name,
    scoring_class,
    start_season,
    end_season

FROM aggregated;