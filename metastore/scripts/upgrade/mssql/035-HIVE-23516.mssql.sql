--Create table replication metrics
CREATE TABLE "REPLICATION_METRICS" (
  "RM_SCHEDULED_EXECUTION_ID" bigint PRIMARY KEY,
  "RM_POLICY" varchar(256) NOT NULL,
  "RM_DUMP_EXECUTION_ID" bigint NOT NULL,
  "RM_METADATA" varchar(max),
  "RM_PROGRESS" varchar(max)
);

--Create indexes for the replication metrics table
CREATE INDEX "POLICY_IDX" ON "REPLICATION_METRICS" ("RM_POLICY");
CREATE INDEX "DUMP_IDX" ON "REPLICATION_METRICS" ("RM_DUMP_EXECUTION_ID");