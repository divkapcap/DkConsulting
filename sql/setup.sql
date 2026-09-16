-- ============================================================
-- Project: DKCONSULTING
-- Database: SQLite
-- File: setup.sql
-- Purpose: Create indexes to improve query performance
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_customers_customer_id
ON customers(customer_id);

CREATE INDEX IF NOT EXISTS idx_orders_order_id
ON orders(order_id);

CREATE INDEX IF NOT EXISTS idx_orders_customer_id
ON orders(customer_id);

CREATE INDEX IF NOT EXISTS idx_orders_order_date
ON orders(order_date);

CREATE INDEX IF NOT EXISTS idx_order_items_order_item_id
ON order_items(order_item_id);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id
ON order_items(order_id);

CREATE INDEX IF NOT EXISTS idx_order_items_product_id
ON order_items(product_id);

CREATE INDEX IF NOT EXISTS idx_products_product_id
ON products(product_id);

CREATE INDEX IF NOT EXISTS idx_fulfillment_order_id
ON fulfillment(order_id);

CREATE INDEX IF NOT EXISTS idx_returns_return_id
ON returns(return_id);

CREATE INDEX IF NOT EXISTS idx_returns_order_item_id
ON returns(order_item_id);

-- Verify that the indexes were created
SELECT
    name AS index_name,
    tbl_name AS table_name
FROM sqlite_master
WHERE type = 'index'
ORDER BY tbl_name, name;