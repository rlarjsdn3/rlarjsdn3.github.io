#!/usr/bin/env bash
set -euo pipefail

# 원격 이름(기본: origin)과 타겟 브랜치(기본: 현재 브랜치)
REMOTE="${1:-origin}"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# 리포지토리 루트로 이동
cd "$(git rev-parse --show-toplevel)"

# Git 사용자 설정이 없으면 기본값 설정
git config user.name >/dev/null 2>&1 || git config user.name "Auto Deploy"
git config user.email >/dev/null 2>&1 || git config user.email "auto-deploy@example.com"

# 한국 시간 기준 날짜로 커밋 메시지 구성
export TZ=Asia/Seoul
TODAY="$(date +"%Y-%m-%d %H:%M")"
MSG="deployed at ${TODAY}"

# 변경 사항 스테이징 & 커밋(변경이 없으면 스킵)
git add -A
if git diff --cached --quiet; then
  echo "No changes to commit."
else
  git commit -m "$MSG"
fi

# 최신 반영 후 푸시
git fetch --all --prune
git pull --rebase "$REMOTE" "$BRANCH" || true
git push "$REMOTE" "$BRANCH"
