# Runtime — Codex

*Lead and teammates.* What the harness supplies. This skill still owns scope, responsibility, approved staffing, evidence, and completion.

| Concern | Where it lives |
|---|---|
| Lead | the root Codex session the user is talking to |
| Approved teammate | a native child spawned with `agent_type: "taskforce_owner"` or `"taskforce_verifier"` |
| Focused support | `agent_type: "taskforce_helper"`: a map, check or settled subtask; no roster entry |
| Spawn | `spawn_agent` |
| Follow-up or correction, including an idle owner | `followup_task` |
| A fact for an active peer, not a new assignment | `send_message` |
| Roster and runtime status | `list_agents` |
| Await updates or completion | `wait_agent` |
| Stop one going the wrong way | `interrupt_agent` |
| Shared task list | none. The mission and each task brief carry what a teammate owns |
| Owner-local delegation | the same `spawn_agent`, under that owner, with `taskforce_helper` |
| Parallel spawn | several `spawn_agent` calls start at once; wait with `wait_agent`, never a sleep loop |

The schema exposed in this run overrides these names. Collaboration tools are
direct calls, not nested `functions.exec` tools. Never invent a tool argument.
A mailbox update or idle status is not an accepted result.

## Keep the returned agent identity

For an agent that will receive follow-ups, record the actual ID returned by
spawn with its role, owned outcome and work-document path in one existing team
record. Copy that entire opaque ID for later calls; never reconstruct it from
memory or combine pieces of two IDs. After context compaction or an ID error,
check the saved return value and `list_agents` before concluding that the agent
cannot be reached. Reuse the confirmed agent when the assignment continues.
A one-shot helper needs no new roster or tracking document just for this rule.

## Roles

The installed role files (`$CODEX_HOME/agents/taskforce_*.toml`) carry the
matching contract from `teammate/` plus Skill(dispatched) as developer
instructions. Send the task-specific brief, not a second copy of the contract.
Inherited lead conversation is background, not the worker's authority.

Check the actual `spawn_agent` schema before passing `agent_type`. If the role is
missing (roles not installed, or a session started before installation), point
the child at its contract path (`teammate/workstream-owner.md` or
`teammate/independent-verifier.md` in this skill) and Skill(dispatched) in the
brief, and say that automatic role loading was unavailable.

For a cold review, spawn the verifier with `fork_turns: "none"` and supply the
artifacts, environment constraints and acceptance criteria without the builder's reasoning or
desired verdict. `"none"` isolates the conversation, not tools, files or
permissions. Do not combine a full-history fork with a model override; use
`"none"`; use another partial-history value only if the actual schema supports it.

## Models and files

Roles have no fixed model. The lead picks model and effort per task through
Skill(model-guide), applying the active environment restrictions first. A listed
name is not proof it will start; follow model-guide's single-attempt rule for an
explicitly requested ID omitted from advisory lists. Report requested settings
separately from what the runtime confirms.

Native children share the checkout. Give each owner a distinct write boundary
and leave other owners' files untouched. A role file is not a permission file:
a verifier's "do not modify" is an instruction, not a sandbox.
