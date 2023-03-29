select  weekday,
        weekday_number,
        round(revenue / users, 2) arpu,
        round(revenue / paying_users, 2) arppu,
        round(revenue / orders, 2) aov
from    (
        select  to_char(time, 'Day') weekday,
                date_part('isodow', time) weekday_number,
                sum(price) revenue,
                count(distinct user_id) paying_users,
                count(distinct order_id) orders
        from    (
                select  user_id, order_id, time, unnest(product_ids) product_id
                from    orders left join
                        user_actions using (order_id)
                where   time >= '2022-08-26' and
                        time <= '2022-09-09' and
                        order_id not in (select order_id from user_actions where action = 'cancel_order')
                ) as t1 left join
                products using (product_id) 
        group by weekday, weekday_number
        ) as t2 join
        (
        select  to_char(time, 'Day') weekday,
                date_part('isodow', time) weekday_number,
                count(distinct user_id) users
        from    orders left join
                user_actions using (order_id)
        where   time >= '2022-08-26' and
                time <= '2022-09-09'
        group by weekday, weekday_number        
        ) as t3 using(weekday, weekday_number)
order by weekday_number