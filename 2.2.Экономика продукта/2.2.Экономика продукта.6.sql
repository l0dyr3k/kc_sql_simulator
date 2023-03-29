with t1 as (
    select  name,
            sum(price) revenue,
            round(100 * sum(price) / sum(sum(price)) over (), 2) share_in_revenue
    from    (
            select  creation_time::date date,
                    unnest(product_ids) product_id
            from    orders
            where   order_id not in (select order_id from user_actions where action = 'cancel_order')
            ) as t1 left join
            products using (product_id)
    group by name
)
select  name as product_name,
        revenue,
        share_in_revenue
from    t1
where   share_in_revenue >= 0.5
union
select  'ДРУГОЕ' as product_name,
        sum(revenue) as revenue,
        sum(share_in_revenue) share_in_revenue
from    t1
where   share_in_revenue < 0.5
order by revenue desc