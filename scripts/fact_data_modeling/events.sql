CREATE TABLE events (
    url        TEXT,
    referrer   TEXT,
    user_id    BIGINT,
    device_id  BIGINT,
    host       VARCHAR(255),
    event_time DATETIME(6),
    KEY idx_events_user_time (user_id, event_time),
    KEY idx_events_device (device_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;