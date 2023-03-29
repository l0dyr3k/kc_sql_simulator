with daily_report as 
(
SELECT  date,
        count(distinct order_id) orders,
        count(distinct user_id) users,
        sum(price) revenue
FROM    (
        SELECT  order_id,
                creation_time :: date as date,
                unnest(product_ids) as product_id
        FROM    orders
        WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
        ) as a LEFT JOIN 
        (
        SELECT  product_id,
                price
        FROM    products
        ) as b using (product_id) LEFT JOIN 
        (
        SELECT  order_id,
                user_id
        FROM    user_actions
        ) as c using (order_id)
GROUP BY date
), 
updated_daily_report as 
(
SELECT  *
FROM    daily_report LEFT JOIN 
        (
        SELECT  time :: date as date,
                count(distinct user_id) all_users
        FROM    user_actions
        GROUP BY date
        ) as d using (date)
)
SELECT  date,
        round(revenue / all_users, 2) arpu,
        round(revenue / users, 2) arppu,
        round(revenue / orders, 2) aov
FROM    updated_daily_report
ORDER BY date