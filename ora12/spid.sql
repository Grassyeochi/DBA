accept  p_spid prompt 'spid 를 입력하세요  ~  '
set verify off

-- SPID를 통해 세션 정보와 현재 SQL 확인
SELECT s.sid, s.serial#, s.username, s.program, s.machine,
       s.status, s.sql_id, t.sql_text
FROM v$session s, v$sqltext t, v$process p
WHERE s.paddr = p.addr
 AND p.spid = &p_spid
  AND s.sql_id = t.sql_id(+)
  AND t.piece = 0
ORDER BY s.sid;

exit;
