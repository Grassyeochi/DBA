col segment_name for a10

select segment_name, extent_id, bytes/1024
from user_extents
where segment_name = 'EMP999';
