-- ============================================================
-- Project: DKCONSULTING
-- File: 03_profitability_views.sql
-- Database: SQLite
-- Purpose: Build reusable profitability calculations
-- ============================================================

-- Financial definition:
--
-- Gross Sales
-- = Quantity * Unit Price
--
-- Net Revenue
-- = Gross Sales - Discounts - Returns + Shipping Revenue
--
-- Contribution Margin
-- = Net Revenue - Product Cost - Shipping Cost
--
-- Conservative return assumption:
-- Product cost is not recovered for returned units because
-- the dataset does not specify whether returned inventory
-- can be resold or otherwise recovered.


-- ============================================================
-- VIEW 1: RETURNS BY ORDER ITEM
-- ============================================================

DROP VIEW IF EXISTS vw_return_summary;

CREATE VIEW vw_return_summary AS
SELECT
    order_item_id,

    SUM(
        CAST(return_quantity AS INTEGER)
    ) AS returned_quantity,

    SUM(
        CAST(return_amount AS REAL)
    ) AS return_amount,

    COUNT(*) AS return_record_count

FROM returns
GROUP BY order_item_id;


-- ============================================================
-- VIEW 2: ITEM-LEVEL PROFITABILITY
-- ============================================================

DROP VIEW IF EXISTS vw_item_profitability;

CREATE VIEW vw_item_profitability AS
SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,

    p.product_name,
    p.category,
    p.subcategory,

    CAST(oi.quantity AS INTEGER)
        AS quantity,

    CAST(oi.unit_price AS REAL)
        AS unit_price,

    COALESCE(
        CAST(oi.discount_amount AS REAL),
        0
    ) AS discount_amount,

    CAST(p.standard_cost AS REAL)
        AS standard_cost,

    CAST(oi.quantity AS INTEGER)
        * CAST(oi.unit_price AS REAL)
        AS gross_sales,

    COALESCE(
        rs.returned_quantity,
        0
    ) AS returned_quantity,

    COALESCE(
        rs.return_amount,
        0
    ) AS return_amount,

    CAST(oi.quantity AS INTEGER)
        * CAST(p.standard_cost AS REAL)
        AS product_cost,

    (
        CAST(oi.quantity AS INTEGER)
        * CAST(oi.unit_price AS REAL)
    )
        - COALESCE(CAST(oi.discount_amount AS REAL), 0)
        - COALESCE(rs.return_amount, 0)
        AS item_net_revenue,

    (
        CAST(oi.quantity AS INTEGER)
        * CAST(oi.unit_price AS REAL)
    )
        - COALESCE(CAST(oi.discount_amount AS REAL), 0)
        - COALESCE(rs.return_amount, 0)
        - (
            CAST(oi.quantity AS INTEGER)
            * CAST(p.standard_cost AS REAL)
        )
        AS item_margin_before_shipping

FROM order_items oi

LEFT JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN vw_return_summary rs
    ON oi.order_item_id = rs.order_item_id;


-- ============================================================
-- VIEW 3: ORDER-ITEM SUMMARY
-- ============================================================

DROP VIEW IF EXISTS vw_order_item_summary;

CREATE VIEW vw_order_item_summary AS
SELECT
    order_id,

    SUM(quantity)
        AS units_ordered,

    SUM(returned_quantity)
        AS units_returned,

    SUM(gross_sales)
        AS gross_sales,

    SUM(discount_amount)
        AS discount_amount,

    SUM(return_amount)
        AS return_amount,

    SUM(product_cost)
        AS product_cost,

    SUM(item_net_revenue)
        AS item_net_revenue,

    SUM(item_margin_before_shipping)
        AS margin_before_shipping

FROM vw_item_profitability
GROUP BY order_id;


-- ============================================================
-- VIEW 4: FINAL ORDER-LEVEL PROFITABILITY
-- ============================================================

DROP VIEW IF EXISTS vw_order_profitability;

