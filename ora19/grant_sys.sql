-- 출력 환경 설정
SET LINESIZE 300
SET PAGESIZE 50
SET WRAP OFF
SET TRIMSPOOL ON

COL grantee      FOR a20
COL privilege    FOR a30
COL granted_role FOR a30
COL owner        FOR a20
COL table_name   FOR a30

PROMPT ===========================================
PROMPT [시스템 권한 - SYSTEM PRIVILEGES]
PROMPT ===========================================

SELECT grantee, privilege, admin_option
FROM dba_sys_privs
WHERE grantee NOT IN ('SYS','SYSTEM', 'SCOTT')
ORDER BY grantee, privilege;

PROMPT ===========================================
PROMPT [객체 권한 - OBJECT PRIVILEGES]
PROMPT ===========================================

SELECT grantee, owner, table_name, privilege, grantable
FROM dba_tab_privs
WHERE grantee NOT IN ('SYS','SYSTEM', 'SCOTT')
ORDER BY grantee, owner, table_name;

PROMPT ===========================================
PROMPT [롤 권한 - ROLE PRIVILEGES]
PROMPT ===========================================

SELECT grantee, granted_role, admin_option, default_role
FROM dba_role_privs
WHERE grantee NOT IN ('SYS','SYSTEM', 'SCOTT')
ORDER BY grantee, granted_role;

