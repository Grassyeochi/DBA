#bin/bash

export ORACLE_SID=ORA19       
export ORACLE_HOME=/u01/app/oracle/product/19.3.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

sqlplus -s hr/hr <<EOF
@/home/oracle/alter_hr.sql
EOF

