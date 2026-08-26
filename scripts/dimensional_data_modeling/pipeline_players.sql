DELETE FROM players
WHERE current_season = 1998;

INSERT INTO players (
    player_name,
    height,
    college,
    country,
    draft_year,
    draft_round,
    draft_number,
    seasons,
    scoring_class,
    years_since_last_active,
    is_active,
    current_season
)
WITH last_season AS (
    SELECT *
    FROM players
    WHERE current_season = 1997
),

this_season AS (
    SELECT *
    FROM player_seasons
    WHERE season = 1998
),

all_players AS (
    SELECT player_name COLLATE utf8mb4_unicode_ci AS player_name
    FROM last_season

    UNION

    SELECT player_name COLLATE utf8mb4_unicode_ci AS player_name
    FROM this_season
)

SELECT
    COALESCE(
        ls.player_name COLLATE utf8mb4_unicode_ci,
        ts.player_name COLLATE utf8mb4_unicode_ci
    ) AS player_name,

    COALESCE(ls.height COLLATE utf8mb4_unicode_ci, ts.height) AS height,
    COALESCE(ls.college COLLATE utf8mb4_unicode_ci, ts.college) AS college,
    COALESCE(ls.country COLLATE utf8mb4_unicode_ci, ts.country) AS country,
    COALESCE(ls.draft_year COLLATE utf8mb4_unicode_ci, ts.draft_year) AS draft_year,
    COALESCE(ls.draft_round COLLATE utf8mb4_unicode_ci, ts.draft_round) AS draft_round,
    COALESCE(ls.draft_number COLLATE utf8mb4_unicode_ci, ts.draft_number) AS draft_number,

    -- PostgreSQL:
    -- seasons || ARRAY[ROW(...)::season_stats]
    --
    -- MySQL:
    CASE
        WHEN ts.season IS NOT NULL THEN
            JSON_ARRAY_APPEND(
                COALESCE(ls.seasons, JSON_ARRAY()),
                '$',
                JSON_OBJECT(
                    'season', ts.season,
                    'pts', ts.pts,
                    'ast', ts.ast,
                    'reb', ts.reb,
                    'weight', ts.weight
                )
            )
        ELSE
            COALESCE(ls.seasons, JSON_ARRAY())
    END AS seasons,

    CASE
        WHEN ts.season IS NOT NULL THEN
            CASE
                WHEN ts.pts > 20 THEN 'star'
                WHEN ts.pts > 15 THEN 'good'
                WHEN ts.pts > 10 THEN 'average'
                ELSE 'bad'
            END
        ELSE
            ls.scoring_class
    END AS scoring_class,

    -- Missing from the original PostgreSQL query
    CASE
        WHEN ts.season IS NOT NULL THEN 0
        ELSE COALESCE(ls.years_since_last_active, 0) + 1
    END AS years_since_last_active,

    ts.season IS NOT NULL AS is_active,

    1998 AS current_season

FROM all_players ap

LEFT JOIN last_season ls
    ON ap.player_name = ls.player_name COLLATE utf8mb4_unicode_ci

LEFT JOIN this_season ts
    ON ap.player_name = ts.player_name COLLATE utf8mb4_unicode_ci;
