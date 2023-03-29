with daily_revenue as 
(
SELECT  creation_time::date as date,
        sum(price) as revenue
FROM    (
        SELECT  order_id,
                creation_time,
                unnest(product_ids) as product_id
        FROM    orders
        WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
        ) as a LEFT JOIN 
        (
        SELECT  product_id,
                price
        FROM    products
        ) as b using (product_id)
GROUP BY date
)
SELECT  date,
        revenue,
        sum(revenue) OVER(ORDER BY date) as total_revenue,
        round(((revenue::decimal / lag(revenue) OVER(ORDER BY date)) - 1) * 100, 2) as revenue_change
FROM    daily_revenue
ORDER BY date