# Table Schema Verification

This document verifies that all Liquibase table definitions match the actual JPA entity classes.

## ts-auth-service

### Entity: `auth.entity.User`
- **Table**: `auth_user` (explicitly named via `@Table(name = "auth_user")`)
- **Columns**:
  - `user_id` VARCHAR(36) PRIMARY KEY - matches `@Column(name = "user_id")`
  - `user_name` VARCHAR(36) - matches `@Column(name = "user_name")`
  - `password` VARCHAR(255) - matches field name

### Collection Table: `User_roles`
- **Source**: `@ElementCollection` on `Set<String> roles` with `@CollectionTable(joinColumns = @JoinColumn(name = "user_id"))`
- **Hibernate Default Naming**: When `@CollectionTable` doesn't specify a `name`, Hibernate uses `EntityName_attributeName` = `User_roles`
- **FK Column**: `User_user_id` (Hibernate default: EntityName + "_" + joinColumn name)
- **Element Column**: `roles` (attribute name)
- **Note**: The join column name `user_id` in `@JoinColumn` refers to the column in the parent table, but the FK column in the collection table is typically prefixed with the entity name.

## ts-assurance-service

### Entity: `assurance.entity.Assurance`
- **Table**: `assurance` (default: entity name lowercase)
- **Columns**:
  - `assurance_id` VARCHAR(255) PRIMARY KEY - matches `@Column(name = "assurance_id")`
  - `orderId` VARCHAR(255) NOT NULL - matches field name (camelCase preserved by default)
  - `assurance_type` VARCHAR(255) - matches `@Column(name = "assurance_type")` with `@Enumerated(EnumType.STRING)` storing values like "TRAFFIC_ACCIDENT"

## ts-user-service

### Entity: `user.entity.User`
- **Table**: `user` (default: entity name lowercase)
- **Columns**:
  - `user_id` VARCHAR(36) PRIMARY KEY - matches `@Column(name = "user_id")`
  - `user_name` VARCHAR(255) - matches `@Column(name = "user_name")`
  - `password` VARCHAR(255) - matches field name
  - `gender` INT - matches field type
  - `document_type` INT - matches `@Column(name = "document_type")`
  - `document_num` VARCHAR(255) - matches `@Column(name = "document_num")`
  - `email` VARCHAR(255) - matches field name

## ts-consign-service

### Entity: `consign.entity.ConsignRecord`
- **Table**: `consign_record` (default: entity name with underscores, `@Table(schema = "ts-consign-mysql")` only specifies schema)
- **Columns**:
  - `consign_record_id` VARCHAR(255) PRIMARY KEY - matches `@Column(name = "consign_record_id")` on `id` field
  - `order_id` VARCHAR(255) - matches field name `orderId` (camelCase -> snake_case)
  - `user_id` VARCHAR(255) - matches `@Column(name = "user_id")` on `accountId` field
  - `handle_date` VARCHAR(255) - matches field name `handleDate` (camelCase -> snake_case)
  - `target_date` VARCHAR(255) - matches field name `targetDate` (camelCase -> snake_case)
  - `from_place` VARCHAR(255) - matches `@Column(name = "from_place")` on `from` field
  - `to_place` VARCHAR(255) - matches `@Column(name = "to_place")` on `to` field
  - `consignee` VARCHAR(255) - matches field name
  - `consign_record_phone` VARCHAR(255) - matches `@Column(name = "consign_record_phone")` on `phone` field
  - `weight` DOUBLE NOT NULL - matches field type
  - `consign_record_price` DOUBLE - matches `@Column(name = "consign_record_price")` on `price` field

**Note**: Current Liquibase uses raw SQL. All columns verified against entity.

## ts-consign-price-service

### Entity: `consignprice.entity.ConsignPrice`
- **Table**: `consign_price` (explicitly named via `@Table(name="consign_price")`)
- **Columns**:
  - `id` VARCHAR(36) PRIMARY KEY - matches `@Column(length = 36)` with `@GeneratedValue`
  - `idx` INT NOT NULL UNIQUE - matches `@Column(name = "idx",unique = true)` on `index` field
  - `initial_weight` DOUBLE - matches `@Column(name = "initial_weight")` on `initialWeight` field
  - `initial_price` DOUBLE - matches `@Column(name = "initial_price")` on `initialPrice` field
  - `within_price` DOUBLE - matches `@Column(name = "within_price")` on `withinPrice` field
  - `beyond_price` DOUBLE - matches `@Column(name = "beyond_price")` on `beyondPrice` field

**Note**: Current Liquibase uses raw SQL. All columns verified against entity.

