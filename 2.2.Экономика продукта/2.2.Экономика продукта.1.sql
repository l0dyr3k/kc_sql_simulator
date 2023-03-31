with daily_revenue as 
(
select  creation_time::date as date,
        sum(price) as revenue
from    (
        select  order_id,
                creation_time,
                unnest(product_ids) as product_id
        from    orders
        where   order_id not in (select order_id from user_actions where action = 'cancel_order')
        ) as a left join 
        (
        select  product_id,
                price
        from    products
        ) as b using (product_id)
group by date
)
select  date,
        revenue,
        sum(revenue) over (order by date) as total_revenue,
        round(((revenue::decimal / lag(revenue) over (order by date)) - 1) * 100, 2) as revenue_change
from    daily_revenue
order by date