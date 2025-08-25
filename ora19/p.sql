set lines 5000
set pages 4000

SELECT * FROM table(dbms_xplan.display_cursor(null, null, 'ALLSTATS LAST'));
