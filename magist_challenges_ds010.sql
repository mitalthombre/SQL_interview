USE magist;

/*
Select all the products from the health_beauty or perfumery categories that 
have been paid by credit card with a payment amount of more than 1000$,
from orders that were purchased during 2018 and have a 'delivered' status?
*/

DROP TEMPORARY TABLE health_beauty_products_filtered;
CREATE TEMPORARY TABLE health_beauty_products_filtered
SELECT 
    *
FROM
    products p
        JOIN
    order_items oi USING (product_id)
        JOIN
    orders o USING (order_id)
        JOIN
    order_payments op USING (order_id)
        JOIN
    sellers USING (seller_id)
        JOIN
    customers USING (customer_id)    
        JOIN
    product_category_name_translation USING (product_category_name)
WHERE
    product_category_name_english IN ('health_beauty', 'perfumery')
        AND o.order_status = 'delivered'
        AND YEAR(o.order_purchase_timestamp) = 2018
        AND op.payment_type LIKE "%credit_card%"
        AND op.payment_value > 1000
;

SELECT 
    *
FROM
    health_beauty_products_filtered;



CREATE TEMPORARY TABLE prod_yan
SELECT product_id, p.product_category_name, product_category_name_english
FROM products AS p
JOIN product_category_name_translation AS pte 
ON p.product_category_name = pte.product_category_name
WHERE pte.product_category_name_english IN ("health_beauty", "perfumery") AND product_id IN 
(SELECT product_id FROM order_items
WHERE order_id IN 
(SELECT order_id FROM order_payments
WHERE payment_type = "credit_card" AND payment_value > 1000 AND order_id IN
(SELECT order_id
FROM orders
WHERE order_status = "delivered" AND year(order_purchase_timestamp) = "2018")));
 
SELECT 
    *
FROM
    prod_yan; 



DROP TABLE IF EXISTS products_H_P_english;
CREATE TEMPORARY TABLE products_H_P_english
SELECT product_id, pte.product_category_name_english FROM products p
JOIN product_category_name_translation pte ON p.product_category_name = pte.product_category_name
WHERE product_category_name_english IN ("health_beauty","perfumery");

SELECT 
    COUNT(*)
FROM
    products_H_P_english;

DROP TABLE IF EXISTS products_orders_ok;
CREATE TEMPORARY TABLE products_orders_ok
SELECT 
    product_id
FROM 
    order_items
WHERE order_id IN (SELECT order_id FROM orders WHERE 
    YEAR(order_purchase_timestamp) = '2018' 
    AND order_status = "delivered" 
    AND order_id IN 
            (SELECT order_id FROM order_payments
                            WHERE payment_type = "credit_card" 
                            AND payment_value > 1000));

SELECT 
    COUNT(*)
FROM
    products_orders_ok;

DROP TABLE IF EXISTS products_Ben;
CREATE TEMPORARY TABLE products_Ben
SELECT product_id FROM products_orders_ok
WHERE product_id IN (SELECT product_id FROM products_H_P_english);

SELECT 
    COUNT(product_id)
FROM
    products_Ben;
 
/*

For the products that you selected, get the following information:

1. The average weight of those products 
2. The cities where there are sellers that sell those products
3. The cities where there are customers who bought products

*/

SELECT 
    AVG(product_weight_g)
FROM
    (SELECT 
        product_weight_g
    FROM
        health_beauty_products_filtered
    GROUP BY product_id) AS distinct_beauty_products;-- 7952.5600
        
SELECT 
    AVG(product_weight_g)
FROM
    products
WHERE
    product_id IN (SELECT 
            product_id
        FROM
            prod_yan);

SELECT 
    AVG(product_weight_g)
FROM
    products
WHERE
    product_id IN (SELECT 
            product_id
        FROM
            products_Ben);

-- 2. The names of the cities where there are sellers that sell those products
SELECT DISTINCT
    city
FROM
    geo
WHERE
    zip_code_prefix IN (SELECT 
            seller_zip_code_prefix
        FROM
            order_items
                JOIN
            sellers USING (seller_id)
        WHERE
            product_id IN (SELECT 
                    product_id
                FROM
                    products_Ben));

SELECT DISTINCT
    city
FROM
    geo g
        JOIN
    health_beauty_products_filtered hbpf ON g.zip_code_prefix = hbpf.seller_zip_code_prefix;-- 9 cities


-- 3. The cities of the customers of those products
SELECT DISTINCT
    city
FROM
    geo g
        JOIN
    health_beauty_products_filtered hbpf ON g.zip_code_prefix = hbpf.customer_zip_code_prefix; -- 34 cities

