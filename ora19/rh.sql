#!/bin/bash
################################################################################
# hotbackup.sh - Oracle Hot Backup Script (Universal Version)
# 모든 Oracle 환경에서 사용 가능하도록 동적으로 tablespace/datafile 탐지
################################################################################

set -e

# ORACLE 환경변수 설정
export ORACLE_HOME=/u01/app/oracle/product/19.3.0/dbhome_1
export ORACLE_SID=oracle19
export PATH=$ORACLE_HOME/bin:$PATH

# 백업 설정
BACKUP_BASE=/home/oracle/hotbackup
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=${BACKUP_BASE}/${BACKUP_DATE}
LOG_FILE=${BACKUP_DIR}/backup.log
TEMP_SQL=/tmp/backup_${ORACLE_SID}_$$.sql

# 로그 함수
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "${message}"
    # 로그 파일이 있으면 기록
    if [[ -f "${LOG_FILE}" ]]; then
        echo "${message}" >> "${LOG_FILE}"
    fi
}

die() {
    log "ERROR: $*"
    emergency_cleanup
    exit 1
}

# 비상 정리 함수
emergency_cleanup() {
    log "비상 정리: 모든 tablespace END BACKUP 시도..."
    sqlplus -s / as sysdba <<EOF >/dev/null 2>&1
BEGIN
    FOR ts IN (SELECT tablespace_name FROM dba_tablespaces 
               WHERE contents NOT IN ('TEMPORARY') AND status = 'ONLINE') LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLESPACE ' || ts.tablespace_name || ' END BACKUP';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/
EXIT;
EOF
    rm -f ${TEMP_SQL}
}

trap emergency_cleanup EXIT SIGINT SIGTERM

# 메인 시작
echo "============================================"
echo "Oracle Hot Backup 시작 (Universal Version)"
echo "============================================"
echo "ORACLE_SID: ${ORACLE_SID}"
echo "ORACLE_HOME: ${ORACLE_HOME}"
echo "백업 디렉토리: ${BACKUP_DIR}"

# 백업 디렉토리 생성
echo "백업 디렉토리 생성 중..."
mkdir -p ${BACKUP_DIR}/{datafiles,controlfiles,archivelogs,scripts}

# 이제부터 로그 파일에 기록 시작
log "============================================"
log "Oracle Hot Backup 시작 (Universal Version)"
log "============================================"
log "ORACLE_SID: ${ORACLE_SID}"
log "ORACLE_HOME: ${ORACLE_HOME}"
log "백업 디렉토리: ${BACKUP_DIR}"

# 데이터베이스 상태 확인
log "데이터베이스 상태 확인..."
DB_STATUS=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF PAGESIZE 0 FEEDBACK OFF TIMING OFF
SELECT status FROM v\$instance;
EXIT;
EOF
)

if [[ ! "${DB_STATUS}" =~ OPEN ]]; then
    die "데이터베이스가 OPEN 상태가 아닙니다: ${DB_STATUS}"
fi

LOG_MODE=$(sqlplus -s / as sysdba <<EOF
SET HEADING OFF PAGESIZE 0 FEEDBACK OFF TIMING OFF
SELECT log_mode FROM v\$database;
EXIT;
EOF
)

if [[ ! "${LOG_MODE}" =~ ARCHIVELOG ]]; then
    die "데이터베이스가 ARCHIVELOG 모드가 아닙니다: ${LOG_MODE}"
fi

log "DB 상태: $(echo ${DB_STATUS} | xargs), 모드: $(echo ${LOG_MODE} | xargs)"

# 1. BEGIN BACKUP 스크립트 동적 생성
log "백업 대상 tablespace 조회 중..."
sqlplus -s / as sysdba <<EOF > ${BACKUP_DIR}/scripts/begin_backup.sql
SET HEADING OFF PAGESIZE 0 FEEDBACK OFF LINESIZE 200 TRIMSPOOL ON TIMING OFF
SELECT 'ALTER TABLESPACE ' || tablespace_name || ' BEGIN BACKUP;'
FROM dba_tablespaces
WHERE contents NOT IN ('TEMPORARY')
  AND status = 'ONLINE'
ORDER BY tablespace_name;
EXIT;
EOF

