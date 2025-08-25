#!/bin/bash

#환경변수 불러오기
source /home/oracle/.bash_profile

# ORACLE Server 시작
/u01/app/oracle/product/19.3.0/dbhome_1/bin/sqlplus / as sysdba <<EOF
startup;
exit;
EOF

export ORACLE_SID=ora19dw

/u01/app/oracle/product/19.3.0/dbhome_1/bin/sqlplus / as sysdba <<EOF
startup;
exit;
EOF

export ORACLE_SID=ORA19

# 리스너 시작
/u01/app/oracle/product/19.3.0/dbhome_1/bin/lsnrctl start

#git
cd /home/oracle/DBA/
git pull origin main
cd
