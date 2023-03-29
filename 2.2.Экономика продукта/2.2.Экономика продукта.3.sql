SELECT  date,
        round(revenue :: decimal / users, 2) running_arpu,
        round(revenue :: decimal / paying_users, 2) running_arppu,
        round(revenue :: decimal / orders, 2) running_aov
FROM    (
        SELECT  date,
                sum(count(user_id)) OVER (ORDER BY date rows between unbounded preceding and current row) users
        FROM    (
                SELECT  min(time :: date) as date,
                        user_id
                FROM    user_actions
                GROUP BY user_id
                ) as t1
        GROUP BY date
        ) as t1 join 
        (
        SELECT  date,
                sum(count(paying_user_id)) OVER (ORDER BY date rows between unbounded preceding and current row) paying_users
        FROM    (
                SELECT  min(time :: date) as date,
                        user_id paying_user_id
                FROM    user_actions
                WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
                GROUP BY user_id
                ) as t1
        GROUP BY date
        ) as t2 using (date) join 
        (
        SELECT  date,
                sum(sum(price)) OVER (ORDER BY date) revenue,
                sum(count(distinct order_id)) OVER (ORDER BY date) orders
        FROM    (
                SELECT  creation_time :: date date,
                        order_id,
                        unnest(product_ids) product_id
                FROM    orders
                WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
                ) as t1 LEFT JOIN 
                (
                SELECT  product_id,
                        price
                FROM    products
                ) as t2 using (product_id)
        GROUP BY date
        ) as t3 using (date)
ORDER BY date