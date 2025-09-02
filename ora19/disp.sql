-- 현재 실행 중인 디스패처 프로세스와 상태를 확인하여 MTS 클라이언트 연결 상태를 모니터링

select name, status from v$dispatcher
/
