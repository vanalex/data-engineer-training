CREATE TABLE monthly_user_site_hits (
    user_id          BIGINT NOT NULL,
    hit_array        JSON,
    month_start      DATE   NOT NULL,
    first_found_date DATE,
    date_partition   DATE   NOT NULL,
    PRIMARY KEY (user_id, date_partition, month_start)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;