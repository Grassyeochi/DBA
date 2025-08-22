#!/bin/bash
# sh.start.sql

# 1. Listener 시작
lsnrctl start

# 2. DB 시작 (SYSDBA 권한)
sqlplus / as sysdba <<EOF
startup
exit;
EOF

echo "실행완료"
