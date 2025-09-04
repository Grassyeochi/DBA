select sid, type, lmode, request, block
from v$lock
where type in ('TX', 'TM')
order by sid asc
/
