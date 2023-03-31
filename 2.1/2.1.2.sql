with courier_list as 
(
SELECT  DISTINCT time::date as date,
        courier_id,
        min(time::date) OVER (PARTITION BY courier_id) as first_day
FROM    courier_actions
), 
user_list as 
(
SELECT  DISTINCT time::date as date,
        user_id,
        min(time::date) OVER (PARTITION BY user_id) as first_day
FROM    user_actions
), 
new_users_and_couriers as 
(
SELECT  date,
        new_users,
        new_couriers,
        sum(new_users) OVER (ORDER BY date)::int total_users,
        sum(new_couriers) OVER (ORDER BY date)::int total_couriers
FROM    (
        SELECT  date,
                count(courier_id) filter (WHERE date = first_day) new_couriers
        FROM   courier_list
        GROUP BY date
        ) as a full join 
        (
        SELECT  date,
                count(user_id) filter (WHERE date = first_day) new_users
        FROM    user_list
        GROUP BY date
        ) as b using (date)
ORDER BY date
)
SELECT  date,
        new_users,
        new_couriers,
        total_users,
        total_couriers,
        round(new_users / lag(new_users, 1) OVER (ORDER BY date)::decimal * 100 - 100, 2) new_users_change,
        round(new_couriers / lag(new_couriers, 1) OVER (ORDER BY date)::decimal * 100 - 100, 2) new_couriers_change,
        round(total_users / lag(total_users, 1) OVER (ORDER BY date)::decimal * 100 - 100, 2) total_users_growth,
        round(total_couriers / lag(total_couriers, 1) OVER (ORDER BY date)::decimal * 100 - 100, 2) total_couriers_growth
FROM    new_users_and_couriers