# 악성 sql 확인

pid=`top | head -8 | tail -1  | awk '{print $2}'`

echo $pid

output=$(sqlplus -s sys/oracle_4U as sysdba <<EOF

Select  a.sql_text txt
from v\$sqlarea a, v\$session b, v\$process c
where c.spid = '$pid'
and c.addr = b.paddr
and b.sql_address = a.address
and b.sql_hash_value = a.hash_value;
EOF
)

echo $output 
