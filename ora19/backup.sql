#!/bin/bash
export ORACLE_SID=oracle19
export ORACLE_HOME=/u01/app/oracle/product/19.3.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

DATE=$(date +%Y%m%d_%H%M%S)

sqlplus -s / as sysdba <<EOF
alter database backup controlfile to trace as '/home/oracle/create_control_${DATE}.sql';
exit;
EOF


