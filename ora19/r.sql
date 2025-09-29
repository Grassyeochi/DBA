-- 복구가 필요한 파일 확인
select d.file#, d.name
from v$recover_file r, v$datafile d
where r.file#=d.file#
/

