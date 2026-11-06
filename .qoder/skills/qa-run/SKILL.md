---
name: qa-run
description: >
  Execute a black-box UI test run from an Excel (.xlsx) or Markdown test case
  list and report results per test case. Use when the user asks to run QA,
  execute test cases, do a test run, or verify a website in the browser from a
  test case file. Drives Chrome directly through browser MCP tools (inline, not
  through a subagent), captures screenshot evidence, then writes verdicts,
  failure reasons, and evidence hyperlinks back into the input workbook plus a
  per-run summary.
---

# qa-run — execute a black-box QA test run

You orchestrate one test run. You do **not** hand the browser to a subagent —
you drive it yourself, following the `qa-engineer` procedure. Your job:
preflight, read the input, run the modules in order, then assemble the result
workbook and `summary.md`.

The application under test (SUT) lives outside this workspace and you must not
read its source. The full black-box rules live in
`.qoder/agents/qa-engineer.md`; read that file once before Step 4.

Artifacts you write (`results/<module>.md`, `summary.md`, the workbook) follow
the templates in `qa/templates/`. All templates and artifact text are in
English. Keep field names and fixed phrases exactly as the templates define
them, because the report is assembled by matching those strings.

## Arguments

| Argument | Required | Meaning |
|---|---|---|
| `--input <path>` | yes | `*.xlsx`, or a directory of Markdown test cases |
| `--only <a,b,c>` | no | Filter: module name, test case id, or tag. Comma-separated |
| `--url <base_url>` | no | Overrides `base_url` from the input |
| `--order <a,b,c>` | no | Module execution order; overrides the input config |
| `--no-writeback` | no | Do not write back to the input file; snapshot only |

Examples:

```
/qa-run --input qa/examples/test-cases.xlsx
/qa-run --input qa/examples/test-cases.xlsx --only auth,cart
/qa-run --input qa/examples/test-cases.xlsx --only TC-CHECKOUT-001
/qa-run --input qa/examples/test-cases.xlsx --url http://localhost:3001
/qa-run --input qa/examples/test-cases --only smoke
/qa-run --input qa/examples/test-cases.xlsx --no-writeback
/qa-run --input qa/examples/test-cases.xlsx --order cart,checkout,admin,auth,catalog
```

If the user asks in plain language ("run QA with that Excel file"), treat it as
the same invocation and ask for the input path when it is not obvious.

## Step 1 — Preflight

1. Resolve `base_url` by priority: `--url` → `Config` sheet (Excel mode) →
   frontmatter of `<input dir>/README.md` (Markdown mode). **There is no
   default.** Never fall back to `localhost`, a guessed port, or the URL from a
   previous run — read it from the input.

   For `.xlsx` input, read the `Config` sheet **now**; do not wait for Step 3:

   ```bash
   uv run --with openpyxl python - <<'PY'
   from openpyxl import load_workbook
   wb = load_workbook("<path from --input>")
   cfg = {}
   if "Config" in wb.sheetnames:
       for k, v in wb["Config"].iter_rows(min_row=2, values_only=True):
           if k:
               cfg[str(k).strip()] = "" if v is None else str(v).strip()
   print("base_url:", cfg.get("base_url"))
   print("logout_hint:", cfg.get("logout_hint"))
   print("module_order:", cfg.get("module_order"))
   PY
   ```

   Keep `logout_hint` and `module_order` from the same output — Step 4 and
   Step 3 need them. For Markdown input, read the frontmatter of
   `<input dir>/README.md` instead.

   Only when `--url` was not given **and** the input yields no `base_url`:
   **stop** and ask the user for the application URL.
2. Check the SUT is reachable:

   ```bash
   curl -sS -o /dev/null -w '%{http_code}\n' --max-time 10 <base_url>
   ```

   Code `000` or a connection error means the SUT is not up. **Stop** and reply:
   > The SUT at `<base_url>` is unreachable. This harness does not start the
   > application under test — bring the SUT up first, then run again.

   Do not guess how to start it and do not run any `docker`/`npm` command.
