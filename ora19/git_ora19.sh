#!/bin/bash

rm -rf /home/oracle/DBA/ora19/*
echo "파일 초기화 완료"

rsync -av --include="*.sql" --include="*.sh" --exclude="c.sql" --exclude="java.sql" --exclude="script.sql" --exclude="*" /home/oracle/ /home/oracle/DBA/ora19

cd ./DBA/

git add -A
if ! git diff --cached --quiet; then
  git commit -m "ora19 : auto commit at $(date +'%Y-%m-%d %H:%M:%S')"
  git push origin main
else
  echo "No changes to commit."
fi

cd
