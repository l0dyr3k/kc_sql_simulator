SELECT  date,
        orders,
        first_orders,
        new_users_orders,
        round(first_orders :: decimal / orders * 100, 2) first_orders_share,
        round(new_users_orders :: decimal / orders * 100, 2) new_users_orders_share
FROM    (
        SELECT  date,
                orders,
                first_orders,
                new_users_orders
        FROM    (
                SELECT  date,
                        count(*) orders,
                        count(user_id) filter (WHERE date = first_date) new_users_orders
                FROM    (
                        SELECT  time :: date date,
                                user_id,
                                first_date
                        FROM    user_actions LEFT JOIN 
                                (
                                SELECT  user_id,
                                        min(time :: date) first_date
                                FROM    user_actions
                                GROUP BY user_id
                                ) as t1 using (user_id)
                        WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
                        ) as t2
                GROUP BY date
                ) as t3 join 
                (
                SELECT  first_date as date,
                        count(user_id) first_orders
                FROM    (
                        SELECT  user_id,
                                min(time :: date) first_date
                        FROM    user_actions
                        WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
                        GROUP BY user_id
                        ) as t1
                GROUP BY date
                ) as t4 using (date)
        ORDER BY date
        ) as t5
ORDER BY date