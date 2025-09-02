-- 데이터베이스의 마지막으로 저장된  체크포인트 확인

select file#, checkpoint_change#
from v$datafile_header
/
