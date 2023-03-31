SELECT  hour :: int,
        successful_orders,
        canceled_orders,
        round(canceled_orders :: decimal / orders, 3) cancel_rate
FROM    (
        SELECT  extract(hour FROM time) as hour, 
                count(distinct order_id) successful_orders
        FROM    user_actions
        WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
        GROUP BY hour
        ) as t1 join 
        (
        SELECT  extract(hour FROM creation_time) as hour, 
                count(distinct order_id) filter (WHERE order_id in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) canceled_orders, 
                count(distinct order_id) orders 
        FROM    orders 
        GROUP BY hour
        ) as t2 using (hour)