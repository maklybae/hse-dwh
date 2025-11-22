SELECT 'up SQL query';

CREATE TABLE IF NOT EXISTS USERS (
    -- PK: Primary Key
    user_id SERIAL PRIMARY KEY,
    
    -- UK: Unique Key, Business Key
    user_external_id UUID NOT NULL UNIQUE,
    
    email VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(50),
    date_of_birth DATE,
    registration_date TIMESTAMP,
    status VARCHAR(50),
    
    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

COMMENT ON COLUMN USERS.user_external_id IS 'Business Key';
COMMENT ON COLUMN USERS.effective_from IS 'SCD Type 2';
COMMENT ON COLUMN USERS.effective_to IS 'SCD Type 2';
COMMENT ON COLUMN USERS.is_current IS 'SCD Type 2';

CREATE TABLE IF NOT EXISTS USER_STATUS_HISTORY (
    -- PK: Primary Key
    history_id SERIAL PRIMARY KEY,
    
    -- FK: Foreign Key, ссылается на user_external_id из таблицы users
    user_external_id UUID NOT NULL,
    
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    change_reason VARCHAR(255),
    
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100),
    session_id VARCHAR(100),
    
    ip_address INET,
    
    user_agent TEXT,
);


COMMENT ON COLUMN USER_STATUS_HISTORY.user_external_id IS 'Business Key';

CREATE TABLE IF NOT EXISTS USERS_ADDRESSES (
    -- PK: Primary Key
    address_id SERIAL PRIMARY KEY,

    -- UK: Unique Key, Business Key (внешний ID самого адреса)
    address_external_id UUID NOT NULL UNIQUE,

    -- FK: Внешний ключ на пользователя (Business Key)
    user_external_id UUID NOT NULL,

    address_type VARCHAR(50),  
    country VARCHAR(100),
    region VARCHAR(100),
    city VARCHAR(100),
    street_address VARCHAR(255),
    postal_code VARCHAR(20),
    apartment VARCHAR(50),
    is_default BOOLEAN DEFAULT FALSE,

    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),

);

COMMENT ON COLUMN USERS_ADDRESSES.address_external_id IS 'Business Key';
COMMENT ON COLUMN USERS_ADDRESSES.user_external_id IS 'Business Key';
COMMENT ON COLUMN USERS_ADDRESSES.effective_from IS 'SCD Type 2';
COMMENT ON COLUMN USERS_ADDRESSES.effective_to IS 'SCD Type 2';
COMMENT ON COLUMN USERS_ADDRESSES.is_current IS 'SCD Type 2';