select sid, lmode, request, block 
from v$lock 
where type in ('TX', 'TM');

/