CREATE VIEW vw_order_profitability AS
SELECT
    o.order_id,
    o.customer_id,

    DATE(o.order_date)
        AS order_date,

    STRFTIME('%Y-%m', o.order_date)
        AS order_month,

    o.promotion_id,

    CASE
        WHEN o.promotion_id IS NULL
          OR TRIM(o.promotion_id) = ''
        THEN 'No Promotion'
        ELSE 'Promotion'
    END AS promotion_group,

    o.order_status,

    CASE
        WHEN c.region IS NULL
          OR TRIM(c.region) = ''
        THEN 'Unknown'
        ELSE c.region
    END AS region,

    CASE
        WHEN c.acquisition_channel IS NULL
          OR TRIM(c.acquisition_channel) = ''
        THEN 'Unknown'
        ELSE c.acquisition_channel
    END AS acquisition_channel,

    CASE
        WHEN c.customer_segment IS NULL
          OR TRIM(c.customer_segment) = ''
        THEN 'Unknown'
        ELSE c.customer_segment
    END AS customer_segment,

    COALESCE(
        f.warehouse_region,
        'Unknown'
    ) AS warehouse_region,

    f.promised_delivery_date,
    f.actual_delivery_date,

    COALESCE(
        f.delivery_status,
        'Unknown'
    ) AS delivery_status,

    CASE
        WHEN f.actual_delivery_date IS NULL
          OR f.promised_delivery_date IS NULL
        THEN NULL

        ELSE CAST(
            JULIANDAY(f.actual_delivery_date)
            - JULIANDAY(f.promised_delivery_date)
            AS INTEGER
        )
    END AS days_late,

    s.units_ordered,
    s.units_returned,
    s.gross_sales,
    s.discount_amount,
    s.return_amount,
    s.product_cost,

    COALESCE(
        CAST(o.shipping_revenue AS REAL),
        0
    ) AS shipping_revenue,

    COALESCE(
        CAST(f.shipping_cost AS REAL),
        0
    ) AS shipping_cost,

    s.gross_sales
        - s.discount_amount
        - s.return_amount
        + COALESCE(CAST(o.shipping_revenue AS REAL), 0)
        AS net_revenue,

    s.gross_sales
        - s.discount_amount
        - s.return_amount
        + COALESCE(CAST(o.shipping_revenue AS REAL), 0)
        - s.product_cost
        - COALESCE(CAST(f.shipping_cost AS REAL), 0)
        AS contribution_margin,

    CASE
        WHEN s.gross_sales = 0
        THEN NULL

        ELSE s.discount_amount / s.gross_sales
    END AS discount_rate,

    CASE
        WHEN s.units_ordered = 0
        THEN NULL

        ELSE
            CAST(s.units_returned AS REAL)
            / s.units_ordered
    END AS unit_return_rate,

    CASE
        WHEN
            s.gross_sales
            - s.discount_amount
            - s.return_amount
            + COALESCE(CAST(o.shipping_revenue AS REAL), 0)
            = 0
        THEN NULL

        ELSE
            (
                s.gross_sales
                - s.discount_amount
                - s.return_amount
                + COALESCE(CAST(o.shipping_revenue AS REAL), 0)
                - s.product_cost
                - COALESCE(CAST(f.shipping_cost AS REAL), 0)
            )
            /
            (
                s.gross_sales
                - s.discount_amount
                - s.return_amount
                + COALESCE(CAST(o.shipping_revenue AS REAL), 0)
            )
    END AS contribution_margin_rate

FROM orders o

INNER JOIN vw_order_item_summary s
    ON o.order_id = s.order_id

LEFT JOIN customers c
    ON o.customer_id = c.customer_id

LEFT JOIN fulfillment f
    ON o.order_id = f.order_id;


-- ============================================================
-- VERIFY THE VIEWS
-- ============================================================

SELECT
    name AS view_name
FROM sqlite_master
WHERE type = 'view'
  AND name LIKE 'vw_%'
ORDER BY name;


-- SELECT *
-- FROM vw_order_profitability
-- LIMIT 10;