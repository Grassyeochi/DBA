-- The following are current System-scope REDO Log Archival related
-- parameters and can be included in the database initialization file.
--
-- LOG_ARCHIVE_DEST=''
-- LOG_ARCHIVE_DUPLEX_DEST=''
--
-- LOG_ARCHIVE_FORMAT=%t_%s_%r.dbf
--
-- DB_UNIQUE_NAME="oracle19"
--
-- LOG_ARCHIVE_CONFIG='SEND, RECEIVE, NODG_CONFIG'
-- LOG_ARCHIVE_MAX_PROCESSES=4
-- STANDBY_FILE_MANAGEMENT=MANUAL
-- FAL_CLIENT=''
-- FAL_SERVER=''
--
-- LOG_ARCHIVE_DEST_1='LOCATION=/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog'
-- LOG_ARCHIVE_DEST_1='OPTIONAL REOPEN=300 NODELAY'
-- LOG_ARCHIVE_DEST_1='ARCH NOAFFIRM NOVERIFY SYNC'
-- LOG_ARCHIVE_DEST_1='REGISTER'
-- LOG_ARCHIVE_DEST_1='NOALTERNATE'
-- LOG_ARCHIVE_DEST_1='NODEPENDENCY'
-- LOG_ARCHIVE_DEST_1='NOMAX_FAILURE NOQUOTA_SIZE NOQUOTA_USED NODB_UNIQUE_NAME'
-- LOG_ARCHIVE_DEST_1='VALID_FOR=(PRIMARY_ROLE,ONLINE_LOGFILES)'
-- LOG_ARCHIVE_DEST_STATE_1=ENABLE

--
-- Below are two sets of SQL statements, each of which creates a new
-- control file and uses it to open the database. The first set opens
-- the database with the NORESETLOGS option and should be used only if
-- the current versions of all online logs are available. The second
-- set opens the database with the RESETLOGS option and should be used
-- if online logs are unavailable.
-- The appropriate set of statements can be copied from the trace into
-- a script file, edited as necessary, and executed when there is a
-- need to re-create the control file.
--
--     Set #1. NORESETLOGS case
--
-- The following commands will create a new control file and use it
-- to open the database.
-- Data used by Recovery Manager will be lost.
-- Additional logs may be required for media recovery of offline
-- Use this only if the current versions of all online logs are
-- available.

-- After mounting the created controlfile, the following SQL
-- statement will place the database in the appropriate
-- protection mode:
--  ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE PERFORMANCE

STARTUP NOMOUNT
CREATE CONTROLFILE REUSE DATABASE "ORACLE19" NORESETLOGS  ARCHIVELOG
    MAXLOGFILES 20
    MAXLOGMEMBERS 4
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
  ) SIZE 200M BLOCKSIZE 512,
  GROUP 4 (
    '/u01/app/oracle/oradata/ORACLE19/redo04.log',
    '/u01/app/oracle/fast_recovery_area/ORACLE19/onlinelog/redo04b.log'
  ) SIZE 200M BLOCKSIZE 512
-- STANDBY LOGFILE
DATAFILE
  '/u01/app/oracle/oradata/ORACLE19/system01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts02.dbf',
  '/u01/app/oracle/oradata/ORACLE19/sysaux01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/undotbs01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/users01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/user91.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts834.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts834b.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts899.dbf'
CHARACTER SET AL32UTF8
;

-- Configure RMAN configuration record 1
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('CONTROLFILE AUTOBACKUP','ON');
-- Commands to re-create incarnation table
-- Below log names MUST be changed to existing filenames on
-- disk. Any one log file from each branch can be used to
-- re-create incarnation records.
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1212683461.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1212836268.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1212839713.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1212840576.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1212848613.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1213097801.dbf';
-- Recovery is required if any of the datafiles are restored backups,
-- or if the last shutdown was not normal or immediate.
RECOVER DATABASE

-- All logs need archiving and a log switch is needed.
ALTER SYSTEM ARCHIVE LOG ALL;

-- Database can now be opened normally.
ALTER DATABASE OPEN;

-- No tempfile entries found to add.
--
--     Set #2. RESETLOGS case
--
-- The following commands will create a new control file and use it
-- to open the database.
-- Data used by Recovery Manager will be lost.
-- The contents of online logs will be lost and all backups will
-- be invalidated. Use this only if online logs are damaged.

-- After mounting the created controlfile, the following SQL
-- statement will place the database in the appropriate
-- protection mode:
--  ALTER DATABASE SET STANDBY DATABASE TO MAXIMIZE PERFORMANCE

STARTUP NOMOUNT
CREATE CONTROLFILE REUSE DATABASE "ORACLE19" RESETLOGS  ARCHIVELOG
    MAXLOGFILES 20
    MAXLOGMEMBERS 4
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
  ) SIZE 200M BLOCKSIZE 512,
  GROUP 4 (
    '/u01/app/oracle/oradata/ORACLE19/redo04.log',
    '/u01/app/oracle/fast_recovery_area/ORACLE19/onlinelog/redo04b.log'
  ) SIZE 200M BLOCKSIZE 512
-- STANDBY LOGFILE
DATAFILE
  '/u01/app/oracle/oradata/ORACLE19/system01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts02.dbf',
  '/u01/app/oracle/oradata/ORACLE19/sysaux01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/undotbs01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/users01.dbf',
  '/u01/app/oracle/oradata/ORACLE19/user91.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts834.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts834b.dbf',
  '/u01/app/oracle/oradata/ORACLE19/ts899.dbf'
CHARACTER SET AL32UTF8
;

-- Configure RMAN configuration record 1
VARIABLE RECNO NUMBER;
EXECUTE :RECNO := SYS.DBMS_BACKUP_RESTORE.SETCONFIG('CONTROLFILE AUTOBACKUP','ON');
-- Commands to re-create incarnation table
-- Below log names MUST be changed to existing filenames on
-- disk. Any one log file from each branch can be used to
-- re-create incarnation records.
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1212683461.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1212836268.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1212839713.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1212840576.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1212848613.dbf';
-- ALTER DATABASE REGISTER LOGFILE '/u01/app/oracle/fast_recovery_area/ORACLE19/archivelog/1_1_1213097801.dbf';
-- Recovery is required if any of the datafiles are restored backups,
-- or if the last shutdown was not normal or immediate.
RECOVER DATABASE USING BACKUP CONTROLFILE

-- Database can now be opened zeroing the online logs.
ALTER DATABASE OPEN RESETLOGS;

-- No tempfile entries found to add.
--
