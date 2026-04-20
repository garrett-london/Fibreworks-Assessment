CREATE OR REPLACE VIEW workorder_metrics AS
WITH sessions_with_duration AS (
    SELECT
        workOrderId,
        sessionType,
        startTime,
        EXTRACT(EPOCH FROM (COALESCE(endTime, NOW()) - startTime)) AS durationSeconds
    FROM workSessions
),
     work_totals AS (
         SELECT
             workOrderId,
             SUM(CASE WHEN sessionType = 'work' THEN durationSeconds ELSE 0 END) AS workSeconds,
             SUM(CASE WHEN sessionType = 'pause' THEN durationSeconds ELSE 0 END) AS pauseSeconds
         FROM sessions_with_duration
         GROUP BY workOrderId
     ),
     first_work_start AS (
         SELECT
             workOrderId,
             MIN(startTime) AS firstWorkStart
         FROM workSessions
         WHERE sessionType = 'work'
         GROUP BY workOrderId
     )

SELECT
    wo.id,
    wo.createdAt,
    wo.completedAt,
    wt.workSeconds / 60 AS actual_work_minutes,
    wt.pauseSeconds / 60 AS pause_minutes,
    EXTRACT(EPOCH FROM (wo.completedAt - wo.createdAt)) / 60 AS lead_time_minutes,
    EXTRACT(EPOCH FROM (wo.completedAt - fws.firstWorkStart)) / 60 AS cycle_time_minutes,
    wt.pauseSeconds / NULLIF(wt.workSeconds, 0) AS interruption_ratio,
    wt.workSeconds / NULLIF(wt.workSeconds + wt.pauseSeconds, 0) AS efficiency
FROM workOrders wo
         LEFT JOIN work_totals wt ON wt.workOrderId = wo.id
         LEFT JOIN first_work_start fws ON fws.workOrderId = wo.id;
