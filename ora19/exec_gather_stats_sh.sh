# /home/oracle/exec_gather_stats_sh.sh
#!/bin/bash

export ORACLE_SID=ORA19       
export ORACLE_HOME=/u01/app/oracle/product/19.3.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

sqlplus -s scott/tiger <<EOF
@/home/oracle/exec_gather_stats_sh.sql
EOF
