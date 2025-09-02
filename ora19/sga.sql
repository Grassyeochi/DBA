-- sga 메모리 상태 확인

PROMPT *** CURRENT parameter settings ***
col name format a12
col VALUE format a8
SHOW parameter sga_
PROMPT
PROMPT *** SGA Dynamic Component SIZE Information***
col component format a22
col current_size format a15
col min_size format a15

SELECT component,current_size/1048576||'M' current_size,
       min_size/1048576||'M' min_size
FROM v$sga_dynamic_components
WHERE component IN ('shared pool','large pool',
                   'java pool','DEFAULT buffer cache');

col name format a20
col VALUE format a20
PROMPT *** CURRENT parameter settings IN V$PARAMETER *** 

SELECT name, VALUE, isdefault 
FROM v$parameter
WHERE name IN ('shared_pool_size','large_pool_size',
               'java_pool_size', 'db_cache_size'); 

