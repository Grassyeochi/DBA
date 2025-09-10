-- cpu 개수 확인

select name, value from v$parameter where name like '%cpu%'
/
