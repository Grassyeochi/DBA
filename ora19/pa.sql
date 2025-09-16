-- 실행중인 병렬 쿼리 확인

select  process, program
   from  v$session
   where  program  like  '%(P0%'
/
