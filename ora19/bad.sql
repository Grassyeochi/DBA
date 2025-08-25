set lines 4000
col "username" format a20
col "kill_command" format a60

-- 높은 리소스를 사용하는 SQL 세션
WITH resource_intensive AS (
    SELECT 
        sql_id,
        sql_text,
        executions,
        disk_reads,
        buffer_gets,
        cpu_time/1000000 AS cpu_seconds,
        elapsed_time/1000000 AS elapsed_seconds,
        CASE 
            WHEN executions > 0 THEN ROUND(disk_reads/executions, 2)
            ELSE disk_reads
        END AS disk_reads_per_exec,
        CASE 
            WHEN executions > 0 THEN ROUND(buffer_gets/executions, 2) 
            ELSE buffer_gets
        END AS buffer_gets_per_exec
    FROM v$sqlarea
    WHERE (disk_reads > 100000 OR buffer_gets > 1000000 OR cpu_time > 10000000)
)
SELECT 
    s.sid,
    s.serial#,
    s.username,
    ri.cpu_seconds,
    'ALTER SYSTEM KILL SESSION ''' || s.sid || ',' || s.serial# || ''' IMMEDIATE;' AS kill_command
FROM 
    v$session s,
    resource_intensive ri,
    v$sqlarea sa
WHERE 
    s.sql_address = sa.address
    AND s.sql_hash_value = sa.hash_value  
    AND sa.sql_id = ri.sql_id
    AND s.username IS NOT NULL
ORDER BY ri.cpu_seconds DESC, ri.disk_reads DESC;

exit;
