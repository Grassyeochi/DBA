col tablespace_name for a10
col file_name for a55
col mb_size for 9999

select tablespace_name, file_name, bytes/1024/1024 mb_size
from dba_data_files;
