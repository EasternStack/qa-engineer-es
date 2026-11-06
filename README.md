# qa-engineer-es

A **black-box QA harness** that turns Qoder into a QA engineer. Give it a list of
test cases and it opens a real Chrome, executes each case like a user, then
writes the verdicts, failure reasons, and screenshot links back into the input
workbook plus a per-run summary.

This repository contains **no source code of the application under test (SUT)**,
and the QA procedure forbids reading it. Every conclusion comes from what is
visible in the browser: URL, accessibility snapshot, screenshot, console
errors, and network requests.

## What's included

- `qa-run` skill — the `/qa-run` entry point: preflight, input parsing, run
  orchestration, workbook assembly, and reporting.
- `qa-engineer` agent definition — the per-case black-box procedure.
- Four output templates that keep results consistent without generator scripts.
- A vendored `xlsx` skill for workbook work.
- Five example test cases, an equivalent Excel input, and an illustrative run
  summary.

## Requirements

- Qoder Desktop with the **browser MCP** connector and Chrome available.
- [uv](https://docs.astral.sh/uv/) on `PATH` (`uv --version`). The harness runs
  openpyxl through `uv run --with openpyxl`; there is no global Python install.
- The SUT is running and reachable at its `base_url`. This harness does not
  start the application under test.
- Qoder must be **restarted** after installation, because skills and agents are
  read at session start.

## Install

Install into an existing project:

```bash
git clone <this-repo> qa-engineer-es
cd qa-engineer-es
./install.sh --target /path/to/your-project
```

The installer copies:

```
.qoder/skills/qa-run/              -> <target>/.qoder/skills/qa-run/
.qoder/skills/xlsx/                -> <target>/.qoder/skills/xlsx/
.qoder/agents/qa-engineer.md       -> <target>/.qoder/agents/qa-engineer.md
qa/templates/                      -> <target>/qa/templates/
```

It also creates `<target>/qa/runs/`. Add `qa/runs/` to the target's `.gitignore`
if it is not there already.

Options:

```bash
./install.sh --target ../my-app --with-example   # also copy qa/examples/
./install.sh --target ../my-app --force          # overwrite existing files
```

Manual installation is documented in [INSTALL.md](INSTALL.md). After installing,
restart Qoder so the `/qa-run` skill and `qa-engineer` agent are registered.

You can also open this repository itself as a Qoder project: the skill, agent,
xlsx skill, and templates are already in the Qoder-native layout. Restart Qoder
after cloning it.

## Language

Documentation, prompts, template fields, and report text are English. UI labels
quoted inside test cases stay in the SUT's language (for example `Masuk`,
`Keranjang`) because they are literal strings the agent must find on the page.

## Quick start

```bash
/qa-run --input qa/examples/test-cases.xlsx
/qa-run --input qa/examples/test-cases
/qa-run --input qa/examples/test-cases.xlsx --only auth,cart
/qa-run --input qa/examples/test-cases.xlsx --only TC-CHECKOUT-001
/qa-run --input qa/examples/test-cases.xlsx --url http://localhost:3001
/qa-run --input qa/examples/test-cases.xlsx --order cart,checkout,admin,auth,catalog
/qa-run --input qa/examples/test-cases.xlsx --no-writeback
```

The slash command is optional — plain language works too:
"run the qa-run workflow with qa/examples/test-cases.xlsx, auth module only".

## Input formats

### Excel (`.xlsx`)

Three sheets:

| Sheet | Purpose | Required |
|---|---|---|
| `TestCases` | The cases | Yes |
| `Accounts` | Credentials referenced by `account` | When any case has an `account` |
| `Config` | `base_url`, `logout_hint`, `module_order` | For `base_url` unless `--url` is given |

`TestCases` columns:

| Column | Required | Example |
|---|---|---|
| `id` | Yes | `TC-AUTH-001` |
| `module` | Yes | `auth` |
| `title` | Yes | Login with valid customer credentials |
| `priority` | Yes | `P0` / `P1` / `P2` |
| `account` | No | `customer` (references `Accounts.username`) |
| `precondition` | No | The account exists in the SUT |
| `steps` | Yes | One step per line inside the cell |
| `expected` | Yes | One assertion per line inside the cell |
| `tags` | No | `smoke,regression` |
| `status` | No | `Active` / `Skipped` |

`Accounts` columns: `username`, `email`, `password`, `role` (`notes` optional).
`Config` is a two-column `key,value` sheet.

### Markdown directory

The input directory contains a `README.md` with frontmatter for `base_url`,
`logout_hint`, `module_order`, and `accounts`, plus one `.md` file per case:

```
my-test-cases/
├── README.md
├── auth/TC-AUTH-001.md
├── catalog/TC-CAT-001.md
└── cart/TC-CART-001.md
```

Start from `qa/templates/test-case.md`. `steps` and `expected` must use relative
paths and visible labels — never CSS/XPath selectors.

## Configuration

