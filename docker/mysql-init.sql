-- Grant all privileges to beta user with GRANT OPTION (so it can grant privileges)
GRANT ALL PRIVILEGES ON *.* TO 'beta'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- Create databases if they don't exist (using hyphens for consistency)
CREATE DATABASE IF NOT EXISTS `ts-auth-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-assurance-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-user-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-consign-price-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-consign-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-food-delivery-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-order-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-order-other-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-payment-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-notification-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-price-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-route-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-security-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-food-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-station-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-station-food-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-train-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-train-food-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-travel-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-travel2-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-wait-order-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-voucher-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-ticket-office-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-inside-payment-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges on specific databases
GRANT ALL PRIVILEGES ON `ts-auth-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-assurance-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-user-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-consign-price-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-consign-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-food-delivery-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-order-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-order-other-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-payment-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-notification-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-price-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-route-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-security-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-food-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-station-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-station-food-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-train-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-train-food-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-travel-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-travel2-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-wait-order-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-voucher-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-ticket-office-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-inside-payment-mysql`.* TO 'beta'@'%';
FLUSH PRIVILEGES;

