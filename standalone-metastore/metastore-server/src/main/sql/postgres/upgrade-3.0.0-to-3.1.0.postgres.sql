SELECT 'Upgrading MetaStore schema from 3.0.0 to 3.1.0';

-- HIVE-19440
ALTER TABLE "GLOBAL_PRIVS" ADD COLUMN IF NOT EXISTS "AUTHORIZER" character varying(128) DEFAULT NULL::character varying;
ALTER TABLE "GLOBAL_PRIVS" DROP CONSTRAINT IF EXISTS "GLOBALPRIVILEGEINDEX";
ALTER TABLE ONLY "GLOBAL_PRIVS"
    ADD CONSTRAINT "GLOBALPRIVILEGEINDEX" UNIQUE ("AUTHORIZER", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "USER_PRIV", "GRANTOR", "GRANTOR_TYPE");

ALTER TABLE "DB_PRIVS" ADD COLUMN IF NOT EXISTS "AUTHORIZER" character varying(128) DEFAULT NULL::character varying;
ALTER TABLE "DB_PRIVS" DROP CONSTRAINT IF EXISTS "DBPRIVILEGEINDEX";
ALTER TABLE ONLY "DB_PRIVS"
    ADD CONSTRAINT "DBPRIVILEGEINDEX" UNIQUE ("AUTHORIZER", "DB_ID", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "DB_PRIV", "GRANTOR", "GRANTOR_TYPE");

ALTER TABLE "TBL_PRIVS" ADD COLUMN IF NOT EXISTS "AUTHORIZER" character varying(128) DEFAULT NULL::character varying;
DROP INDEX IF EXISTS "TABLEPRIVILEGEINDEX";
CREATE INDEX IF NOT EXISTS "TABLEPRIVILEGEINDEX" ON "TBL_PRIVS" USING btree ("AUTHORIZER", "TBL_ID", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "TBL_PRIV", "GRANTOR", "GRANTOR_TYPE");

ALTER TABLE "PART_PRIVS" ADD COLUMN IF NOT EXISTS "AUTHORIZER" character varying(128) DEFAULT NULL::character varying;
DROP INDEX IF EXISTS "PARTPRIVILEGEINDEX";
CREATE INDEX IF NOT EXISTS "PARTPRIVILEGEINDEX" ON "PART_PRIVS" USING btree ("AUTHORIZER", "PART_ID", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "PART_PRIV", "GRANTOR", "GRANTOR_TYPE");

ALTER TABLE "TBL_COL_PRIVS" ADD COLUMN IF NOT EXISTS "AUTHORIZER" character varying(128) DEFAULT NULL::character varying;
DROP INDEX IF EXISTS "TABLECOLUMNPRIVILEGEINDEX";
CREATE INDEX IF NOT EXISTS "TABLECOLUMNPRIVILEGEINDEX" ON "TBL_COL_PRIVS" USING btree ("AUTHORIZER", "TBL_ID", "COLUMN_NAME", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "TBL_COL_PRIV", "GRANTOR", "GRANTOR_TYPE");

ALTER TABLE "PART_COL_PRIVS" ADD COLUMN IF NOT EXISTS "AUTHORIZER" character varying(128) DEFAULT NULL::character varying;
DROP INDEX IF EXISTS "PARTITIONCOLUMNPRIVILEGEINDEX";
CREATE INDEX IF NOT EXISTS "PARTITIONCOLUMNPRIVILEGEINDEX" ON "PART_COL_PRIVS" USING btree ("AUTHORIZER", "PART_ID", "COLUMN_NAME", "PRINCIPAL_NAME", "PRINCIPAL_TYPE", "PART_COL_PRIV", "GRANTOR", "GRANTOR_TYPE");

CREATE INDEX IF NOT EXISTS "TAB_COL_STATS_IDX" ON "TAB_COL_STATS" USING btree ("CAT_NAME", "DB_NAME","TABLE_NAME","COLUMN_NAME");

-- HIVE-19340
ALTER TABLE TXNS ADD COLUMN IF NOT EXISTS TXN_TYPE integer DEFAULT NULL;

-- HIVE-19027
-- ADD COLUMN IF NOT EXISTS MATERIALIZATION_TIME (bigint) to MV_CREATION_METADATA table
ALTER TABLE "MV_CREATION_METADATA" ADD COLUMN IF NOT EXISTS "MATERIALIZATION_TIME" bigint NULL;
UPDATE "MV_CREATION_METADATA" SET "MATERIALIZATION_TIME" = 0;
ALTER TABLE "MV_CREATION_METADATA" ALTER COLUMN "MATERIALIZATION_TIME" SET NOT NULL;

-- ADD COLUMN IF NOT EXISTS CTC_UPDATE_DELETE (char) to COMPLETED_TXN_COMPONENTS table
ALTER TABLE COMPLETED_TXN_COMPONENTS ADD COLUMN IF NOT EXISTS CTC_UPDATE_DELETE char(1) NULL;
UPDATE COMPLETED_TXN_COMPONENTS SET CTC_UPDATE_DELETE = 'N';
ALTER TABLE COMPLETED_TXN_COMPONENTS ALTER COLUMN CTC_UPDATE_DELETE SET NOT NULL;

CREATE TABLE IF NOT EXISTS MATERIALIZATION_REBUILD_LOCKS (
  MRL_TXN_ID bigint NOT NULL,
  MRL_DB_NAME varchar(128) NOT NULL,
  MRL_TBL_NAME varchar(256) NOT NULL,
  MRL_LAST_HEARTBEAT bigint NOT NULL,
  PRIMARY KEY(MRL_TXN_ID)
);

-- These lines need to be last.  Insert any changes above.
UPDATE "VERSION" SET "SCHEMA_VERSION"='3.1.0', "VERSION_COMMENT"='Hive release version 3.1.0' where "VER_ID"=1;
SELECT 'Finished upgrading MetaStore schema from 3.0.0 to 3.1.0';