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
FROM    user_actions)
SELECT  date,
        new_users,
        new_couriers,
        sum(new_users) OVER (ORDER BY date)::int total_users,
        sum(new_couriers) OVER (ORDER BY date)::int total_couriers
FROM    (
        SELECT  date,
                count(courier_id) filter (WHERE date = first_day) new_couriers
        FROM    courier_list
        GROUP BY date
        ) as a full join 
        (
        SELECT  date,
                count(user_id) filter (WHERE date = first_day) new_users
        FROM    user_list
        GROUP BY date
        ) as b using (date)
ORDER BY date