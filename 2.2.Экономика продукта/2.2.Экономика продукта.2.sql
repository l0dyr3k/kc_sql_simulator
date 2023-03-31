with daily_report as 
(
select  date,
        count(distinct order_id) orders,
        count(distinct user_id) users,
        sum(price) revenue
from    (
        select  order_id,
                creation_time :: date as date,
                unnest(product_ids) as product_id
        from    orders
        where   order_id not in (select order_id from user_actions where action = 'cancel_order')
        ) as a left join 
        (
        select  product_id,
                price
        from    products
        ) as b using (product_id) left join 
        (
        select  order_id,
                user_id
        from    user_actions
        ) as c using (order_id)
group by date
), 
updated_daily_report as 
(
select  *
from    daily_report left join 
        (
        select  time :: date as date,
                count(distinct user_id) all_users
        from    user_actions
        group by date
        ) as d using (date)
)
select  date,
        round(revenue / all_users, 2) arpu,
        round(revenue / users, 2) arppu,
        round(revenue / orders, 2) aov
from    updated_daily_report
order by date