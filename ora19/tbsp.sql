select   t.tablespace_name, free_size,
round( ((t.total_size - f.free_size) / t.total_size) * 100) usedspace
from (select tablespace_name, sum(bytes)/1024/1024 total_size
from dba_data_files
group by tablespace_name) t,
(select tablespace_name, sum(bytes)/1024/1024 free_size
from dba_free_space
group by tablespace_name) f
where t.tablespace_name = f.tablespace_name(+)
/
