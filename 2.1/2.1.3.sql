SELECT  start_date date,
        paying_users,
        active_couriers,
        round(paying_users :: decimal / all_users * 100, 2) paying_users_share,
        round(active_couriers :: decimal / all_couriers * 100, 2) active_couriers_share
FROM    (
        SELECT  time :: date start_date,
                count(distinct user_id) paying_users
        FROM    user_actions
        WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
        GROUP BY start_date
        ) as b join 
        (
        SELECT  time :: date start_date,
                count(distinct courier_id) active_couriers
        FROM    courier_actions
        WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
        GROUP BY start_date
        ) as d using (start_date) join 
        (
        SELECT  start_date,
                sum(count(user_id)) OVER (ORDER BY start_date) all_users
        FROM    (
                SELECT  user_id,
                        min(time :: date) start_date
                FROM    user_actions
                GROUP BY user_id
                ) as e
        GROUP BY start_date
        ) as f using (start_date) join 
        (
        SELECT  start_date,
                sum(count(courier_id)) OVER (ORDER BY start_date) all_couriers
        FROM    (
                SELECT  courier_id,
                        min(time :: date) start_date
                FROM    courier_actions
                GROUP BY courier_id
                ) as g
        GROUP BY start_date
        ) as h using (start_date)
ORDER BY start_date