select  date,
        round(revenue :: decimal / users, 2) running_arpu,
        round(revenue :: decimal / paying_users, 2) running_arppu,
        round(revenue :: decimal / orders, 2) running_aov
from    (
        select  date,
                sum(count(user_id)) over (order by date rows between unbounded preceding and current row) users
        from    (
                select  min(time :: date) as date,
                        user_id
                from    user_actions
                group by user_id
                ) as t1
        group by date
        ) as t1 join 
        (
        select  date,
                sum(count(paying_user_id)) over (order by date rows between unbounded preceding and current row) paying_users
        from    (
                select  min(time :: date) as date,
                        user_id paying_user_id
                from    user_actions
                where   order_id not in (select order_id from user_actions where action = 'cancel_order')
                group by user_id
                ) as t1
        group by date
        ) as t2 using (date) join 
        (
        select  date,
                sum(sum(price)) over (order by date) revenue,
                sum(count(distinct order_id)) over (order by date) orders
        from    (
                select  creation_time :: date date,
                        order_id,
                        unnest(product_ids) product_id
                from    orders
                where   order_id not in (select order_id from user_actions where action = 'cancel_order')
                ) as t1 left join 
                (
                select  product_id,
                        price
                from    products
                ) as t2 using (product_id)
        group by date
        ) as t3 using (date)
order by date