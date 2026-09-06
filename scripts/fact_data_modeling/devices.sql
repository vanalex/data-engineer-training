CREATE TABLE devices (
    device_id             BIGINT       NOT NULL,
    browser_type          VARCHAR(255),
    browser_version_major BIGINT,
    browser_version_minor BIGINT,
    browser_version_patch BIGINT,
    device_type           VARCHAR(255),
    device_version_major  BIGINT,
    device_version_minor  BIGINT,
    device_version_patch  BIGINT,
    os_type               VARCHAR(255),
    os_version_major      BIGINT,
    os_version_minor      BIGINT,
    os_version_patch      BIGINT,
    PRIMARY KEY (device_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;