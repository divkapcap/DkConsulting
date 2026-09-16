-- ============================================================
-- File: 06_profitability_drivers.sql
-- Purpose: Identify monthly profitability pressures
-- ============================================================

SELECT
    order_month,

    ROUND(
        SUM(gross_sales),
        2
    ) AS gross_sales,

    ROUND(
        SUM(discount_amount),
        2
    ) AS discount_cost,

    ROUND(
        SUM(return_amount),
        2
    ) AS return_cost,

    ROUND(
        SUM(product_cost),
        2
    ) AS product_cost,

    ROUND(
        SUM(shipping_cost),
        2
    ) AS shipping_cost,

    ROUND(
        SUM(shipping_revenue),
        2
    ) AS shipping_revenue,

    ROUND(
        SUM(shipping_cost)
        - SUM(shipping_revenue),
        2
    ) AS net_shipping_cost,

    ROUND(
        SUM(net_revenue),
        2
    ) AS net_revenue,

    ROUND(
        SUM(contribution_margin),
        2
    ) AS contribution_margin

FROM vw_order_profitability

WHERE order_status = 'Completed'

GROUP BY order_month

ORDER BY order_month;