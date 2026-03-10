#!/bin/bash

# Insert mock data to test Debezium CDC

echo "Inserting mock data into user-service-db..."
docker exec pg-user-1 psql -U postgres -d postgres <<EOF
-- Insert users
INSERT INTO users (user_external_id, email, first_name, last_name, phone, date_of_birth, registration_date, status, effective_from, is_current)
VALUES
    (gen_random_uuid(), 'john@example.com', 'John', 'Doe', '+1234567890', '1990-01-15', NOW(), 'active', NOW(), true),
    (gen_random_uuid(), 'jane@example.com', 'Jane', 'Smith', '+1234567891', '1985-05-22', NOW(), 'active', NOW(), true),
    (gen_random_uuid(), 'bob@example.com', 'Bob', 'Johnson', '+1234567892', '1992-11-08', NOW(), 'active', NOW(), true);

SELECT 'Inserted ' || COUNT(*) || ' users' FROM users;
EOF

echo "Inserting mock data into order-service-db..."
docker exec pg-order-1 psql -U postgres -d postgres <<EOF
-- Insert orders (note: user_external_id should match users from user-service in real scenario)
-- For testing, we'll just use random UUIDs
INSERT INTO orders (order_external_id, user_external_id, order_number, order_date, status, subtotal, total_amount, currency, payment_method, payment_status, is_current, effective_from)
VALUES
    (gen_random_uuid(), gen_random_uuid(), 'ORD-2024-001', NOW(), 'pending', 100.00, 110.00, 'USD', 'credit_card', 'pending', true, NOW()),
    (gen_random_uuid(), gen_random_uuid(), 'ORD-2024-002', NOW(), 'processing', 150.00, 165.00, 'USD', 'paypal', 'paid', true, NOW()),
    (gen_random_uuid(), gen_random_uuid(), 'ORD-2024-003', NOW(), 'completed', 200.00, 220.00, 'USD', 'credit_card', 'paid', true, NOW());

SELECT 'Inserted ' || COUNT(*) || ' orders' FROM orders;
EOF

echo "Inserting mock data into logistics-service-db..."
docker exec pg-logistics-1 psql -U postgres -d postgres <<EOF
-- Insert warehouses
INSERT INTO warehouses (warehouse_code, warehouse_name, warehouse_type, country, city, street_address, postal_code, contact_phone, manager_name, is_active, effective_from, is_current)
VALUES
    ('WH-NYC-001', 'Main Warehouse', 'distribution', 'USA', 'New York', '123 Storage St', '10001', '+1111111111', 'Manager One', true, NOW(), true),
    ('WH-LA-001', 'Secondary Warehouse', 'regional', 'USA', 'Los Angeles', '456 Depot Ave', '90001', '+2222222222', 'Manager Two', true, NOW(), true);

-- Insert shipments (note: order_external_id should match orders from order-service in real scenario)
INSERT INTO shipments (shipment_external_id, order_external_id, tracking_number, status, origin_warehouse_code, created_date, estimated_delivery_date, is_current, effective_from)
SELECT
    gen_random_uuid(),
    gen_random_uuid(),
    'TRACK-' || LPAD(n::text, 8, '0'),
    'processing',
    (SELECT warehouse_code FROM warehouses LIMIT 1),
    NOW(),
    NOW() + INTERVAL '3 days',
    true,
    NOW()
FROM generate_series(1, 2) AS n;

SELECT 'Inserted ' || COUNT(*) || ' warehouses' FROM warehouses;
SELECT 'Inserted ' || COUNT(*) || ' shipments' FROM shipments;
EOF

echo ""
echo "✓ Mock data inserted successfully!"
echo ""
echo "Waiting 5 seconds for Debezium to capture changes..."
sleep 5

echo ""
echo "Checking Kafka topics created by Debezium..."
docker exec debezium-kafka /kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 | grep -E "debezium-"