# 불필요한 공백/개행 제거
sed -i '/^$/d' ${BACKUP_DIR}/scripts/begin_backup.sql 2>/dev/null || true
sed -i 's/^[[:space:]]*//' ${BACKUP_DIR}/scripts/begin_backup.sql 2>/dev/null || true
sed -i 's/[[:space:]]*$//' ${BACKUP_DIR}/scripts/begin_backup.sql 2>/dev/null || true

# BEGIN BACKUP할 tablespace 목록 출력
log "백업 대상 tablespace:"
grep "ALTER TABLESPACE" ${BACKUP_DIR}/scripts/begin_backup.sql | while read line; do
    if [[ -n "$line" ]]; then
        ts_name=$(echo "$line" | awk '{print $3}')
        log "  - ${ts_name}"
    fi
done

# 2. END BACKUP 스크립트 동적 생성
sqlplus -s / as sysdba <<EOF > ${BACKUP_DIR}/scripts/end_backup.sql
SET HEADING OFF PAGESIZE 0 FEEDBACK OFF LINESIZE 200 TIMING OFF
SELECT 'ALTER TABLESPACE ' || tablespace_name || ' END BACKUP;'
FROM dba_tablespaces
WHERE contents NOT IN ('TEMPORARY')
  AND status = 'ONLINE'
ORDER BY tablespace_name;
EXIT;
EOF

# 3. 데이터파일 목록 동적 생성
log "백업 대상 datafile 조회 중..."
sqlplus -s / as sysdba <<EOF > ${BACKUP_DIR}/scripts/datafiles.lst
SET HEADING OFF PAGESIZE 0 FEEDBACK OFF LINESIZE 500 TIMING OFF
SELECT file_name
FROM dba_data_files
WHERE tablespace_name IN (
    SELECT tablespace_name FROM dba_tablespaces
    WHERE contents NOT IN ('TEMPORARY')
      AND status = 'ONLINE'
)
ORDER BY tablespace_name, file_id;
EXIT;
EOF

# 빈 줄과 "경 과:" 같은 불필요한 줄 제거
sed -i '/^$/d' ${BACKUP_DIR}/scripts/datafiles.lst 2>/dev/null || true
sed -i '/^경/d' ${BACKUP_DIR}/scripts/datafiles.lst 2>/dev/null || true

DATAFILE_COUNT=$(wc -l < ${BACKUP_DIR}/scripts/datafiles.lst)
log "백업 대상 datafile: ${DATAFILE_COUNT}개"

# 4. BEGIN BACKUP 실행
log "BEGIN BACKUP 시작..."
sqlplus -s / as sysdba >> ${LOG_FILE} 2>&1 <<EOF
SET ECHO ON SERVEROUTPUT ON TIMING OFF

@${BACKUP_DIR}/scripts/begin_backup.sql

-- BEGIN BACKUP 상태 확인
SELECT 'BEGIN BACKUP 상태 확인:' AS message FROM DUAL;
SELECT b.file#, d.tablespace_name, b.status, b.change#
FROM v\$backup b, v\$datafile d
WHERE b.file# = d.file#
ORDER BY b.file#;

EXIT;
EOF

EXIT_CODE=$?
if [ ${EXIT_CODE} -ne 0 ]; then
    log "ERROR: BEGIN BACKUP 실패 (Exit Code: ${EXIT_CODE})"
    log "로그 파일 확인: ${LOG_FILE}"
    cat ${LOG_FILE}
    die "BEGIN BACKUP 실패"
fi

log "BEGIN BACKUP 완료"

# 5. 데이터파일 복사
log "데이터파일 복사 시작..."

COPY_SUCCESS=0
COPY_FAIL=0

while IFS= read -r datafile; do
    # 공백 제거
    datafile=$(echo "$datafile" | xargs)
    
    if [[ -z "$datafile" ]]; then
        continue
    fi
    
    filename=$(basename "$datafile")
    
    if [[ -f "$datafile" ]]; then
        log "  복사 중: ${filename}"
        if cp -p "$datafile" "${BACKUP_DIR}/datafiles/${filename}"; then
            COPY_SUCCESS=$((COPY_SUCCESS + 1))
        else
            log "  경고: 복사 실패 - ${filename}"
            COPY_FAIL=$((COPY_FAIL + 1))
        fi
    else
        log "  경고: 파일 없음 - ${datafile}"
        COPY_FAIL=$((COPY_FAIL + 1))
    fi
    
