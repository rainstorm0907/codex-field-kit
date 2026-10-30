#!/usr/bin/env bash
# Install skills, taskforce roles and AGENTS.md into Codex.
# Usage: ./install.sh            -> skills + AGENTS.md
#        ./install.sh --skills   -> skills and roles, no AGENTS.md
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
dest="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$dest/skills"
for s in "$here"/skills/*/; do
  name="$(basename "$s")"
  rm -rf "$dest/skills/$name"
  cp -R "$s" "$dest/skills/$name"
  echo "skill: $name"
done
mkdir -p "$dest/agents"
for r in "$here"/agents/*.toml; do
  cp "$r" "$dest/agents/"
  echo "role: $(basename "$r" .toml)"
done
if [ "${1:-}" != "--skills" ]; then
  marker="<!-- codex-field-kit -->"
  if [ -f "$dest/AGENTS.md" ] && grep -q "$marker" "$dest/AGENTS.md"; then
    echo "AGENTS.md: already installed"
  else
    { [ -s "$dest/AGENTS.md" ] && echo; echo "$marker"; cat "$here/AGENTS.md"; } >> "$dest/AGENTS.md"
    echo "AGENTS.md: appended to $dest/AGENTS.md"
  fi
fi
echo "done. Start a new codex session to load them."