3. Check `uv`:

   ```bash
   uv --version
   ```

   If it is missing, **stop** with a message that uv is required for openpyxl.
   The `xlsx` skill is installed at `.qoder/skills/xlsx`; use it for workbook
   work, but run Python through `uv run --with openpyxl` as shown in this file.
4. Check the input file exists and is readable. If the `.xlsx` will not open,
   stop and report the error verbatim.
5. Check the templates are present:
   `qa/templates/test-case.md`, `qa/templates/module-result.md`,
   `qa/templates/excel-result.md`, `qa/templates/summary.md`.

   If any template is missing, **stop** and tell the user to copy `qa/templates/`
   from the QA skill repository or re-run its installer.
6. Check the browser MCP server:

   ```
   mcp_list({ keyword: "browser" })
   ```

   Use the server that actually exists (`browser-use`, `user-browser-use`, or
   another name) and its `mcp__<server>__*` prefix. If no browser server is
   available, **stop** and tell the user to connect Chrome through the Qoder
   browser connector.

## Step 2 — Run id and directory structure

```bash
RUN_ID=$(date +%Y-%m-%d-%H%M)
RUN_DIR=qa/runs/$RUN_ID
mkdir -p "$RUN_DIR"/{results,evidence,report}
git rev-parse --short HEAD > "$RUN_DIR/.qa-commit" 2>/dev/null || echo "no-git" > "$RUN_DIR/.qa-commit"
date '+%Y-%m-%d %H:%M:%S' > "$RUN_DIR/.started-at"
```

## Step 3 — Read the input

**`.xlsx` mode** — run Python inline through uv. Do not create a script file:

```bash
uv run --with openpyxl python - <<'PY'
from openpyxl import load_workbook
wb = load_workbook("<path from --input>")
for name in wb.sheetnames:
    ws = wb[name]
    print(f"### {name} ({ws.max_row}x{ws.max_column})")
    for row in ws.iter_rows(values_only=True):
        print(row)
PY
```

Replace the path with the value of `--input`. Required sheets: `TestCases`
(mandatory), `Accounts` (mandatory when any `account` cell is filled), `Config`
(mandatory for `base_url` unless `--url` was given; `logout_hint` and
`module_order` optional).

`TestCases` columns: `id`, `module`, `title`, `priority`, `account`,
`precondition`, `steps`, `expected`, `tags`, `status`.

**Markdown directory mode** — read the frontmatter of `<input dir>/README.md`
for `base_url`, `logout_hint`, `module_order`, and `accounts`, then read the
frontmatter of each `<input dir>/<module>/*.md`.

**Validate before continuing.** Stop and report when:

| Problem | Action |
|---|---|
| A required sheet or column is missing | Stop; name the missing sheet/column |
| Duplicate `id` | Stop; name the id |
| Empty `steps` or `expected` | Stop; name the id |
| `account` refers to a username absent from `Accounts` | **Do not stop** — mark that case BLOCKED with reason `Account <x> was not found in the Accounts sheet.` and run the rest |

**Normalize** every case into the same shape, whatever the input was:
`id, module, title, priority, account{username,email,password,role}|null, precondition, steps[], expected[], tags[], status`.

The `steps` and `expected` cells in Excel hold several lines in one cell — split
on newline, drop empty lines, drop leading `1.` / `-` numbering.

**`--only` filter** — a case joins the run when its `module`, its `id`, or any
of its `tags` appears in the list. A case with `status: Skipped` is not
executed; its verdict is `SKIP` outright, with reason
`Status is Skipped in the input.`

**Module order** — use the first source that exists:

1. `--order a,b,c`
2. `module_order` in the Excel `Config` sheet or the Markdown README frontmatter
3. first appearance of the module in the normalized case list

If one module creates data that a later module asserts on (for example an
`admin` dashboard fed by a `checkout` run), set `module_order` explicitly in the
input.

## Step 4 — Run the tests per module, inline

