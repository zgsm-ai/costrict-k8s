-- Auth users table
-- ----------------------------
-- Table structure for auth_users
-- ----------------------------
-- DROP TABLE IF EXISTS "public"."auth_users";
CREATE TABLE "public"."auth_users" (
  "id" uuid NOT NULL,
  "created_at" timestamptz(0),
  "updated_at" timestamptz(0),
  "access_time" timestamptz(0),
  "name" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "github_id" varchar(100) COLLATE "pg_catalog"."default",
  "github_name" varchar(100) COLLATE "pg_catalog"."default",
  "vip" int8 DEFAULT 0,
  "phone" varchar(20) COLLATE "pg_catalog"."default",
  "email" varchar(100) COLLATE "pg_catalog"."default",
  "password" varchar(100) COLLATE "pg_catalog"."default",
  "company" varchar(100) COLLATE "pg_catalog"."default",
  "location" varchar(100) COLLATE "pg_catalog"."default",
  "user_code" varchar(100) COLLATE "pg_catalog"."default",
  "external_accounts" varchar(100) COLLATE "pg_catalog"."default",
  "employee_number" varchar(100) COLLATE "pg_catalog"."default",
  "github_star" text COLLATE "pg_catalog"."default",
  "devices" jsonb
);

-- ----------------------------
-- Indexes structure for table auth_users
-- ----------------------------
CREATE INDEX "idx_auth_users_email" ON "public"."auth_users" USING btree (
  "email" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE UNIQUE INDEX "idx_auth_users_github_id" ON "public"."auth_users" USING btree (
  "github_id" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_auth_users_name" ON "public"."auth_users" USING btree (
  "name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table auth_users
-- ----------------------------
ALTER TABLE "public"."auth_users" ADD CONSTRAINT "auth_users_pkey" PRIMARY KEY ("id");
