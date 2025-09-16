# /home/oracle/exec_gather_stats_sh.sql

begin
dbms_stats.gather_schema_stats('SH');
end;
/

exit;
