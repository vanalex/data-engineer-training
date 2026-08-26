CREATE TABLE vertices (
    identifier VARCHAR(255) NOT NULL,

    type ENUM(
        'player',
        'team',
        'game'
    ) NOT NULL,

    properties JSON,

    PRIMARY KEY (identifier, type)
)
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

CREATE TABLE edges (
    subject_identifier VARCHAR(255) NOT NULL,

    subject_type ENUM(
        'player',
        'team',
        'game'
    ) NOT NULL,

    object_identifier VARCHAR(255) NOT NULL,

    object_type ENUM(
        'player',
        'team',
        'game'
    ) NOT NULL,

    edge_type ENUM(
        'plays_against',
        'shares_team',
        'plays_in',
        'plays_on'
    ) NOT NULL,

    properties JSON,

    PRIMARY KEY (
        subject_identifier,
        subject_type,
        object_identifier,
        object_type,
        edge_type
    )
)
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;