done < ${BACKUP_DIR}/scripts/datafiles.lst

log "데이터파일 복사 완료 (성공: ${COPY_SUCCESS}, 실패: ${COPY_FAIL})"

# 6. END BACKUP 실행
log "END BACKUP 시작..."
sqlplus -s / as sysdba >> ${LOG_FILE} 2>&1 <<EOF
SET ECHO ON

@${BACKUP_DIR}/scripts/end_backup.sql

-- 로그 스위치
ALTER SYSTEM ARCHIVE LOG CURRENT;
ALTER SYSTEM CHECKPOINT;

-- END BACKUP 상태 확인
SELECT 'END BACKUP 상태 확인:' AS message FROM DUAL;
SELECT tablespace_name, file#, status 
FROM v\$backup
ORDER BY file#;

EXIT;
EOF

if [ $? -ne 0 ]; then
    die "END BACKUP 실패"
fi

log "END BACKUP 완료"

# 7. 컨트롤파일 백업
log "컨트롤파일 백업 중..."
sqlplus -s / as sysdba >> ${LOG_FILE} 2>&1 <<EOF
ALTER DATABASE BACKUP CONTROLFILE TO '${BACKUP_DIR}/controlfiles/control.ctl';
ALTER DATABASE BACKUP CONTROLFILE TO TRACE AS '${BACKUP_DIR}/controlfiles/control.sql';
EXIT;
EOF

log "컨트롤파일 백업 완료"

# 8. 아카이브 로그 복사
log "아카이브 로그 백업 중..."
ARCHIVE_DEST=$(sqlplus -s / as sysdba <<EOF | grep -v '^$'
SET HEADING OFF PAGESIZE 0 FEEDBACK OFF
SELECT value FROM v\$parameter WHERE name='log_archive_dest_1';
EXIT;
EOF
)

ARCHIVE_DIR=$(echo "${ARCHIVE_DEST}" | sed 's/.*LOCATION=//' | awk '{print $1}')

if [[ -d "${ARCHIVE_DIR}" ]]; then
    log "아카이브 로그 디렉토리: ${ARCHIVE_DIR}"
    ARCHIVE_COUNT=$(find "${ARCHIVE_DIR}" -name "*.arc" -mtime -1 -type f 2>/dev/null | wc -l)
    if [[ ${ARCHIVE_COUNT} -gt 0 ]]; then
        find "${ARCHIVE_DIR}" -name "*.arc" -mtime -1 -type f -exec cp {} "${BACKUP_DIR}/archivelogs/" \;
        log "아카이브 로그 ${ARCHIVE_COUNT}개 복사 완료"
    else
        log "복사할 아카이브 로그 없음 (최근 1일 이내)"
    fi
else
    log "경고: 아카이브 로그 디렉토리를 찾을 수 없음"
fi

# 9. 파라미터 파일 백업
log "파라미터 파일 백업 중..."
sqlplus -s / as sysdba >> ${LOG_FILE} 2>&1 <<EOF
CREATE PFILE='${BACKUP_DIR}/init${ORACLE_SID}.ora' FROM SPFILE;
EXIT;
EOF

