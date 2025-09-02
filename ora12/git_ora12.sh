#!/bin/bash

rm -rf /home/oracle/DBA/ora12/*
echo "파일 초기화 완료"

rsync -av --include="*.sql" --include="*.sh" --exclude="c.sql" --exclude="java.sql" --exclude="*" /home/oracle/ /home/oracle/DBA/ora12

cd ./DBA/

git add -A
if ! git diff --cached --quiet; then
  git commit -m "ora12c : auto commit at $(date +'%Y-%m-%d %H:%M:%S')"
  git push origin main
else
  echo "No changes to commit."
fi

cd
