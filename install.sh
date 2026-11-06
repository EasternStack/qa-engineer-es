#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Install the qa-run skill into a Qoder project.

Usage:
  ./install.sh [--target DIR] [--force] [--with-example]

Options:
  --target DIR     Project root to install into (default: current directory)
  --force          Overwrite existing skill, agent, xlsx skill, and templates
  --with-example   Also copy qa/examples/ into the target
  -h, --help       Show this help

What gets installed:
  .qoder/skills/qa-run/
  .qoder/skills/xlsx/
  .qoder/agents/qa-engineer.md
  qa/templates/
  qa/runs/         (created empty)
USAGE
}

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
TARGET=$PWD
FORCE=0
WITH_EXAMPLE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target)
      [ $# -ge 2 ] || { echo "error: --target needs a directory" >&2; exit 1; }
      TARGET=$2
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --with-example)
      WITH_EXAMPLE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

[ -d "$TARGET" ] || { echo "error: target does not exist: $TARGET" >&2; exit 1; }

for required in \
  "$SCRIPT_DIR/.qoder/skills/qa-run/SKILL.md" \
  "$SCRIPT_DIR/.qoder/skills/xlsx/SKILL.md" \
  "$SCRIPT_DIR/.qoder/agents/qa-engineer.md" \
  "$SCRIPT_DIR/qa/templates"; do
  [ -e "$required" ] || { echo "error: missing source: $required" >&2; exit 1; }
done

copy_item() {
  src=$1
  dest=$2
  label=$3

  if [ -e "$dest" ] && [ "$FORCE" -eq 0 ]; then
    printf 'skip  %s (already exists; use --force to overwrite)\n' "$label"
    return 0
  fi

  if [ -e "$dest" ] && [ "$FORCE" -eq 1 ]; then
    rm -rf -- "$dest"
  fi

  mkdir -p -- "$(dirname -- "$dest")"
  cp -R -- "$src" "$dest"
  printf 'copy  %s\n' "$label"
}

printf 'Installing qa-run into %s\n\n' "$TARGET"

copy_item "$SCRIPT_DIR/.qoder/skills/qa-run" "$TARGET/.qoder/skills/qa-run" ".qoder/skills/qa-run"
copy_item "$SCRIPT_DIR/.qoder/skills/xlsx" "$TARGET/.qoder/skills/xlsx" ".qoder/skills/xlsx"
copy_item "$SCRIPT_DIR/.qoder/agents/qa-engineer.md" "$TARGET/.qoder/agents/qa-engineer.md" ".qoder/agents/qa-engineer.md"
copy_item "$SCRIPT_DIR/qa/templates" "$TARGET/qa/templates" "qa/templates"

if [ "$WITH_EXAMPLE" -eq 1 ]; then
  copy_item "$SCRIPT_DIR/qa/examples" "$TARGET/qa/examples" "qa/examples"
fi

mkdir -p -- "$TARGET/qa/runs"
printf 'mkdir %s\n' "qa/runs"

cat <<EOF

Done.

Next steps:
1. Add this line to $TARGET/.gitignore if it is not there already:
     qa/runs/
2. Restart Qoder so the skill and agent are registered.
3. Run a case:
     /qa-run --input qa/examples/test-cases.xlsx --only TC-AUTH-001

The SUT must already be running at its base_url. This harness does not start it.
EOF
