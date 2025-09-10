-- alert log file의 위치 확인

SELECT value
FROM   v$diag_info
WHERE  name = 'Diag Alert';
