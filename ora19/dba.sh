#!/bin/bash

echo -e "
           dba 작업을 자동화하는 쉘 스크립트
"
echo -e " ================================= "
echo "                                       "
echo "
[0] DB 시작 하려면 0번을 누르세요.
[1] DB에서 발생한 TX 락을 확인하려면 1번을 누르세요.
[2] DB에서 발생한 악성 SQL을 확인하려면 2번을 누르세요
[3] TOP명령어로 확인한 프로세서 번호로 해당 세션의 정보를 확인하고 싶으면 3번을 누르세요
[4] ora19 alert log file을 실시간 모니터링하려면 4번을 누르세요
[5] ora19dw alert log file을 실시간 모니터링하려면 5번을 누르세요
[6] ora192 alert log file을 실시간 모니터링하려면 6번을 누르세요
"
echo "                                "
echo -n "원하는 작업번호를 누르세요 "
read aa
echo "                                "
case $aa in
    0) sh /home/oracle/start.sql ;;
    1) sqlplus -s system/oracle_4U @/home/oracle/lock.sql ;;
    2) sqlplus -s system/oracle_4U @/home/oracle/bad.sql ;;
    3) sqlplus -s system/oracle_4U @/home/oracle/spid.sql ;;
    4) tail -f /u01/app/oracle/diag/rdbms/oracle19/oracle19/trace/alert* ;;
    5) tail -f /u01/app/oracle/diag/rdbms/ora19dw/ora19dw/trace/alert* ;;
    6) tail -f /u01/app/oracle/diag/rdbms/ora192/ORA192/trace/alert* ;;
esac
echo "                                "               
