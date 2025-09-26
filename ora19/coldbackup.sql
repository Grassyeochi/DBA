#!/bin/bash


export ORACLE_SID=oracle19
BACKUP_DIR=/home/oracle/coldbackup
sqlplus -s sys/oracle_4U as sysdba << EOF

shutdown immediate
exit;
EOF

cp /u01/app/oracle/oradata/ORACLE19/* $BACKUP_DIR/

sqlplus -s / as sysdba << EOF
startup;
exit;
EOF

echo "Cold backup completed successfully to $BACKUP_DIR"