# SPFILE도 직접 복사
if [[ -f ${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora ]]; then
    cp -p ${ORACLE_HOME}/dbs/spfile${ORACLE_SID}.ora ${BACKUP_DIR}/
    log "SPFILE 복사 완료"
fi

# 10. 백업 정보 파일 생성
log "백업 정보 파일 생성 중..."

# 백업된 tablespace 목록 생성 (깔끔하게)
TABLESPACE_LIST=$(grep "ALTER TABLESPACE" ${BACKUP_DIR}/scripts/begin_backup.sql | awk '{print $3}' | tr '\n' ' ')

# DB 상태 정리 (불필요한 줄 제거)
DB_STATUS_CLEAN=$(echo "${DB_STATUS}" | xargs)
LOG_MODE_CLEAN=$(echo "${LOG_MODE}" | xargs)

cat > ${BACKUP_DIR}/README.txt <<EOFINFO
================================================================================
Oracle Hot Backup 정보
================================================================================
백업 일시    : ${BACKUP_DATE}
데이터베이스 : ${ORACLE_SID}
백업 위치    : ${BACKUP_DIR}
DB 상태      : ${DB_STATUS_CLEAN}
로그 모드    : ${LOG_MODE_CLEAN}

백업된 Tablespace (${DATAFILE_COUNT}개 datafile):
${TABLESPACE_LIST}

백업 내용:
  - Datafiles     : ${BACKUP_DIR}/datafiles/ (성공: ${COPY_SUCCESS}, 실패: ${COPY_FAIL})
  - Control Files : ${BACKUP_DIR}/controlfiles/
  - Archive Logs  : ${BACKUP_DIR}/archivelogs/
  - PFILE         : ${BACKUP_DIR}/init${ORACLE_SID}.ora
  - Scripts       : ${BACKUP_DIR}/scripts/

생성된 스크립트:
  - begin_backup.sql  : BEGIN BACKUP 명령어
  - end_backup.sql    : END BACKUP 명령어
  - datafiles.lst     : 백업된 데이터파일 목록

복구 절차:
  1. 데이터베이스 종료
     sqlplus / as sysdba
     SHUTDOWN IMMEDIATE;
  
  2. 데이터파일을 원래 위치로 복사
     (원본 경로는 scripts/datafiles.lst 참조)
  
  3. 데이터베이스 MOUNT
     STARTUP MOUNT;
  
  4. 복구 수행
     RECOVER DATABASE USING BACKUP CONTROLFILE;
     (아카이브 로그 적용)
  
  5. 데이터베이스 OPEN
     ALTER DATABASE OPEN RESETLOGS;

로그 파일: ${LOG_FILE}
================================================================================
EOFINFO

# 11. 복구 스크립트 생성
cat > ${BACKUP_DIR}/scripts/restore.sh <<'EOFRESTORE'
#!/bin/bash
# 복구 스크립트 (수동 검토 후 사용)

echo "====================================="
echo "Oracle Database 복구 스크립트"
echo "====================================="
echo ""
echo "경고: 이 스크립트는 데이터베이스를 복구합니다."
echo "실행 전에 반드시 현재 상태를 확인하세요!"
echo ""
read -p "계속하시겠습니까? (yes/no): " confirm‎

if [[ "$confirm‎" != "yes" ]]; then
    echo "취소되었습니다."
    exit 0
fi

# 1. 데이터베이스 종료
echo "1. 데이터베이스 종료 중..."
sqlplus / as sysdba <<EOF
SHUTDOWN IMMEDIATE;
EXIT;
EOF

# 2. 데이터파일 복사는 수동으로 수행
echo ""
echo "2. 데이터파일을 복사하세요:"
echo "   복사 대상: $(dirname $0)/../datafiles/*"
echo "   복사 위치: scripts/datafiles.lst 참조"
echo ""
read -p "데이터파일 복사를 완료했습니까? (yes/no): " copied

if [[ "$copied" != "yes" ]]; then
    echo "복사를 완료한 후 다시 실행하세요."
    exit 1
fi

# 3. 데이터베이스 복구
echo "3. 데이터베이스 복구 시작..."
sqlplus / as sysdba <<EOF
STARTUP MOUNT;
RECOVER DATABASE;
ALTER DATABASE OPEN;
EXIT;
EOF

echo ""
echo "복구가 완료되었습니다!"
EOFRESTORE

chmod +x ${BACKUP_DIR}/scripts/restore.sh

# 백업 크기 계산
BACKUP_SIZE=$(du -sh ${BACKUP_DIR} | awk '{print $1}')

# Trap 해제
trap - EXIT SIGINT SIGTERM

# 완료
log "============================================"
log "백업 완료!"
log "============================================"
log "백업 위치: ${BACKUP_DIR}"
log "백업 크기: ${BACKUP_SIZE}"
log "로그 파일: ${LOG_FILE}"
log ""
log "백업 요약:"
log "  - Tablespace: $(echo ${TABLESPACE_LIST} | wc -w)개"
log "  - Datafile: ${COPY_SUCCESS}/${DATAFILE_COUNT}개 성공"
log "  - 실패: ${COPY_FAIL}개"
log "============================================"

# 백업 성공 여부 판단
if [[ ${COPY_FAIL} -eq 0 ]]; then
    log "상태: 성공 ✓"
    exit 0
else
    log "상태: 경고 (일부 파일 복사 실패)"
    exit 1
fi

