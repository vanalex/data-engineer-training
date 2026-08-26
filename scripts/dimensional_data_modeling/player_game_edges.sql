INSERT INTO edges (
    subject_identifier,
    subject_type,
    object_identifier,
    object_type,
    edge_type,
    properties
)
WITH deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY player_id, game_id
            ORDER BY player_id, game_id
        ) AS row_num
    FROM game_details
)
SELECT
    CAST(player_id AS CHAR) AS subject_identifier,
    'player' AS subject_type,

    CAST(game_id AS CHAR) AS object_identifier,
    'game' AS object_type,

    'plays_in' AS edge_type,

    JSON_OBJECT(
        'start_position', start_position,
        'pts', pts,
        'team_id', team_id,
        'team_abbreviation', team_abbreviation
    ) AS properties

FROM deduped
WHERE row_num = 1;