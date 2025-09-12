-- Character set 확인

select *
from database_properties
where property_name='NLS_CHARACTERSET' or property_name='NLS_NCHAR_CHARACTERSET';
