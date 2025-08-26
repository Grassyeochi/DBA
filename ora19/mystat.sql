select
        s.sid, s.serial#, p.spid
from
        v$session s, v$process p
where
        s.sid = (select sid from v$mystat where rownum = 1)
        and s.paddr = p.addr
/
