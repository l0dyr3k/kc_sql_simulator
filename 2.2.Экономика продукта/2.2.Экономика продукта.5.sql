select  date,
        sum(price) revenue,
        sum(price) filter (where date = first_date) new_users_revenue,
        round(100 * sum(price) filter (where date = first_date) / sum(price), 2) new_users_revenue_share,
        coalesce(round(100 * sum(price) filter (where date <> first_date) / sum(price), 2), 0) old_users_revenue_share
from    (
        select  user_id,
                time::date as date,
                first_date,
                unnest(product_ids) product_id
        from    orders left join
                (
                select  user_id,
                        order_id,
                        time,
                        min(time) over (partition by user_id)::date first_date
                from    user_actions
                ) as t1 using (order_id)
        where   order_id not in (select order_id from user_actions where action = 'cancel_order')
        ) as t1 left join
        products using (product_id)
group by date
order by date