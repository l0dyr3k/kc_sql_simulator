SELECT  date,
        (avg(extract(epoch FROM delivered - accepted)) / 60) :: integer minutes_to_deliver
FROM    (
        SELECT  max(time :: date) date,
                courier_id,
                order_id,
                min(time) accepted,
                max(time) delivered
        FROM    courier_actions
        WHERE   order_id not in (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
        GROUP BY courier_id, order_id
        ) as t1
GROUP BY date
ORDER BY date