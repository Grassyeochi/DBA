col holder for a15
col waiter for a15
select decode(status,'INACTIVE',username || ' ' || sid || ',' || serial#,'lock') as Holder,
       decode(status,'ACTIVE',  username || ' ' || sid || ',' || serial#,'lock') as waiter, sid, serial#, status
    from( select level as le, NVL(s.username,'(oracle)') AS username,
    s.osuser,
    s.sid,
    s.serial#,
    s.lockwait,
    s.module,
    s.machine,
    s.status,
    s.program,
    to_char(s.logon_TIME, 'DD-MON-YYYY HH24:MI:SS') as logon_time
       from v$session s
      where level>1
                or EXISTS( select 1
    from v$session
    where blocking_session = s.sid)
      CONNECT by PRIOR s.sid = s.blocking_session
  START WITH s.blocking_session is null );

!echo "락 홀더 세션을 죽이고 싶으면 아래의 SQL을 참고하세요"
!echo " alter system kill session '136,61515' immediate; "

exit;
