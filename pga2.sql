-- 사용률 (할당량 대비 사용량)
set lines 500
set pages 400

SELECT 
    ROUND(pga_used.value/1024/1024, 2) AS "PGA_Used(MB)",
    ROUND(pga_alloc.value/1024/1024, 2) AS "PGA_Allocated(MB)",
    ROUND(pga_target.value/1024/1024, 2) AS "PGA_Target(MB)",
    ROUND((pga_used.value / pga_alloc.value) * 100, 2) AS "Used_vs_Allocated(%)",
    ROUND((pga_alloc.value / pga_target.value) * 100, 2) AS "Allocated_vs_Target(%)"
FROM 
    (SELECT value FROM v$pgastat WHERE name = 'total PGA inuse') pga_used,
    (SELECT value FROM v$pgastat WHERE name = 'total PGA allocated') pga_alloc,
    (SELECT value FROM v$parameter WHERE name = 'pga_aggregate_target') pga_target;
