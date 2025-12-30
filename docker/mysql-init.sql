-- Grant all privileges to beta user with GRANT OPTION (so it can grant privileges)
GRANT ALL PRIVILEGES ON *.* TO 'beta'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- Create databases if they don't exist (using hyphens for consistency)
CREATE DATABASE IF NOT EXISTS `ts-auth-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-assurance-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-user-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-consign-price-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-consign-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges on specific databases
GRANT ALL PRIVILEGES ON `ts-auth-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-assurance-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-user-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-consign-price-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-consign-mysql`.* TO 'beta'@'%';
FLUSH PRIVILEGES;

