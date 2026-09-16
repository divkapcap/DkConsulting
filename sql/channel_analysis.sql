-- ============================================================
-- File: 07_channel_analysis.sql
-- Purpose: Compare profitability by acquisition channel
-- ============================================================

SELECT
    acquisition_channel,

    COUNT(order_id) AS order_count,

    COUNT(DISTINCT customer_id)
        AS customer_count,

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
        SUM(shipping_cost),
        2
    ) AS shipping_cost,

    ROUND(
        SUM(net_revenue),
        2
    ) AS net_revenue,

    ROUND(
        SUM(contribution_margin),
        2
    ) AS contribution_margin,

    ROUND(
        SUM(contribution_margin)
        / NULLIF(SUM(net_revenue), 0),
        4
    ) AS contribution_margin_rate,

    ROUND(
        SUM(return_amount)
        / NULLIF(SUM(gross_sales), 0),
        4
    ) AS return_value_rate,

    ROUND(
        SUM(discount_amount)
        / NULLIF(SUM(gross_sales), 0),
        4
    ) AS discount_rate,

    ROUND(
        SUM(contribution_margin)
        / NULLIF(COUNT(DISTINCT customer_id), 0),
        2
    ) AS margin_per_customer

FROM vw_order_profitability

WHERE order_status = 'Completed'

GROUP BY acquisition_channel

ORDER BY contribution_margin_rate;