INSERT INTO employees (id, name)
SELECT
    gen_random_uuid(),
    'Employee_' || i
FROM generate_series(1, 10) AS s(i);

INSERT INTO workorders (id, createdat, scheduledstart, completedat, status)
SELECT
    gen_random_uuid(),

    NOW() - (INTERVAL '10 days' * random()),

    NOW() - (INTERVAL '8 days' * random()),

    CASE
        WHEN random() > 0.2 THEN NOW() - (INTERVAL '1 days' * random())
        ELSE NULL
        END,

    CASE
        WHEN random() > 0.2 THEN 'completed'
        ELSE 'in_progress'
        END
FROM generate_series(1, 50);

WITH workorder_list AS (
    SELECT id FROM workorders
),
     employee_list AS (
         SELECT id FROM employees
     ),
     session_seed AS (
         SELECT
             wo.id AS workorderid,
             (SELECT id FROM employee_list ORDER BY random() LIMIT 1) AS employeeid,
             generate_series(1, (3 + floor(random() * 5))::int) AS session_index,
             NOW() - (INTERVAL '5 days' * random()) AS base_time
         FROM workorder_list wo
     ),
     sessions AS (
         SELECT
             workorderid,
             employeeid,

             CASE
                 WHEN session_index % 2 = 0 THEN 'pause'
                 ELSE 'work'
                 END AS sessiontype,

             base_time + (session_index * INTERVAL '30 minutes') AS starttime,

             base_time
                 + (session_index * INTERVAL '30 minutes')
                 + (INTERVAL '10 minutes' * (1 + random())) AS endtime
         FROM session_seed
     )

INSERT INTO worksessions (
    id,
    workorderid,
    employeeid,
    sessiontype,
    starttime,
    endtime
)
SELECT
    gen_random_uuid(),
    workorderid,
    employeeid,
    sessiontype,
    starttime,
    endtime
FROM sessions;