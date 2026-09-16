-- ============================================================
-- File: 10_returns_analysis.sql
-- Purpose: Analyze return reasons and categories
-- ============================================================

SELECT
    p.category,

    CASE
        WHEN r.return_reason IS NULL
          OR TRIM(r.return_reason) = ''
        THEN 'Unknown'
        ELSE r.return_reason
    END AS return_reason,

    COUNT(r.return_id)
        AS return_record_count,

    SUM(
        CAST(r.return_quantity AS INTEGER)
    ) AS returned_units,

    ROUND(
        SUM(CAST(r.return_amount AS REAL)),
        2
    ) AS return_amount

FROM returns AS r

INNER JOIN order_items AS oi
    ON r.order_item_id = oi.order_item_id

INNER JOIN products AS p
    ON oi.product_id = p.product_id

GROUP BY
    p.category,
    CASE
        WHEN r.return_reason IS NULL
          OR TRIM(r.return_reason) = ''
        THEN 'Unknown'
        ELSE r.return_reason
    END

ORDER BY return_amount DESC;