col current for a10

col current clear

SELECT b.value "Current", a.value "Max", (a.value - b.value) "Diff"
       FROM V$PGASTAT a, V$PGASTAT b
       WHERE a.name = 'aggregate PGA target parameter' AND b.name = 'total PGA inuse'; 
