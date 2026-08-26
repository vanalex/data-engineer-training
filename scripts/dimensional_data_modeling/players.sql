DROP TABLE IF EXISTS players;

CREATE TABLE players (
    player_name VARCHAR(255) NOT NULL,
    height VARCHAR(50),
    college VARCHAR(255),
    country VARCHAR(100),
    draft_year VARCHAR(20),
    draft_round VARCHAR(20),
    draft_number VARCHAR(20),

    -- MySQL replacement for PostgreSQL season_stats[]
    seasons JSON,

    -- MySQL supports ENUM directly on the column
    scoring_class ENUM(
        'bad',
        'average',
        'good',
        'star'
    ),

    years_since_last_active INTEGER,

    -- BOOLEAN is an alias for TINYINT(1) in MySQL
    is_active BOOLEAN,

    current_season INTEGER NOT NULL,

    PRIMARY KEY (player_name, current_season)
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
