CREATE TABLE users_cumulated (
    user_id DECIMAL(38, 10) NOT NULL,
    dates_active JSON,
    date DATE NOT NULL,
    PRIMARY KEY (user_id, date)
);
