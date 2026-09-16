-- ============================================================
-- File: 09_category_analysis.sql
-- Purpose: Compare product-category economics
-- Note: Excludes order-level shipping allocation
-- ============================================================

SELECT
    category,

    COUNT(DISTINCT order_id)
        AS order_count,

    SUM(quantity)
        AS units_ordered,

    SUM(returned_quantity)
        AS units_returned,

    ROUND(
        SUM(gross_sales),
        2
    ) AS gross_sales,

    ROUND(
        SUM(discount_amount),
        2
    ) AS discount_amount,

    ROUND(
        SUM(return_amount),
        2
    ) AS return_amount,

    ROUND(
        SUM(product_cost),
        2
    ) AS product_cost,

    ROUND(
        SUM(item_net_revenue),
        2
    ) AS net_item_revenue,

    ROUND(
        SUM(item_margin_before_shipping),
        2
    ) AS margin_before_shipping,

    ROUND(
        SUM(item_margin_before_shipping)
        / NULLIF(SUM(item_net_revenue), 0),
        4
    ) AS margin_rate_before_shipping,

    ROUND(
        SUM(return_amount)
        / NULLIF(SUM(gross_sales), 0),
        4
    ) AS return_value_rate,

    ROUND(
        SUM(discount_amount)
        / NULLIF(SUM(gross_sales), 0),
        4
    ) AS discount_rate

FROM vw_item_profitability

GROUP BY category

ORDER BY margin_rate_before_shipping;