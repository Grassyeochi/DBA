SELECT name, value/1024/1024 AS "Size(MB)"
FROM v$pgastat
WHERE name IN ('total PGA allocated', 
               'total PGA inuse',
               'total PGA used for auto workareas',
               'total PGA used for manual workareas');
