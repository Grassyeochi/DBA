set lines 5000
set pages 4000

select file_id, tablespace_name, file_name
from dba_data_files;

