-- Oracle 19c 점검 SQL
SET LINESIZE 200
SET PAGESIZE 100
SET MARKUP HTML ON SPOOL ON ENTMAP OFF PREFORMAT OFF
SPOOL /home/oracle/check_report/dbcheck.html

PROMPT <h1>✅ Oracle 19c DB 내부 점검 보고서</h1>

PROMPT <h2>[DB 초기화 파라미터 확인]</h2>
SELECT name, value FROM v$parameter
WHERE name IN (
  'memory_target','sga_target','pga_aggregate_target',
  'processes','sessions','transactions',
  'undo_tablespace','undo_retention',
  'db_create_file_dest','db_recovery_file_dest',
  'db_recovery_file_dest_size','nls_language','nls_territory',
  'nls_date_format','audit_trail'
);

PROMPT <h2>[아카이브 모드 확인]</h2>
ARCHIVE LOG LIST;

PROMPT <h2>[테이블스페이스 상태 확인]</h2>
SELECT tablespace_name, file_name, autoextensible, bytes/1024/1024 AS size_mb
FROM dba_data_files;

PROMPT <h2>[임시 테이블스페이스 확인]</h2>
SELECT tablespace_name, file_name, autoextensible, bytes/1024/1024 AS size_mb
FROM dba_temp_files;

PROMPT <h2>[계정 잠금/만료 상태 확인]</h2>
SELECT username, account_status FROM dba_users
WHERE username IN ('SYS','SYSTEM','DBSNMP','OUTLN');

PROMPT <h2>[프로필 비밀번호 정책 확인]</h2>
SELECT profile, resource_name, limit FROM dba_profiles
WHERE resource_name LIKE 'PASSWORD%';

PROMPT <h2>[백업 관련 FRA 확인]</h2>
SHOW PARAMETER db_recovery_file_dest;
SHOW PARAMETER db_recovery_file_dest_size;

PROMPT <h2>[성능 진단 관련]</h2>
SHOW PARAMETER statistics_level;
SHOW PARAMETER diagnostic_dest;

PROMPT <h2>[감사 설정 확인]</h2>
SHOW PARAMETER audit_trail;

PROMPT <h2>[완료]</h2>

SPOOL OFF
SET MARKUP HTML OFF

