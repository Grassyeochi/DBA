-- 사용자 권환 확인
SET LINESIZE 300
SET PAGESIZE 50
SET WRAP OFF
SET TRIMSPOOL ON

COL grantee     FOR a10
COL owner       FOR a10
COL table_name  FOR a30
COL grantor     FOR a12
COL privilege   FOR a30
COL type        FOR a10

SELECT * FROM session_privs;

prompt ==================================================================================================================

SELECT grantee, owner, table_name, grantor, privilege, type
FROM user_tab_privs;


