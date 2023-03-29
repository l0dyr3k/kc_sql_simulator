select  date_trunc('month', start_date)::date start_month,
        start_date,
        date - start_date day_number,
        round(count(user_id) / max(count(user_id)) over (partition by start_date)::decimal, 2) retention
from    (
        select  distinct user_id, start_date, time::date date
        from    user_actions left join
                (
                select  user_id, min(time::date) start_date
                from    user_actions
                group by user_id    
                ) t1 using (user_id)
        ) t2
group by start_month, start_date, day_number
order by start_date, day_number