| Key | Meaning |
|---|---|
| `base_url` | Application under test. No default; the run stops if it is missing |
| `logout_hint` | Label of the sign-out control, used to reset the session per case |
| `module_order` | Comma-separated execution order. Defaults to first appearance in the input |

Set `module_order` when one module creates data another module asserts on. In the
example suite, `admin` reads a dashboard that only fills in after `checkout`.

`--url` overrides `base_url`; `--order` overrides `module_order`.

## How it works

```
Excel / Markdown test cases
        |
   /qa-run  --  preflight  --  run id
        |
   qa-engineer procedure, inline in the main agent (sequential)
        |   Chrome through browser MCP
        v
   qa/runs/<run-id>/{results,evidence}/
        |
   snapshot workbook + write-back to input + report/summary.md
```

The skill drives the browser **inline**, not through a subagent: subagents do not
have access to MCP browser tools in this runtime. The `qa-engineer` file is a
reference procedure that the main agent follows.

## Output

Each run writes to `qa/runs/<run-id>/`:

```
qa/runs/<run-id>/
├── evidence/<TC-ID>-<NN>.png
├── results/<module>.md
├── report/summary.md
├── test-cases.xlsx          # snapshot with Summary sheet
├── .qa-commit
├── .started-at
└── .finished-at
```

Verdicts are exactly `PASS`, `FAIL`, `BLOCKED`, or `SKIP`:

| Verdict | Meaning |
|---|---|
| `PASS` | Every expected line was observed, and there is screenshot evidence |
| `FAIL` | An expected line was not met, or the application errored |
| `BLOCKED` | A precondition or setup failed — login, data, dialog, or an unreachable element |
| `SKIP` | The case status is `Skipped`, or it depends on a case that FAILed |

The snapshot is written before the write-back, so a locked input file cannot
destroy the results. The result workbook gets a `Summary` sheet and four result
columns in `TestCases`: `Verdict`, `Failure Reason / Actual`, `Evidence`, `Run`.

## Templates

| Template | Keeps consistent |
|---|---|
| `qa/templates/test-case.md` | Markdown case format |
| `qa/templates/module-result.md` | Per-module result format the agent writes |
| `qa/templates/excel-result.md` | Workbook columns, colours, hyperlinks, `Summary` layout |
| `qa/templates/summary.md` | `report/summary.md` structure |

Templates are English and are parsed mechanically; keep field names and fixed
phrases exactly as written.

## Examples

- `qa/examples/test-cases/` — five Markdown cases, one per module.
- `qa/examples/test-cases.xlsx` — the same cases in Excel.
- `qa/examples/sample-run/report/summary.md` — illustrative output format; not a
  real execution, and evidence PNGs are omitted.

The examples target the Eastern Stack demo storefront. Replace `base_url`,
`accounts`, and the cases to test your own application.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `/qa-run` or `qa-engineer` is not available | Restart Qoder; skills and agents are loaded at session start |
| "No browser server" | Connect Chrome through the Qoder browser connector, then check `mcp_list({ keyword: "browser" })` |
| The SUT is unreachable | Start the application yourself; this harness never starts, seeds, or migrates the SUT |
| `uv` is missing | Install uv and confirm `uv --version` works |
| Templates are missing | Re-run `install.sh` or copy `qa/templates/` into the project |
| Write-back fails because the workbook is open | Close it in Excel and re-run, or use `--no-writeback` and use the snapshot |
| A case reports BLOCKED | That is not a pass: the flow was not tested. Fix the precondition and re-run |

## Limitations

- Sequential with a single Chrome. One case at a time, one module at a time.
- No automatic retry. Each case runs exactly once.
- Failure diagnosis is limited to browser signals: the agent can say
  "POST /checkout returned 500", not point at a line of code.
- No CI integration, scheduling, parallel execution, or visual regression.
- Credentials in input files are plaintext. Use dedicated test accounts only.

## Repository layout

| Path | Contents |
|---|---|
| `.qoder/skills/qa-run/SKILL.md` | Workflow: preflight → inline execution → assemble results |
| `.qoder/agents/qa-engineer.md` | Black-box per-case procedure |
| `.qoder/skills/xlsx/` | Vendored Excel skill |
| `qa/templates/` | Four result templates |
| `qa/examples/` | Five example cases, Excel input, illustrative summary |
| `qa/runs/` | Per-run artifacts (gitignored) |
| `install.sh` | Project installer |
| `INSTALL.md` | Detailed installation and uninstallation |

## Attribution

The `xlsx` skill is vendored from
[AutumnsGrove/ClaudeSkills](https://github.com/AutumnsGrove/ClaudeSkills) and
adapted to run through `uv` with openpyxl. It is included because the `qa-run`
workflow depends on it for reading and writing workbooks.

## License

The original code in this repository is released under the MIT License — see
[LICENSE](LICENSE).

The vendored `xlsx` skill is third-party software and is **not** covered by the
MIT license. Its upstream repository declares no license. See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) before publishing or
redistributing this repository.

Use this harness only against applications you are authorized to test.
