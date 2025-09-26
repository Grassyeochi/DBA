#!/bin/bash


export ORACLE_SID=oracle19
BACKUP_START_DIR=/u01/app/oracle/oradata/ORACLE19/*
BACKUP_END_DIR=/home/oracle/coldbackup

sqlplus -s sys/oracle_4U as sysdba << EOF

shutdown immediate
exit;
EOF

cp $BACKUP_START_DIR $BACKUP_END_DIR/

sqlplus -s / as sysdba << EOF
startup;
exit;
EOF

echo "Cold backup completed successfully to $BACKUP_END_DIR"

