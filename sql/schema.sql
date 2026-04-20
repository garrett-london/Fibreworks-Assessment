CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL
);

CREATE TABLE workOrders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    createdAt TIMESTAMP NOT NULL DEFAULT NOW(),
    scheduledStart TIMESTAMP,
    completedAt TIMESTAMP,
    status TEXT NOT NULL CHECK (status IN ('planned', 'in_progress', 'paused', 'completed'))
);

CREATE TABLE workSessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workOrderId UUID NOT NULL REFERENCES workOrders(id) ON DELETE CASCADE,
    employeeId UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    startTime TIMESTAMP NOT NULL,
    endTime TIMESTAMP,
    sessionType TEXT NOT NULL CHECK (sessionType IN ('work', 'pause')),
    CHECK (endTime IS NULL OR endTime > startTime)
);

CREATE INDEX idx_workSessions_workOrderId ON workSessions(workOrderId);
CREATE INDEX idx_workSessions_employeeId ON workSessions(employeeId);
CREATE INDEX idx_workSessions_startTime ON workSessions(startTime);
