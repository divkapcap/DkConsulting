-- ============================================================
-- Project: DKCONSULTING
-- File: 04_validate_views.sql
-- Purpose: Validate profitability views and calculations
-- ============================================================


-- ============================================================
-- CHECK 1: ITEM ROW COUNTS
-- Expected: both values should be 21,015
-- ============================================================

SELECT
    (
        SELECT COUNT(*)
        FROM order_items
    ) AS source_item_rows,

    (
        SELECT COUNT(*)
        FROM vw_item_profitability
    ) AS profitability_item_rows;


-- ============================================================
-- CHECK 2: DUPLICATE ORDERS IN FINAL VIEW
-- Expected: duplicate_order_count should be 0
-- ============================================================

SELECT
    COUNT(*) AS duplicate_order_count
FROM (
    SELECT order_id
    FROM vw_order_profitability
    GROUP BY order_id
    HAVING COUNT(*) > 1
);


-- ============================================================
-- CHECK 3: ORDERS MISSING FROM FINAL VIEW
-- Expected: ideally 0
-- ============================================================

SELECT
    COUNT(*) AS orders_missing_from_profitability
FROM orders o

LEFT JOIN vw_order_profitability v
    ON o.order_id = v.order_id

WHERE v.order_id IS NULL;


-- ======================*==================================*==
-- CHECK 4: RETURN AMOUNT RECON*ILIATION
-- Expected: all three am*unts should match
-- =============*==================================*===========

SELECT
    ROUND(
        (SELECT SUM(CAST(return_amount AS REAL))
         FROM returns),
        2
    ) AS source_return_amount,

    ROUND(
        (SELECT SUM(return_amount)
         FROM vw_return_summary),
        2
    ) AS summarized_return_amount,

    ROUND(
        (SELECT SUM(return_amount)
         FROM vw_order_profitability),
        2
    ) AS order_view_return_amount;


-- =======*==================================*=================
-- CHECK 5: GROS* SALES RECONCILIATION
-- Expected:*all three amounts should match
-- *==================================*========================

SELECT
    ROUND(
        (
            SELECT SUM(
                CAST(quantity AS INTEGER)
                * CAST(unit_price AS REAL)
            )
            FROM order_items
        ),
        2
    ) AS source_gross_sales,

    ROUND(
        (
            SELECT SUM(gross_sales)
            FROM vw_item_profitability
        ),
        2
    ) AS item_view_gross_sales,

    ROUND(
        (
            SELECT SUM(gross_sales)
            FROM vw_order_profitability
        ),
        2
    ) AS order_view_gross_sales;
``


-- ============================================================
-- CHECK 6: NULL FINANCIAL VALUES
-- Expected: all values should be 0
-- ============================================================

SELECT
    SUM(
        CASE
            WHEN gross_sales IS NULL THEN 1
            ELSE 0
        END
    ) AS null_gross_sales,

    SUM(
        CASE
            WHEN product_cost IS NULL THEN 1
            ELSE 0
        END
    ) AS null_product_cost,

    SUM(
        CASE
            WHEN net_revenue IS NULL THEN 1
            ELSE 0
        END
    ) AS null_net_revenue,

    SUM(
        CASE
            WHEN contribution_margin IS NULL THEN 1
            ELSE 0
        END
    ) AS null_contribution_margin

FROM vw_order_profitability;


-- ============================================================
-- CHECK 7: OVERALL FINANCIAL SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS order_count,
    COUNT(DISTINCT customer_id) AS customer_count,

    ROUND(SUM(gross_sales), 2)
        AS gross_sales,

    ROUND(SUM(discount_amount), 2)
        AS discounts,

    ROUND(SUM(return_amount), 2)
        AS return_amount,

    ROUND(SUM(shipping_revenue), 2)
        AS shipping_revenue,

    ROUND(SUM(product_cost), 2)
        AS product_cost,

    ROUND(SUM(shipping_cost), 2)
        AS shipping_cost,

    ROUND(SUM(net_revenue), 2)
        AS net_revenue,

    ROUND(SUM(contribution_margin), 2)
        AS contribution_margin,

    ROUND(
        100.0 * SUM(contribution_margin)
        / NULLIF(SUM(net_revenue), 0),
        2
    ) AS contribution_margin_rate_pct

FROM vw_order_profitability

WHERE order_status = 'Completed';