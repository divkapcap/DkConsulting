-- ============================================================
-- File: 01_verify_setup.sql
-- Purpose: Verify the six source tables
-- ============================================================

-- Query 1: Confirm the tables
SELECT
    name AS table_name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;


-- Query 2: Confirm the row counts
SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT
    'fulfillment',
    COUNT(*)
FROM fulfillment

UNION ALL

SELECT
    'order_items',
    COUNT(*)
FROM order_items

UNION ALL

SELECT
    'orders',
    COUNT(*)
FROM orders

UNION ALL

SELECT
    'products',
    COUNT(*)
FROM products

UNION ALL

SELECT
    'returns',
    COUNT(*)
FROM returns

ORDER BY table_name;