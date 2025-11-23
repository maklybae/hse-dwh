SELECT 'up SQL query';

CREATE TABLE IF NOT EXISTS SHIPMENTS (
    -- PK
    shipment_id SERIAL PRIMARY KEY,

    -- UK: Business Key
    shipment_external_id UUID NOT NULL UNIQUE,

    order_external_id UUID NOT NULL,

    -- UK: Трек-номер 
    tracking_number VARCHAR(100) UNIQUE,
    status VARCHAR(50),

    weight_grams INTEGER,
    volume_cubic_cm INTEGER,
    package_count INTEGER,


    origin_warehouse_code VARCHAR(50),
    destination_type VARCHAR(50),
    destination_pickup_point_code VARCHAR(50),

    destination_address_external_id UUID,

    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    dispatched_date TIMESTAMP, 
    estimated_delivery_date TIMESTAMP, 
    actual_delivery_date TIMESTAMP, 

    delivery_notes TEXT,
    recipient_name VARCHAR(255),
    delivery_signature VARCHAR(255), 

    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN DEFAULT TRUE,


    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_shipments_order_ext_id ON SHIPMENTS(order_external_id);
CREATE INDEX IF NOT EXISTS idx_shipments_address_ext_id ON SHIPMENTS(destination_address_external_id);


CREATE TABLE IF NOT EXISTS SHIPMENT_MOVEMENTS (
    movement_id SERIAL PRIMARY KEY,

    -- FK: Связь с таблицей shipments
    shipment_external_id UUID NOT NULL,

    movement_type VARCHAR(50), 
    location_type VARCHAR(50), 
    location_code VARCHAR(50),
    movement_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operator_name VARCHAR(100),
    notes TEXT,

    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_movements_shipment_id ON SHIPMENT_MOVEMENTS(shipment_external_id);

CREATE TABLE IF NOT EXISTS SHIPMENT_STATUS_HISTORY (
    history_id SERIAL PRIMARY KEY,

    -- FK: Связь с таблицей shipments
    shipment_external_id UUID NOT NULL,

    old_status VARCHAR(50),
    new_status VARCHAR(50),
    change_reason VARCHAR(255),
    
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100),
    
    location_type VARCHAR(50),
    location_code VARCHAR(50),
    
    notes TEXT,
    customer_notified BOOLEAN DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_status_history_shipment_id ON SHIPMENT_STATUS_HISTORY(shipment_external_id);

CREATE TABLE IF NOT EXISTS WAREHOUSES (
    -- PK
    warehouse_id SERIAL PRIMARY KEY,

    -- UK: Business Key
    warehouse_code VARCHAR(50) NOT NULL UNIQUE,

    warehouse_name VARCHAR(100) NOT NULL,
    warehouse_type VARCHAR(50), 

    country VARCHAR(100),
    region VARCHAR(100),
    city VARCHAR(100),
    street_address VARCHAR(255),
    postal_code VARCHAR(20),

    is_active BOOLEAN DEFAULT TRUE,

    max_capacity_cubic_meters DECIMAL(15, 2),

    operating_hours VARCHAR(255), 
    contact_phone VARCHAR(50),
    manager_name VARCHAR(100),

    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);


CREATE INDEX IF NOT EXISTS idx_warehouses_city ON WAREHOUSES(city);
CREATE INDEX IF NOT EXISTS idx_warehouses_is_active ON WAREHOUSES(is_active);


CREATE TABLE IF NOT EXISTS PICKUP_POINTS (
    -- PK
    pickup_point_id SERIAL PRIMARY KEY,

    -- UK: Business Key 
    pickup_point_code VARCHAR(50) NOT NULL UNIQUE,

    pickup_point_name VARCHAR(100) NOT NULL,
    pickup_point_type VARCHAR(50), 

    country VARCHAR(100),
    region VARCHAR(100),
    city VARCHAR(100),
    street_address VARCHAR(255),
    postal_code VARCHAR(20),

    is_active BOOLEAN DEFAULT TRUE,

    max_capacity_packages INTEGER,

    operating_hours VARCHAR(255),
    contact_phone VARCHAR(50),
    partner_name VARCHAR(100),
    
    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_pickup_points_city ON PICKUP_POINTS(city);
CREATE INDEX IF NOT EXISTS idx_pickup_points_type ON PICKUP_POINTS(pickup_point_type);