**Run inline, do not dispatch a subagent.** Subagents have no access to the
browser MCP tools (`mcp_call`), so driving the browser must happen in the main
agent. Read `.qoder/agents/qa-engineer.md` once at the start — it is the full
procedure you follow yourself, module by module. If that file is missing, look
for `~/.qoder/agents/qa-engineer.md`; if neither exists, stop and tell the user
to install the agent definition.

Per-case procedure in brief (the agent file has the details):

1. Record the start time (`date +%s`).
2. Reset the session — open `base_url`, look for a button labelled
   `logout_hint`, click it if present. Verify with `list_pages`.
3. Log in when `account` is filled. **Login failure → BLOCKED**, do not continue.
4. Execute `steps` one at a time through the browser MCP:
   - `mcp_call({ toolName: "mcp__<server>__navigate_page", ... })`
   - `mcp_call({ toolName: "mcp__<server>__take_snapshot", ... })`
   - `mcp_call({ toolName: "mcp__<server>__fill", ... })`
   - `mcp_call({ toolName: "mcp__<server>__click", ... })`
   - and so on. Take a snapshot **every** time after a navigation/interaction,
     before the next fill/click — a `uid` is only valid from the latest snapshot.
5. Screenshot evidence to `<run_dir>/evidence/<id>-<NN>.png`.
6. Judge each `expected` line against what was observed.
7. On FAIL, collect technical signals (`list_console_messages`,
   `list_network_requests`).
8. Record the end time, compute the duration.

Run **sequentially, one module at a time**. Never in parallel: there is only one
Chrome instance.

After each module finishes, write its results to `<run_dir>/results/<module>.md`
following `qa/templates/module-result.md` **exactly**. Cases with no result file
are noted so Step 5 can mark them BLOCKED with reason
`Not executed — module result file not found.`

## Step 5 — Assemble the results

Read `qa/templates/excel-result.md` and follow it **exactly**. Then:

1. Read every `<run_dir>/results/<module>.md`.
2. Write the snapshot `<run_dir>/test-cases.xlsx`: copy the input workbook, add
   a `Summary` sheet at index 0, fill the four result columns in `TestCases`
   (`Verdict`, `Failure Reason / Actual`, `Evidence`, `Run`), apply the
   per-verdict fill colour and the hyperlink on `Evidence`. Open with
   `load_workbook(path)` **without** `data_only=True`. Do not touch the
   `Accounts` and `Config` sheets.
3. **Write back** to the input path, unless `--no-writeback`. If the input path
   is outside this workspace (check with `git ls-files --error-unmatch <path>`;
   an error means untracked), **ask the user first** before overwriting. If the
   write-back fails because the file is locked, do not retry in a loop — report
   it and point at the snapshot path.
4. Write `<run_dir>/report/summary.md` following `qa/templates/summary.md`. Its
   numbers **must match** the `Summary` sheet.
5. ```bash
   date '+%Y-%m-%d %H:%M:%S' > "$RUN_DIR/.finished-at"
   ```

Do not reverse this order: snapshot before write-back, so a failed write-back
cannot destroy the results.

## Step 6 — Report to the user

Reply concisely:

- overall scorecard (PASS / FAIL / BLOCKED / SKIP out of N cases)
- FAIL list: `id — title — one-line reason`
- BLOCKED list: `id — one-line reason`
- path of the result workbook, path of `summary.md`, number of evidence files
- whether write-back happened, and to which path

Do not paste the whole report into the reply. Do not claim a case passed when it
has no evidence.

## Forbidden

- Reading or browsing the SUT source, including through relative paths outside
  this QA workspace.
- Running `docker`, `npm run dev`, migrations, or seeds to "fix" a failed
  preflight. The SUT is not this harness's responsibility.
- Editing test cases, expected results, or verdicts to make the run look better.
- Using `evaluate_script` as evidence.
- Delegating browser driving to a subagent — subagents have no access to the
  browser MCP tools. All browser interaction happens inline.
- Creating Python script files in this workspace. Python is allowed only inline
  through a heredoc, to read and write the workbook.
