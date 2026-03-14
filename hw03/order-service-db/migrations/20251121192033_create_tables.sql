-- +goose Up
-- +goose StatementBegin
SELECT 'up SQL query';

CREATE TABLE IF NOT EXISTS ORDERS (
    order_id SERIAL PRIMARY KEY,
    
    -- Business Key самого заказа
    order_external_id UUID NOT NULL UNIQUE,

    user_external_id UUID NOT NULL, 

    order_number VARCHAR(100) NOT NULL UNIQUE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    
    subtotal DECIMAL(15, 2),
    tax_amount DECIMAL(15, 2),
    shipping_cost DECIMAL(15, 2),
    discount_amount DECIMAL(15, 2),
    total_amount DECIMAL(15, 2),
    currency VARCHAR(3),

    delivery_address_external_id UUID,

    delivery_type VARCHAR(50),
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),

    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_orders_user_ext_id ON ORDERS(user_external_id);

CREATE TABLE IF NOT EXISTS ORDER_STATUS_HISTORY (
    -- PK
    history_id SERIAL PRIMARY KEY,

    -- FK: Ссылка на таблицу orders 
    order_external_id UUID NOT NULL,

    old_status VARCHAR(50),
    new_status VARCHAR(50),
    change_reason VARCHAR(255),
    
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100),
    session_id VARCHAR(100),
    
    ip_address INET,

    notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_order_history_order_ext_id
    ON ORDER_STATUS_HISTORY(order_external_id);

CREATE TABLE IF NOT EXISTS ORDER_ITEMS (
    -- PK
    order_item_id SERIAL PRIMARY KEY,

    -- FK: Ссылка на таблицу orders
    order_external_id UUID NOT NULL,

    product_sku VARCHAR(100) NOT NULL,

    quantity INTEGER NOT NULL,
    
    unit_price DECIMAL(15, 2) NOT NULL,
    total_price DECIMAL(15, 2) NOT NULL,

    product_name_snapshot VARCHAR(255),
    product_category_snapshot VARCHAR(100),
    product_brand_snapshot VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON ORDER_ITEMS(order_external_id);

CREATE INDEX IF NOT EXISTS idx_order_items_product_sku ON ORDER_ITEMS(product_sku);

CREATE TABLE IF NOT EXISTS PRODUCTS (
    -- PK: Суррогатный ключ
    product_id SERIAL PRIMARY KEY,

    -- UK: Business Key 
    product_sku VARCHAR(100) NOT NULL UNIQUE,

    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    brand VARCHAR(100),

    price DECIMAL(15, 2),
    currency VARCHAR(3), 

    weight_grams INTEGER,
    dimensions_length_cm DECIMAL(10, 2),
    dimensions_width_cm DECIMAL(10, 2),
    dimensions_height_cm DECIMAL(10, 2),

    is_active BOOLEAN DEFAULT TRUE,

    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_products_category ON PRODUCTS(category);
CREATE INDEX IF NOT EXISTS idx_products_brand ON PRODUCTS(brand);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON PRODUCTS(is_active);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
SELECT 'down SQL query';

DROP TABLE IF EXISTS PRODUCTS;
DROP TABLE IF EXISTS ORDER_ITEMS;
DROP TABLE IF EXISTS ORDER_STATUS_HISTORY;
DROP TABLE IF EXISTS ORDERS;
-- +goose StatementEnd
