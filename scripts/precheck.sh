#!/usr/bin/env bash
# 작업 환경 점검과 이 묶음 설치를 한 번에 한다. 키·토큰 값은 출력하지 않는다.
# 새 터미널(작업 폴더)에서:
#   git clone https://github.com/rainstorm0907/codex-field-kit.git /tmp/codex-field-kit && bash /tmp/codex-field-kit/scripts/precheck.sh --preview
# --preview  : 0.0.0.0:3000 에 확인용 페이지를 띄운다 (연결 확인용)
# --no-install: 점검만 하고 설치는 안 한다
set -u
KIT="$(cd "$(dirname "$0")/.." && pwd)"
WS="$PWD"
CH="${CODEX_HOME:-$HOME/.codex}"
PREVIEW=0; INSTALL=1
for a in "$@"; do case "$a" in --preview) PREVIEW=1;; --no-install) INSTALL=0;; esac; done
sec(){ printf '\n== %s\n' "$1"; }
inside(){ case "$1/" in "$WS"/*) echo "작업 폴더 안 ⚠ 결과물에 섞일 수 있음";; *) echo "작업 폴더 밖";; esac; }

sec "기본"
echo "사용자 $(whoami)  |  작업 폴더 $WS  |  HOME $HOME  |  $(uname -sm)"
echo "CPU $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null)개"
free -h 2>/dev/null | sed -n 1,2p
df -h "$WS" 2>/dev/null | tail -1 | awk '{print "디스크 남음 " $4 " / " $2}'

sec "도구"
for c in node npm python3 pip3 git curl codex; do
  if command -v "$c" >/dev/null 2>&1; then printf '%-8s %s\n' "$c" "$("$c" --version 2>&1 | head -1)"; else printf '%-8s 없음\n' "$c"; fi
done

sec "네트워크 (HTTP 코드, 000 = 막힘)"
for u in https://github.com https://registry.npmjs.org https://pypi.org/simple/; do
  printf '%-30s %s\n' "$u" "$(curl -s -o /dev/null -m 6 -w '%{http_code}' "$u" 2>/dev/null || echo 000)"
done

sec "결과물 안 AI용 환경변수 (이름만)"
env | cut -d= -f1 | grep -iE 'openai|llm|model|api_|base_url' | sort | sed 's/^/  /' || true
[ -n "${OPENAI_BASE_URL:-}" ] && echo "  OPENAI_BASE_URL 호스트: $(echo "$OPENAI_BASE_URL" | sed -E 's#^[a-z]+://([^/]+).*#\1#')"
[ -n "${OPENAI_MODEL:-}" ] && echo "  OPENAI_MODEL: $OPENAI_MODEL"

sec "코덱스 설정 ($CH, $(inside "$CH"))"
if [ -d "$CH" ]; then
  ls -1 "$CH" | sed 's/^/  /'
  if [ -f "$CH/config.toml" ]; then echo "  -- config.toml 중 모델·권한 줄만 (나머지는 출력 안 함)"; grep -E '^[[:space:]]*(\[|model|model_provider|model_reasoning_effort|approval_policy|sandbox_mode|profile)' "$CH/config.toml" | grep -viE 'key|token|secret|password|auth|header' | sed 's/^/  /'; fi
  [ -f "$CH/AGENTS.md" ] && echo "  기존 AGENTS.md $(wc -l < "$CH/AGENTS.md")줄"
  [ -d "$CH/skills" ] && echo "  기존 스킬: $(ls "$CH/skills" | tr '\n' ' ')"
else echo "  없음 (설치 때 만든다)"; fi
( mkdir -p "$CH" && touch "$CH/.w" && rm -f "$CH/.w" ) 2>/dev/null && echo "  쓰기 가능" || echo "  쓰기 불가 ⚠ 설치 못 함"

if [ "$INSTALL" = 1 ]; then
  sec "묶음 설치 (묶음 위치: $KIT, $(inside "$KIT"))"
  stamp=$(date +%H%M%S)
  [ -f "$CH/AGENTS.md" ] && cp "$CH/AGENTS.md" "$CH/AGENTS.md.before-kit-$stamp" && echo "  기존 AGENTS.md 백업: AGENTS.md.before-kit-$stamp"
  for s in "$KIT"/skills/*/; do n=$(basename "$s"); if [ -d "$CH/skills/$n" ]; then mkdir -p "$CH/skills-before-kit-$stamp"; cp -R "$CH/skills/$n" "$CH/skills-before-kit-$stamp/"; echo "  같은 이름 기존 스킬 백업: $n"; fi; done
  CODEX_HOME="$CH" bash "$KIT/install.sh" | tail -2 | sed 's/^/  /'
  echo "  스킬 $(ls "$CH/skills" | wc -l | tr -d ' ')개, 역할 $(ls "$CH/agents" 2>/dev/null | tr '\n' ' ')"
  grep -q "제한된 작업 환경" "$CH/AGENTS.md" && echo "  AGENTS.md 제한된 작업 환경 절 있음" || echo "  ⚠ AGENTS.md 제한된 작업 환경 절 없음"
  [ -f "$CH/skills/frontend-ux-router/references/portable-design-principles.md" ] && echo "  화면 원칙 파일 있음" || echo "  ⚠ 화면 원칙 파일 없음"
fi

if [ "$PREVIEW" = 1 ]; then
  sec "미리보기 확인용 서버"
  d=$(mktemp -d); printf '<!doctype html><meta charset="utf-8"><h1>미리보기 연결 확인</h1><p>이 글이 보이면 0.0.0.0 바인딩과 미리보기 연결이 된다.</p>' > "$d/index.html"
  if ! command -v python3 >/dev/null 2>&1; then
    echo "  ⚠ python3 없음: 미리보기 확인은 node 등 다른 서버로"
  elif python3 -c "import socket,sys; s=socket.socket(); sys.exit(s.connect_ex(('127.0.0.1',3000))!=0)"; then
    echo "  ⚠ 3000번을 이미 누가 쓰고 있어서 띄우지 않음"
  else
    nohup python3 -c "import os,functools,http.server as h; open('/tmp/precheck-preview.pid','w').write(str(os.getpid())); h.ThreadingHTTPServer(('0.0.0.0',3000),functools.partial(h.SimpleHTTPRequestHandler,directory='$d')).serve_forever()" >/dev/null 2>&1 &
    sleep 1; echo "  브라우저 미리보기에서 3000번 포트, 경로 / 를 열어 확인. 끄기: kill \$(cat /tmp/precheck-preview.pid)"
  fi
fi

sec "다음: 새 터미널에서 codex 실행 → /status → /model → 아래 질문"
cat <<'Q'
[질문 1] 스킬·지침이 세션에 올라갔는지
파일은 열지 말고, 지금 이 세션에 등록된 스킬 이름만 한 줄로 나열해 줘. 그다음 AGENTS.md의 '제한된 작업 환경' 절 첫 문장과 frontend-ux-router의 portable-design-principles.md에서 말투 규칙 한 줄을 각각 그대로 인용해 줘.

[질문 2] 하위 에이전트·모델·검색
gpt-6.1-sol로 taskforce_helper 하위 에이전트 하나를 띄워서, 웹 검색으로 Python http.server 공식 문서 주소 하나만 찾아오게 해 줘. 띄울 때 받은 에이전트 ID를 그대로 적고, 띄우기나 검색이 안 되면 받은 오류를 그대로 보여 줘.

[질문 3, 시간 남으면] 화면 스킬이 불리는지
할 일 목록 화면 하나를 만든다면 어떤 스킬과 문서부터 읽을지만 말해 줘. 아무것도 만들지 마.
Q
