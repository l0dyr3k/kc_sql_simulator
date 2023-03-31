SELECT  date,
        round(paying_users :: decimal / active_couriers, 2) users_per_courier,
        round(orders :: decimal / active_couriers, 2) orders_per_courier
FROM    (
        SELECT  time :: date date,
                count(distinct courier_id) active_couriers
        FROM    courier_actions
        WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
        GROUP BY date
        ) as t1 join 
        (
        SELECT  time :: date date,
                count(distinct user_id) paying_users
        FROM    user_actions
        WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
        GROUP BY date
        ) as t2 using (date) join 
        (
        SELECT  creation_time :: date date,
                count(order_id) orders
        FROM    orders
        WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
        GROUP BY date
        ) as t3 using (date)