// Overall buisness Performance 
/* SELECT
    SUM(quantity * unit_price) AS sales,
    SUM(discount_amount) AS discounts,
    SUM(quantity * p.standard_cost) AS product_cost,
    SUM(
        (quantity * unit_price)
        - discount_amount
        - (quantity * p.standard_cost)
    ) AS gross_profit
FROM orderitems oi
JOIN products p
    ON oi.product_id = p.product_id;*/
 
 
// profit by category
 
/* SELECT
    p.category,
    SUM(quantity * unit_price) AS sales,
    SUM(discount_amount) AS discounts,
    SUM(quantity * p.standard_cost) AS costs,
    SUM(
        (quantity * unit_price)
        - discount_amount
        - (quantity * p.standard_cost)
    ) AS profit
FROM orderitems oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY profit; 
*/
 
// Returns 
SELECT
    return_reason,
    COUNT(*) AS total_returns,
    SUM(return_amount) AS return_value
FROM returns
GROUP BY return_reason
ORDER BY return_value DESC;
 
// shipping
 
/* SELECT
    SUM(shipping_cost) AS total_shipping_cost
FROM FUFILLMENT; */
 
//Dilevery
 
/* SELECT
    delivery_status,
    COUNT(*) AS orders,
    AVG(shipping_cost) AS avg_shipping_cost
FROM fulfillment
GROUP BY delivery_status
ORDER BY orders DESC; */
 
 
//
 
/*
SELECT
    p.category,
    COUNT(*) AS returns,
    SUM(r.return_amount) AS return_value
FROM returns r
JOIN orderitems oi
    ON r.order_item_id = oi.order_item_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY return_value DESC;
 
*/

// Overall buisness Performance 
/* SELECT
    SUM(quantity * unit_price) AS sales,
    SUM(discount_amount) AS discounts,
    SUM(quantity * p.standard_cost) AS product_cost,
    SUM(
        (quantity * unit_price)
        - discount_amount
        - (quantity * p.standard_cost)
    ) AS gross_profit
FROM orderitems oi
JOIN products p
    ON oi.product_id = p.product_id;*/
 
 
// profit by category
 
/* SELECT
    p.category,
    SUM(quantity * unit_price) AS sales,
    SUM(discount_amount) AS discounts,
    SUM(quantity * p.standard_cost) AS costs,
    SUM(
        (quantity * unit_price)
        - discount_amount
        - (quantity * p.standard_cost)
    ) AS profit
FROM orderitems oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY profit; 
*/
 
// Returns 
SELECT
    return_reason,
    COUNT(*) AS total_returns,
    SUM(return_amount) AS return_value
FROM returns
GROUP BY return_reason
ORDER BY return_value DESC;
 
// shipping
 
/* SELECT
    SUM(shipping_cost) AS total_shipping_cost
FROM FUFILLMENT; */
 
//Dilevery
 
/* SELECT
    delivery_status,
    COUNT(*) AS orders,
    AVG(shipping_cost) AS avg_shipping_cost
FROM fulfillment
GROUP BY delivery_status
ORDER BY orders DESC; */
 
 
//
 
/*
SELECT
    p.category,
    COUNT(*) AS returns,
    SUM(r.return_amount) AS return_value
FROM returns r
JOIN orderitems oi
    ON r.order_item_id = oi.order_item_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY return_value DESC;
 
*/

// Overall buisness Performance 
/* SELECT
    SUM(quantity * unit_price) AS sales,
    SUM(discount_amount) AS discounts,
    SUM(quantity * p.standard_cost) AS product_cost,
    SUM(
        (quantity * unit_price)
        - discount_amount
        - (quantity * p.standard_cost)
    ) AS gross_profit
FROM orderitems oi
JOIN products p
    ON oi.product_id = p.product_id;*/
 
 
// profit by category
 
/* SELECT
    p.category,
    SUM(quantity * unit_price) AS sales,
    SUM(discount_amount) AS discounts,
    SUM(quantity * p.standard_cost) AS costs,
    SUM(
        (quantity * unit_price)
        - discount_amount
        - (quantity * p.standard_cost)
    ) AS profit
FROM orderitems oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY profit; 
*/
 
// Returns 
SELECT
    return_reason,
    COUNT(*) AS total_returns,
    SUM(return_amount) AS return_value
FROM returns
GROUP BY return_reason
ORDER BY return_value DESC;
 
// shipping
 
/* SELECT
    SUM(shipping_cost) AS total_shipping_cost
FROM FUFILLMENT; */
 
//Dilevery
 
/* SELECT
    delivery_status,
    COUNT(*) AS orders,
    AVG(shipping_cost) AS avg_shipping_cost
FROM fulfillment
GROUP BY delivery_status
ORDER BY orders DESC; */
 
 
//
 
/*
SELECT
    p.category,
    COUNT(*) AS returns,
    SUM(r.return_amount) AS return_value
FROM returns r
JOIN orderitems oi
    ON r.order_item_id = oi.order_item_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY return_value DESC;
 
*/

// Monthly profitability trend

/* SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(quantity * unit_price) AS sales,
    SUM(discount_amount) AS discounts,
    SUM(quantity * p.standard_cost) AS product_cost,
    SUM(
        (quantity * unit_price)
        - discount_amount
        - (quantity * p.standard_cost)
    ) AS profit
FROM orders o
JOIN orderitems oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;
*/

