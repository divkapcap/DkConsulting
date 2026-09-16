-- ============================================================
-- File: 08_promotion_analysis.sql
-- Purpose: Compare promotion and non-promotion orders
-- ============================================================

SELECT
    promotion_group,

    COUNT(order_id) AS order_count,

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
        SUM(discount_amount)
        / NULLIF(SUM(gross_sales), 0),
        4
    ) AS discount_rate,

    ROUND(
        SUM(return_amount)
        / NULLIF(SUM(gross_sales), 0),
        4
    ) AS return_value_rate,

    ROUND(
        SUM(net_revenue)
        / NULLIF(COUNT(order_id), 0),
        2
    ) AS average_order_value,

    ROUND(
        SUM(contribution_margin)
        / NULLIF(COUNT(order_id), 0),
        2
    ) AS margin_per_order

FROM vw_order_profitability

WHERE order_status = 'Completed'

GROUP BY promotion_group

ORDER BY promotion_group;
