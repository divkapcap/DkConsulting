-- ============================================================
-- Project: DKCONSULTING
-- File: 02_data_quality.sql
-- Purpose: Identify data-quality issues
-- ============================================================


-- ============================================================
-- SECTION 1: DUPLICATE PRIMARY KEYS
-- Expected result: issue_count should be 0 for every table
-- ============================================================

SELECT
    'customers' AS table_name,
    COUNT(*) AS issue_count
FROM (
    SELECT customer_id
    FROM customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'orders',
    COUNT(*)
FROM (
    SELECT order_id
    FROM orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'order_items',
    COUNT(*)
FROM (
    SELECT order_item_id
    FROM order_items
    GROUP BY order_item_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'products',
    COUNT(*)
FROM (
    SELECT product_id
    FROM products
    GROUP BY product_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'fulfillment',
    COUNT(*)
FROM (
    SELECT order_id
    FROM fulfillment
    GROUP BY order_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'returns',
    COUNT(*)
FROM (
    SELECT return_id
    FROM returns
    GROUP BY return_id
    HAVING COUNT(*) > 1
);

-- ============================================================
-- SECTION 2: MISSING VALUES
-- ============================================================

SELECT
    'customers.region' AS field_name,
    SUM(
        CASE
            WHEN region IS NULL OR TRIM(region) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_count
FROM customers

UNION ALL

SELECT
    'customers.acquisition_channel',
    SUM(
        CASE
            WHEN acquisition_channel IS NULL
              OR TRIM(acquisition_channel) = ''
            THEN 1
            ELSE 0
        END
    )
FROM customers

UNION ALL

SELECT
    'customers.customer_segment',
    SUM(
        CASE
            WHEN customer_segment IS NULL
              OR TRIM(customer_segment) = ''
            THEN 1
            ELSE 0
        END
    )
FROM customers

UNION ALL

SELECT
    'orders.promotion_id',
    SUM(
        CASE
            WHEN promotion_id IS NULL
              OR TRIM(promotion_id) = ''
            THEN 1
            ELSE 0
        END
    )
FROM orders

UNION ALL

SELECT
    'returns.return_reason',
    SUM(
        CASE
            WHEN return_reason IS NULL
              OR TRIM(return_reason) = ''
            THEN 1
            ELSE 0
        END
    )
FROM returns;

-- ============================================================
-- SECTION 3: TABLE RELATIONSHIP CHECKS
-- Expected result: issue_count should generally be 0
-- ============================================================

SELECT
    'orders without customer' AS issue_name,
    COUNT(*) AS issue_count
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'order items without order',
    COUNT(*)
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'order items without product',
    COUNT(*)
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT
    'fulfillment without order',
    COUNT(*)
FROM fulfillment f
LEFT JOIN orders o
    ON f.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'returns without order item',
    COUNT(*)
FROM returns r
LEFT JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
WHERE oi.order_item_id IS NULL;


-- ============================================================
-- SECTION 4: DATE CONSISTENCY CHECKS
-- ============================================================

SELECT
    'orders before customer signup' AS issue_name,
    COUNT(*) AS issue_count
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE DATE(o.order_date) < DATE(c.signup_date)

UNION ALL

SELECT
    'signups after analysis period',
    COUNT(*)
FROM customers
WHERE DATE(signup_date) > DATE('2026-06-30')

UNION ALL

SELECT
    'returns before order date',
    COUNT(*)
FROM returns r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE DATE(r.return_date) < DATE(o.order_date)

UNION ALL

SELECT
    'delivery status conflicts',
    COUNT(*)
FROM fulfillment
WHERE
    (
        DATE(actual_delivery_date) > DATE(promised_delivery_date)
        AND delivery_status <> 'Late'
    )
    OR
    (
        DATE(actual_delivery_date) <= DATE(promised_delivery_date)
        AND delivery_status = 'Late'
    );


-- ============================================================
-- SECTION 5: INVALID FINANCIAL OR QUANTITY VALUES
-- ============================================================

SELECT
    'invalid order item quantity' AS issue_name,
    COUNT(*) AS issue_count
FROM order_items
WHERE CAST(quantity AS INTEGER) <= 0

UNION ALL

SELECT
    'negative unit price',
    COUNT(*)
FROM order_items
WHERE CAST(unit_price AS REAL) < 0

UNION ALL

SELECT
    'negative discount',
    COUNT(*)
FROM order_items
WHERE CAST(discount_amount AS REAL) < 0

UNION ALL

SELECT
    'discount exceeds gross sales',
    COUNT(*)
FROM order_items
WHERE CAST(discount_amount AS REAL)
    > CAST(quantity AS INTEGER) * CAST(unit_price AS REAL)

UNION ALL

SELECT
    'negative product cost',
    COUNT(*)
FROM products
WHERE CAST(standard_cost AS REAL) < 0

UNION ALL

SELECT
    'product cost exceeds list price',
    COUNT(*)
FROM products
WHERE CAST(standard_cost AS REAL)
    > CAST(list_price AS REAL)

UNION ALL

SELECT
    'negative shipping cost',
    COUNT(*)
FROM fulfillment
WHERE CAST(shipping_cost AS REAL) < 0

UNION ALL

SELECT
    'invalid return quantity',
    COUNT(*)
FROM returns
WHERE CAST(return_quantity AS INTEGER) <= 0

UNION ALL

SELECT
    'negative return amount',
    COUNT(*)
FROM returns
WHERE CAST(return_amount AS REAL) < 0;

-- ============================================================
-- SECTION 6: RETURN QUANTITY VALIDATION
-- ============================================================

WITH return_totals AS (
    SELECT
        order_item_id,
        SUM(CAST(return_quantity AS INTEGER))
            AS total_return_quantity
    FROM returns
    GROUP BY order_item_id
)

SELECT
    COUNT(*) AS return_quantity_issues
FROM return_totals rt
JOIN order_items oi
    ON rt.order_item_id = oi.order_item_id
WHERE rt.total_return_quantity
    > CAST(oi.quantity AS INTEGER);

-- ============================================================
-- SECTION 7A: ORDER STATUSES
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- ============================================================
-- SECTION 7B: DELIVERY STATUSES
-- ============================================================

SELECT
    delivery_status,
    COUNT(*) AS order_count
FROM fulfillment
GROUP BY delivery_status
ORDER BY order_count DESC;


-- ============================================================
-- SECTION 7C: RETURN REASONS
-- ============================================================

SELECT
    CASE
        WHEN return_reason IS NULL
          OR TRIM(return_reason) = ''
        THEN 'Unknown'
        ELSE return_reason
    END AS return_reason_group,

    COUNT(*) AS return_count,

    ROUND(
        SUM(CAST(return_amount AS REAL)),
        2
    ) AS return_amount

FROM returns
GROUP BY return_reason_group
ORDER BY return_amount DESC;


-- ============================================================
-- SECTION 7D: ACQUISITION CHANNELS
-- ============================================================

SELECT
    CASE
        WHEN acquisition_channel IS NULL
          OR TRIM(acquisition_channel) = ''
        THEN 'Unknown'
        ELSE acquisition_channel
    END AS acquisition_channel_group,

    COUNT(*) AS customer_count

FROM customers
GROUP BY acquisition_channel_group
ORDER BY customer_count DESC;