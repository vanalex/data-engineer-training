CREATE TABLE user_datelist_int (
    user_id DECIMAL(38, 10) NOT NULL,
    datelist_int BIT(32),
    date DATE NOT NULL,
    PRIMARY KEY (user_id, date)
);
