with delivers as (
    select  date,
            sum(delivers * 150) deliver_costs,
            sum(case 
                when delivers >= 5 and date_part('month', date) = 8 then 400
                when delivers >= 5 then 500 
                else 0 
                end) bonus_costs
    from    (
            select  time::date date, courier_id, count(distinct order_id) delivers
            from    courier_actions
            where   action = 'deliver_order' and
                    order_id not in (select order_id from user_actions where action = 'cancel_order')
            group by date, courier_id
            ) as t1
    group by date
),
assemblies as (
    select  time::date date,
            sum(case
                when date_part('month', time::date) = 8 then 140
                else 115
                end) assembly_costs
    from    user_actions
    where   order_id not in (select order_id from user_actions where action = 'cancel_order')
    group by date
),
revenue_and_vat as (
    select  date,
            sum(price) revenue,
            sum(case
                when name in ('сахар', 'сухарики', 'сушки', 'семечки', 
                              'масло льняное', 'виноград', 'масло оливковое', 
                              'арбуз', 'батон', 'йогурт', 'сливки', 'гречка', 
                              'овсянка', 'макароны', 'баранина', 'апельсины', 
                              'бублики', 'хлеб', 'горох', 'сметана', 'рыба копченая', 
                              'мука', 'шпроты', 'сосиски', 'свинина', 'рис', 
                              'масло кунжутное', 'сгущенка', 'ананас', 'говядина', 
                              'соль', 'рыба вяленая', 'масло подсолнечное', 'яблоки', 
                              'груши', 'лепешка', 'молоко', 'курица', 'лаваш', 'вафли', 'мандарины') then round(price / 110 * 10, 2)
                else round(price / 120 * 20, 2)
                end) vat
    from    (
            select  creation_time::date date, unnest(product_ids) product_id
            from    orders
            where   order_id not in (select order_id from user_actions where action = 'cancel_order')
            ) as t2 left join
            products using (product_id)
    group by date
)
select  date,
        revenue,
        (assembly_costs + deliver_costs + bonus_costs + fixed_costs)::int costs,
        vat tax,
        revenue - (assembly_costs + deliver_costs + bonus_costs + fixed_costs) - vat gross_profit,
        sum(revenue) over (order by date) total_revenue,
        sum(assembly_costs + deliver_costs + bonus_costs + fixed_costs) over (order by date) total_costs,
        sum(vat) over (order by date) total_tax,
        sum(revenue - (assembly_costs + deliver_costs + bonus_costs + fixed_costs) - vat) over (order by date) total_gross_profit,
        round(100 * (revenue - (assembly_costs + deliver_costs + bonus_costs + fixed_costs) - vat) / revenue, 2) gross_profit_ratio,
        round(100 * (sum(revenue - (assembly_costs + deliver_costs + bonus_costs + fixed_costs) - vat) over (order by date)) / (sum(revenue) over (order by date)), 2) total_gross_profit_ratio
from    revenue_and_vat join
        assemblies using (date) join
        delivers using (date) join
        (
        select  distinct time::date date,
                case
                when date_part('month', time::date) = 8 then 120000
                else 150000
                end fixed_costs
        from    user_actions
        ) as t3 using (date)
order by date