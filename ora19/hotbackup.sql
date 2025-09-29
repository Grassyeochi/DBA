
# hotbackup.sh
# ORACLE_HOME, ORACLE_SID 환경변수 확인 필요

export ORACLE_HOME=/u01/app/oracle/product/19.3.0/dbhome_1
export ORACLE_SID=oracle19
export PATH=$ORACLE_HOME/bin:$PATH
BACKUP_DIR=/home/oracle/hotbackup

# 백업 디렉토리 초기화
if [ -d "$BACKUP_DIR" ]; then
    rm -rf $BACKUP_DIR
fi
mkdir -p $BACKUP_DIR

# 1. 테이블스페이스 BEGIN BACKUP
sqlplus -s / as sysdba <<EOF
set echo on
alter tablespace SYSTEM begin backup;
alter tablespace SYSAUX begin backup;
alter tablespace UNDOTBS1 begin backup;
alter tablespace USERS begin backup;
alter tablespace TS01 begin backup;
alter tablespace TS02 begin backup;

exit;
EOF

# 2. 데이터파일 복사 (쉘에서 실행)
cp /u01/app/oracle/oradata/ORACLE19/users01.dbf      $BACKUP_DIR/
cp /u01/app/oracle/oradata/ORACLE19/ts01.dbf         $BACKUP_DIR/
cp /u01/app/oracle/oradata/ORACLE19/undotbs01.dbf    $BACKUP_DIR/
cp /u01/app/oracle/oradata/ORACLE19/sysaux01.dbf     $BACKUP_DIR/
cp /u01/app/oracle/oradata/ORACLE19/ts02.dbf         $BACKUP_DIR/
cp /u01/app/oracle/oradata/ORACLE19/system01.dbf     $BACKUP_DIR/
cp /u01/app/oracle/oradata/ORACLE19/user91.dbf       $BACKUP_DIR/

# 3. 테이블스페이스 END BACKUP
sqlplus -s / as sysdba <<EOF
set echo on
alter tablespace SYSTEM end backup;
alter tablespace SYSAUX end backup;
alter tablespace UNDOTBS1 end backup;
alter tablespace USERS end backup;
alter tablespace TS01 end backup;
alter tablespace TS02 end backup;

-- 필요 시 확인
select * from v\$backup;
exit;
EOF


