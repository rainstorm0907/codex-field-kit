# codex-field-kit

Rubato에서 쓰는 스킬을 Codex에 그대로 붙이는 묶음이야. 하위 에이전트 팀(agent-taskforce)도 Codex 기본 기능으로 돌아가게 변환돼 있어.

## 설치

```bash
git clone https://github.com/rainstorm0907/codex-field-kit.git
cd codex-field-kit && ./install.sh
```

| 넣는 것 | 어디로 |
|---|---|
| `skills/*` | `$CODEX_HOME/skills` (기본 `~/.codex/skills`) |
| `agents/taskforce_*.toml` | `$CODEX_HOME/agents` (새 세션에서 실제 역할 노출 확인) |
| `AGENTS.md` | `$CODEX_HOME/AGENTS.md` 끝에 덧붙임 (`--skills`면 생략) |

설치 뒤에 새 `codex` 세션을 열고 실제 `spawn_agent`의 역할을 확인해. 역할이 없으면 `skills/agent-taskforce/runtimes/codex.md`의 계약 경로 전달 방식을 따라.

## 스킬

| 스킬 | 언제 |
|---|---|
| dispatching · dispatched | 하위 에이전트에게 일을 넘길 때, 넘겨받은 일을 읽을 때 |
| agent-taskforce | 담당자·검증자로 팀을 꾸릴지 정하고 운영할 때 (Codex 연결: `runtimes/codex.md`) |
| model-guide | 위임할 모델·effort 고를 때 |
| work-intent | 뭘 만들고 어디까지 할지 정해야 할 때 |
| metaframe | 관찰이 지금 설명과 어긋날 때 방향 유지·전환 판단 |
| codex-discusser | 열린 논의, 선택 비교 |
| codex-reviewer | diff·계획 리뷰 |
| product-framing · product-reframing | 제품 가치·범위 정하기, 프레임 다시 보기 |
| frontend-ux-router · frontend-design | 화면·흐름 만들기와 다듬기 |
| update-docs · wrapping-sessions | 기록 갱신, 마무리·인수인계 |
| keep-simple · laws | 가장 작은 올바른 수정, 원인부터 고치기 |

## 팀 역할

| 역할 | 하는 일 |
|---|---|
| `taskforce_owner` | 한 결과를 조사부터 구현·확인까지 끝까지 맡음 |
| `taskforce_verifier` | 새 맥락에서 결과물과 완료 기준을 독립 확인 |
| `taskforce_klong` | 클롱이: 세션 곁에 붙어 계속 보는 검증자 |
| `taskforce_helper` | 좁은 조사·확인·정해진 작은 일 |

역할 파일은 `skills/agent-taskforce`의 계약과 `skills/dispatched`로 만들어. 스킬을 고친 뒤 `node scripts/build-roles.mjs`로 다시 만들고, `--check`로 최신인지 확인해.
