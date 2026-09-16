-- ============================================================
-- File: 11_fulfillment_analysis.sql
-- Purpose: Compare warehouse and delivery performance
-- ============================================================

SELECT
    warehouse_region,

    COUNT(order_id)
        AS order_count,

    SUM(
        CASE
            WHEN delivery_status = 'Late'
            THEN 1
            ELSE 0
        END
    ) AS late_order_count,

    ROUND(
        AVG(shipping_cost),
        2
    ) AS average_shipping_cost,

    ROUND(
        SUM(shipping_cost),
        2
    ) AS total_shipping_cost,

    ROUND(
        SUM(shipping_revenue),
        2
    ) AS total_shipping_revenue,

    ROUND(
        SUM(shipping_cost)
        - SUM(shipping_revenue),
        2
    ) AS net_shipping_cost,

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
    ) AS contribution_margin_rate

FROM vw_order_profitability

WHERE order_status = 'Completed'

GROUP BY warehouse_region

ORDER BY contribution_margin_rate;


SELECT
    delivery_status,

    COUNT(order_id)
        AS order_count,

    ROUND(
        AVG(shipping_cost),
        2
    ) AS average_shipping_cost,

    ROUND(
        SUM(return_amount),
        2
    ) AS return_amount,

    ROUND(
        SUM(return_amount)
        / NULLIF(SUM(gross_sales), 0),
        4
    ) AS return_value_rate,

    ROUND(
        SUM(contribution_margin)
        / NULLIF(SUM(net_revenue), 0),
        4
    ) AS contribution_margin_rate

FROM vw_order_profitability

WHERE order_status = 'Completed'

GROUP BY delivery_status

ORDER BY delivery_status;