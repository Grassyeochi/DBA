STARTUP NOMOUNT
CREATE CONTROLFILE REUSE DATABASE "ORACLE19" NORESETLOGS  ARCHIVELOG
    MAXLOGFILES 16
    MAXLOGMEMBERS 3
    MAXDATAFILES 2000
    MAXINSTANCES 8
    MAXLOGHISTORY 292
LOGFILE
  GROUP 1 (
    '/u01/app/oracle/oradata/ORACLE19/redo01.log',
    '/u01/app/oracle/fast_recovery_area/ORACLE19/onlinelog/redo01b.log'
  ) SIZE 200M BLOCKSIZE 512,
  GROUP 2 (
    '/u01/app/oracle/oradata/ORACLE19/redo02.log',
    '/u01/app/oracle/fast_recovery_area/ORACLE19/onlinelog/redo02b.log'
  ) SIZE 200M BLOCKSIZE 512,
  GROUP 3 (
    '/u01/app/oracle/oradata/ORACLE19/redo03.log',
    '/u01/app/oracle/fast_recovery_area/ORACLE19/onlinelog/redo03b.log'
  ) SIZE 200M BLOCKSIZE 512
-- STANDBY LOGFILE
DATAFILE
  '/u01/app/oracle/oradata/ORACLE19/system01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts02.dbf',
  '/u01/app/oracle/oradata/ORACLE19/sysaux01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/undotbs01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/users01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/user91.dbf'
CHARACTER SET AL32UTF8
;

-- Configure RMAN configuration record 1
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('CONTROLFILE AUTOBACKUP','ON');
-- Commands to re-create incarnation table
-- Below log names MUST be changed to existing filenames on
-- disk. Any one log file from each branch can be used to
-- re-create incarnation records.
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1212661880.dbf';
-- Recovery is required if any of the datafiles are restored backups,
-- or if the last shutdown was not normal or immediate.
RECOVER DATABASE

-- All logs need archiving and a log switch is needed.
ALTER SYSTEM ARCHIVE LOG ALL;

-- Database can now be opened normally.
ALTER DATABASE OPEN;

