# Module result template

Written by the `qa-engineer` procedure to
`qa/runs/<run-id>/results/<module>.md` after every case in that module is done.
The `qa-run` skill reads this file to assemble the workbook and `summary.md` —
**the format must be exact**, because parsing matches the headings and field
names below.

Rules:
- One `## <id>` block per case, in execution order.
- `Verdict` is only `PASS`, `FAIL`, `BLOCKED`, or `SKIP`.
- `Technical signals` is required on FAIL. If console and network are clean,
  write exactly `No technical signals; the failure is visible only in the UI.`
  and do **not** invent a cause.
- `Evidence` = file name only (not a path), relative to
  `qa/runs/<run-id>/evidence/`.
- Never mention SUT file names, functions, or line numbers in any field.

```markdown
# Module result: auth
Run: 2026-09-29-1142
Base URL: https://shop.example/
Started: 2026-09-29 11:42:07
Finished: 2026-09-29 11:49:51

## TC-AUTH-001
Verdict: PASS
Duration: 34
Account: customer

| # | Step | Observed |
|---|---|---|
| 1 | Open /login | "Masuk" heading visible; "Email" and "Password" fields present |
| 2 | Fill "Email" with customer@demo.id | Value entered |
| 3 | Fill "Password" with customer1234 | Value entered (masked) |
| 4 | Click "Masuk" | URL changed to https://shop.example/ |

Expected vs Actual:
- The URL becomes / → observed: URL `/` (list_pages)
- The header shows "Pesanan Saya" and "Keluar" → observed: both present in the snapshot
- No error message is visible → observed: no error text in the snapshot

Evidence: TC-AUTH-001-04.png

## TC-AUTH-002
Verdict: FAIL
Duration: 41
Account: (no login)

| # | Step | Observed |
|---|---|---|
| 1 | Open /login | "Masuk" heading visible |
| 2 | Fill "Email" with customer@demo.id | Value entered |
| 3 | Fill "Password" with wrong12345 | Value entered |
| 4 | Click "Masuk" | Stayed on /login; no error message at all |

Expected vs Actual:
- Stay on /login → observed: as expected
- The text "Email atau password salah." appears → **not observed**; the page shows no message

Technical signals:
- network: POST /login → 200 (no request with status ≥ 400)
- console: no errors

Suspected cause: the server-side error is not rendered to the page. Marked as a
suspicion — based only on browser signals.

Evidence: TC-AUTH-002-04.png, TC-AUTH-002-04-console.png
```

## Field reference

| Field | Required | Content |
|---|---|---|
| `Verdict` | yes | `PASS` / `FAIL` / `BLOCKED` / `SKIP` |
| `Duration` | yes | Seconds, from `date +%s` before the first step until after the last assertion |
| `Account` | yes | The `username` used, or `(no login)` |
| step table | yes | One row per `steps` item; the "Observed" column contains facts, not judgements |
| `Expected vs Actual` | yes | One line per `expected`, format `- <expected> → observed: <fact>` |
| `Technical signals` | on FAIL | Requests with status ≥ 400 (method, path, status) and console errors |
| `Suspected cause` | on FAIL | One suspected cause, explicitly marked as a suspicion |
| `Evidence` | yes | PNG file names, comma-separated |

For `BLOCKED`, replace `Expected vs Actual` with a one-line `Blocked reason:`.
For `SKIP`, write only `Verdict: SKIP` and a one-line `Skip reason:`.
