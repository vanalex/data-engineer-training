CREATE TABLE array_metrics (
    user_id      DECIMAL(20, 0) NOT NULL,
    month_start  DATE           NOT NULL,
    metric_name  VARCHAR(255)   NOT NULL,
    metric_array JSON           NOT NULL,
    PRIMARY KEY (user_id, month_start, metric_name)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;