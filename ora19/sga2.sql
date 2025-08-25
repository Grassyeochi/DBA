-- SGA 풀별 사용량
SELECT pool, 
       SUM(bytes)/1024/1024 AS "Used(MB)",
       SUM(bytes)/1024/1024/1024 AS "Used(GB)"
FROM v$sgastat 
WHERE pool IS NOT NULL
GROUP BY pool
ORDER BY SUM(bytes) DESC;
