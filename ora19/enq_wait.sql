select sid, event
from v$session_wait
where event like '%enq%'
/
