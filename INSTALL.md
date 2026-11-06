# Installation

## Prerequisites

| Requirement | Check |
|---|---|
| Qoder Desktop | Open the app |
| Browser connector + Chrome | `mcp_list({ keyword: "browser" })` returns a browser server |
| `uv` | `uv --version` |
| `git` | `git --version` |
| SUT reachable | `curl -sS -o /dev/null -w '%{http_code}\n' <base_url>` returns a non-`000` code |

The harness does not install Python packages globally. openpyxl is resolved per
command through `uv run --with openpyxl`.

## Install into a project

From this repository:

```bash
./install.sh --target /path/to/your-project
```

The target must already exist. The installer creates these paths:

```
<target>/.qoder/skills/qa-run/SKILL.md
<target>/.qoder/skills/xlsx/...
<target>/.qoder/agents/qa-engineer.md
<target>/qa/templates/test-case.md
<target>/qa/templates/module-result.md
<target>/qa/templates/excel-result.md
<target>/qa/templates/summary.md
<target>/qa/runs/                  (empty, artifact directory)
```

Existing files are skipped unless you pass `--force`:

```bash
./install.sh --target /path/to/your-project --force
```

To copy the example cases and the illustrative summary as well:

```bash
./install.sh --target /path/to/your-project --with-example
```

Then add the artifact directory to the target's `.gitignore`:

```gitignore
qa/runs/
```

## Install without the script

Copy the same four artifacts by hand:

```bash
TARGET=/path/to/your-project

mkdir -p "$TARGET/.qoder/skills" "$TARGET/.qoder/agents" "$TARGET/qa"
cp -R .qoder/skills/qa-run "$TARGET/.qoder/skills/"
cp -R .qoder/skills/xlsx "$TARGET/.qoder/skills/"
cp .qoder/agents/qa-engineer.md "$TARGET/.qoder/agents/"
cp -R qa/templates "$TARGET/qa/"
mkdir -p "$TARGET/qa/runs"
```

## Restart Qoder

Skills and agents are read at session start. **Restart Qoder after installing**
so `/qa-run` and `qa-engineer` are registered in the target project.

## Verify

1. Confirm the files exist:

   ```bash
   ls .qoder/skills/qa-run/SKILL.md
   ls .qoder/skills/xlsx/SKILL.md
   ls .qoder/agents/qa-engineer.md
   ls qa/templates/
   ```

2. Restart Qoder and check that `/qa-run` appears in the skill picker.
3. Run a single case against a reachable SUT:

   ```
   /qa-run --input qa/examples/test-cases.xlsx --only TC-AUTH-001
   ```

   If the skill answers with a preflight error, follow the error: it names the
   missing prerequisite instead of guessing.

## Update

Re-run the installer with `--force`:

```bash
./install.sh --target /path/to/your-project --force
```

This overwrites the skill, the agent, the xlsx skill, and the four templates.
Your own test cases and `qa/runs/` are untouched.

If you have edited the templates in the target project, back them up before
using `--force`.

## Uninstall

Remove only the files this kit installed:

```bash
TARGET=/path/to/your-project

rm -rf "$TARGET/.qoder/skills/qa-run"
rm -rf "$TARGET/.qoder/skills/xlsx"
rm -f  "$TARGET/.qoder/agents/qa-engineer.md"
rm -rf "$TARGET/qa/templates"
```

Do not delete `qa/runs/` unless you want to discard past results. Remove
`qa/runs/` from `.gitignore` if you added it only for this kit.

## Optional: user-level install

A project-level install is recommended because the templates belong to the
project. If you want the skill available in every workspace, copy the skill and
agent to your user Qoder directory:

```bash
cp -R .qoder/skills/qa-run ~/.qoder/skills/
cp -R .qoder/skills/xlsx ~/.qoder/skills/
cp .qoder/agents/qa-engineer.md ~/.qoder/agents/
```

Templates are still required per project (`qa/templates/`), so each workspace
needs the four files. The skill stops with a clear message when they are missing.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `/qa-run` does not appear | Qoder was not restarted | Restart Qoder |
| "No browser server" | Chrome is not connected | Open the Qoder browser connector and connect Chrome |
| `uv: command not found` | uv is not installed | Install uv and reopen the terminal/Qoder |
| "Templates are missing" | `qa/templates/` was not copied | Re-run `install.sh` or copy the four files |
| Write-back fails | The workbook is open in Excel | Close it and re-run, or use `--no-writeback` |
| The agent reads the SUT source | Wrong workspace | Keep the QA workspace separate from the SUT; see the black-box rules in `.qoder/agents/qa-engineer.md` |

## License

The original code in this repository is MIT licensed — see [LICENSE](LICENSE).
The vendored `xlsx` skill is third-party software and is not covered by that
license — see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
