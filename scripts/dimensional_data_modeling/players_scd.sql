CREATE TABLE players_scd_table (
    player_name VARCHAR(255) NOT NULL,

    scoring_class ENUM(
        'bad',
        'average',
        'good',
        'star'
    ),

    is_active BOOLEAN,

    start_season INTEGER NOT NULL,
    end_season INTEGER NOT NULL,

    current_season INTEGER NOT NULL,

    PRIMARY KEY (
        player_name,
        start_season,
        current_season
    )
);