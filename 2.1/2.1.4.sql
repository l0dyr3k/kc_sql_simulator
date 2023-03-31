SELECT  date,
        round(single_order_users :: decimal / paying_users * 100, 2) single_order_users_share,
        round(several_order_users :: decimal / paying_users * 100, 2) several_orders_users_share
FROM    (
        SELECT  date,
                count(user_id) filter (WHERE orders = 1) single_order_users,
                count(user_id) filter (WHERE orders > 1) several_order_users,
                count(user_id) paying_users
        FROM    (
                SELECT  time :: date date,
                        user_id,
                        count(distinct order_id) orders
                FROM    user_actions
                WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
                GROUP BY date, user_id
                ) as t1
        GROUP BY date
        ) as t2
ORDER BY date