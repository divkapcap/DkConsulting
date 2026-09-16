-- ============================================================
-- Project: DKCONSULTING
-- File: 05_monthly_analysis.sql
-- Purpose: Compare monthly revenue and profitability
-- ============================================================

SELECT
    order_month,

    COUNT(*) AS order_count,

    COUNT(DISTINCT customer_id)
        AS customer_count,

    SUM(units_ordered)
        AS units_ordered,

    SUM(units_returned)
        AS units_returned,

    ROUND(SUM(gross_sales), 2)
        AS gross_sales,
    ROUND(SUM(discount_amount), 2)
        AS discount_amount,

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
    ) AS contribution_margin_rate_pct,

    ROUND(
        100.0 * SUM(discount_amount)
        / NULLIF(SUM(gross_sales), 0),
        2
    ) AS discount_rate_pct,

    ROUND(
        100.0 * SUM(return_amount)
        / NULLIF(SUM(gross_sales), 0),
        2
    ) AS return_value_rate_pct,

    ROUND(
        100.0 * SUM(units_returned)
        / NULLIF(SUM(units_ordered), 0),
        2
    ) AS unit_return_rate_pct,

    ROUND(
        SUM(net_revenue)
        / NULLIF(COUNT(*), 0),
        2
    ) AS average_order_value,

    ROUND(
        SUM(contribution_margin)
        / NULLIF(COUNT(*), 0),
        2
    ) AS margin_per_order

FROM vw_order_profitability

WHERE order_status = 'Completed'

GROUP BY order_month
ORDER BY order_month;