-- tx_lock_full.sql 

-- 락 모니터링 및 Kill 명령어 생성
SET PAGESIZE 30
SET LINESIZE 300
SET WRAP OFF

COLUMN sid FORMAT 999 HEADING "SID"
COLUMN username FORMAT A8 HEADING "USERNAME"
COLUMN type FORMAT A4 HEADING "TYPE"
COLUMN lmode FORMAT 999 HEADING "LMODE"
COLUMN request FORMAT 999 HEADING "REQUEST"
COLUMN block FORMAT 9 HEADING "BLOCK"
COLUMN holding FORMAT A10 HEADING "HOLDING"
COLUMN waiting FORMAT A10 HEADING "WAITING"
COLUMN status FORMAT A8 HEADING "STATUS"
COLUMN wait_st FORMAT A8 HEADING "WAIT"

-- 락 상황 조회
SELECT 
    l.sid,
    NVL(s.username,'?') as username,
    l.type,
    l.lmode,
    l.request,
    l.block,
    DECODE(l.lmode,0,'None',1,'Null',2,'Row-S',3,'Row-X',4,'Share',5,'S/Row-X',6,'Exclusive') as holding,
    DECODE(l.request,0,'None',1,'Null',2,'Row-S',3,'Row-X',4,'Share',5,'S/Row-X',6,'Exclusive') as waiting,
    DECODE(l.block,1,'BLOCKER',DECODE(l.request,0,'HOLDER','WAITER')) as status,
    CASE WHEN sw.event LIKE '%TX%' THEN 'TX-WAIT' 
         ELSE 'OK' END as wait_st
FROM v$lock l, v$session s, v$session_wait sw
WHERE l.sid = s.sid
  AND l.sid = sw.sid (+)
  AND l.type IN ('TX', 'TM')
  AND (l.lmode > 0 OR l.request > 0)
ORDER BY l.block DESC, l.sid;

PROMPT
PROMPT ======================= KILL COMMANDS =======================

-- BLOCKER Kill 명령어
COLUMN kill_blocker FORMAT A80 HEADING "KILL BLOCKER COMMAND"
SELECT 'ALTER SYSTEM KILL SESSION '''||l.sid||','||s.serial#||''';' as kill_blocker
FROM v$lock l, v$session s
WHERE l.sid = s.sid
  AND l.type = 'TX'
  AND l.block = 1;

PROMPT
PROMPT ==================== OPTIONAL WAITER KILL ====================

-- WAITER Kill 명령어
COLUMN kill_waiter FORMAT A80 HEADING "KILL WAITER COMMAND"  
SELECT 'ALTER SYSTEM KILL SESSION '''||l.sid||','||s.serial#||''';' as kill_waiter
FROM v$lock l, v$session s
WHERE l.sid = s.sid
  AND l.type = 'TX'
  AND l.request > 0;
COLUMN block FORMAT 9 HEADING "B"
COLUMN holding FORMAT A6 HEADING "HOLD"
COLUMN waiting FORMAT A6 HEADING "WANT"
COLUMN status FORMAT A6 HEADING "STAT"
COLUMN wait_st FORMAT A4 HEADING "WAIT"
