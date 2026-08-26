ALTER TABLE players
CONVERT TO CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

ALTER TABLE players_scd_table
CONVERT TO CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

WITH last_season_scd AS (
    SELECT *
    FROM players_scd_table
    WHERE current_season = 2021
      AND end_season = 2021
),

historical_scd AS (
    SELECT
        player_name,
        scoring_class,
        is_active,
        start_season,
        end_season
    FROM players_scd_table
    WHERE current_season = 2021
      AND end_season < 2021
),

this_season_data AS (
    SELECT *
    FROM players
    WHERE current_season = 2022
),

-- Player exists and neither tracked attribute changed.
-- Extend the existing SCD period through 2022.
unchanged_records AS (
    SELECT
        ts.player_name,
        ts.scoring_class,
        ts.is_active,
        ls.start_season,
        ts.current_season AS end_season
    FROM this_season_data ts
    JOIN last_season_scd ls
        ON ls.player_name = ts.player_name
    WHERE ts.scoring_class <=> ls.scoring_class
      AND ts.is_active <=> ls.is_active
),

-- Close the previous SCD record when something changed.
changed_old_records AS (
    SELECT
        ls.player_name,
        ls.scoring_class,
        ls.is_active,
        ls.start_season,
        ls.end_season
    FROM this_season_data ts
    JOIN last_season_scd ls
        ON ls.player_name = ts.player_name
    WHERE NOT (
        ts.scoring_class <=> ls.scoring_class
        AND ts.is_active <=> ls.is_active
    )
),

-- Create a new SCD record starting in 2022.
changed_new_records AS (
    SELECT
        ts.player_name,
        ts.scoring_class,
        ts.is_active,
        ts.current_season AS start_season,
        ts.current_season AS end_season
    FROM this_season_data ts
    JOIN last_season_scd ls
        ON ls.player_name = ts.player_name
    WHERE NOT (
        ts.scoring_class <=> ls.scoring_class
        AND ts.is_active <=> ls.is_active
    )
),

-- Players that did not previously have a current SCD record.
new_records AS (
    SELECT
        ts.player_name,
        ts.scoring_class,
        ts.is_active,
        ts.current_season AS start_season,
        ts.current_season AS end_season
    FROM this_season_data ts
    LEFT JOIN last_season_scd ls
        ON ts.player_name = ls.player_name
    WHERE ls.player_name IS NULL
)

SELECT
    player_name,
    scoring_class,
    is_active,
    start_season,
    end_season,
    2022 AS current_season
FROM (
    SELECT * FROM historical_scd

    UNION ALL

    SELECT * FROM unchanged_records

    UNION ALL

    SELECT * FROM changed_old_records

    UNION ALL

    SELECT * FROM changed_new_records

    UNION ALL

    SELECT * FROM new_records
) AS combined_records;