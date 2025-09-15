#!/bin/bash
# Oracle 19c 환경 점검 스크립트

WORKDIR=/home/oracle/check_report
mkdir -p $WORKDIR
FINAL_REPORT=$WORKDIR/final_checklist.txt
HTML_REPORT=$WORKDIR/oracle19c_check_report.html

echo "===== [1] OS 환경 점검 =====" >> $FINAL_REPORT
echo "ORACLE_HOME=$ORACLE_HOME" >> $FINAL_REPORT
echo "ORACLE_SID=$ORACLE_SID" >> $FINAL_REPORT
echo "PATH=$PATH" >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "커널 파라미터 확인:" >> $FINAL_REPORT
sysctl -n kernel.shmmax >> $FINAL_REPORT
sysctl -n kernel.shmall >> $FINAL_REPORT
sysctl -n fs.file-max >> $FINAL_REPORT
ulimit -a >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "===== [2] Listener 점검 =====" >> $FINAL_REPORT
lsnrctl status >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

echo "===== [3] Oracle 프로세스 점검 =====" >> $FINAL_REPORT
ps -ef | grep ora_ | grep -v grep >> $FINAL_REPORT
echo "" >> $FINAL_REPORT

# HTML 보고서 생성
cat <<EOF > $HTML_REPORT
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>Oracle 19c 점검 보고서</title>
  <style>
    body { font-family: monospace, sans-serif; background: #f9f9f9; color: #333; padding: 20px; }
    h1 { color: #0057a3; }
    h2 { color: #0077cc; border-bottom: 1px solid #ccc; padding-bottom: 5px; }
    pre { background: #fff; padding: 10px; border: 1px solid #ddd; border-radius: 4px; overflow-x: auto; }
  </style>
</head>
<body>
  <h1>✅ Oracle 19c 설치 후 점검/설정 보고서</h1>
EOF

while IFS= read -r line; do
  if [[ "$line" =~ ^===== ]]; then
    echo "<h2>${line}</h2>" >> $HTML_REPORT
    echo "<pre>" >> $HTML_REPORT
  elif [[ -z "$line" ]]; then
    echo "</pre>" >> $HTML_REPORT
  else
    echo "$line" >> $HTML_REPORT
  fi
done < $FINAL_REPORT

# 마지막 pre 태그 닫기
echo "</pre>" >> $HTML_REPORT
echo "</body></html>" >> $HTML_REPORT

echo "✅ HTML 보고서 생성 완료: $HTML_REPORT"

