# Result workbook template

Used by the `qa-run` skill in Step 5 when writing
`qa/runs/<run-id>/test-cases.xlsx` (snapshot) and when writing back to the input
file. Open the workbook with `load_workbook(path)` **without** `data_only=True`,
so existing formulas and formatting survive the save.

## Write order (do not reverse)

1. `evidence/` — already written during execution
2. `results/<module>.md` — already written by the agent
3. snapshot `qa/runs/<run-id>/test-cases.xlsx`
4. write-back to the input path (unless `--no-writeback`, or the input is
   outside the workspace and the user declines)
5. `qa/runs/<run-id>/report/summary.md`

The snapshot is written first so a failed write-back (file open in Excel,
permissions) cannot destroy the results.

## Sheets

Sheet order after writing: `Summary`, `TestCases`, `Accounts`, `Config`.

- **`Summary`** — created new and moved to index 0. If a previous run left one,
  delete it and create it again.
- **`TestCases`** — existing rows are not added, removed, or reordered. Result
  columns are matched by `id`.
- **`Accounts`** and **`Config`** — **never touched**.

## Result columns in `TestCases`

Four columns are appended to the right of the last input column (`status`),
headers in row 1:

| Column | Content | Width |
|---|---|---|
| `Verdict` | `PASS` / `FAIL` / `BLOCKED` / `SKIP` | 12 |
| `Failure Reason / Actual` | see the text rules below | 70 |
| `Evidence` | hyperlink to the first screenshot | 34 |
| `Run` | `<run-id>` | 18 |

Result-column headers use fill `1F2937` with bold white font, and every cell in
those four columns uses `wrap_text=True`, `vertical="top"`.

### `Failure Reason / Actual` text rules

- **PASS** → `As expected. ` followed by all `expected` lines joined with `; `.
- **FAIL** → `Expected: <failed expected line> | Actual: <observed>` then a new
  line `Suspected: <suspected cause from results>`. If the result file says
  `No technical signals; the failure is visible only in the UI.`, copy that
  sentence verbatim after `Suspected:` — do not invent a cause.
- **BLOCKED** → the `Blocked reason:` text from the result file.
- **SKIP** → the `Skip reason:` text from the result file.

Never copy SUT file names, functions, or line numbers into this column.

### `Verdict` fill colours

| Verdict | Fill | Font |
|---|---|---|
| `PASS` | `C6EFCE` | `006100` |
| `FAIL` | `FFC7CE` | `9C0006` |
| `BLOCKED` | `FFEB9C` | `9C6500` |
| `SKIP` | `E7E6E6` | `808080` |

Fill and font apply only to the `Verdict` cell. The font is bold.

### `Evidence` hyperlink

- Target: the **first** screenshot named in the `Evidence` field of the result
  file.
- Use a relative path when the workbook and `qa/runs/` live in the same repo.
  From `qa/examples/test-cases.xlsx`, the target is
  `../runs/<run-id>/evidence/<file>.png`.
- When the workbook is outside the repo, use an absolute path.
- The displayed cell text is the file name only. Font is blue `0563C1` with a
  single underline.
- If a case has more than one screenshot, write the rest in
  `Failure Reason / Actual` as a `Other evidence: <name>, <name>` line.
- If there is no screenshot (for example `SKIP`), leave the cell empty and add no
  hyperlink.

## `Summary` sheet layout

Row by row, starting at `A1`. Column `A` holds labels (width 26), columns `B`–`G`
hold values.

```
A1  QA RUN RESULT                      (font 14 bold)
A2  Run ID          B2 <run-id>
A3  Base URL        B3 <base_url>
A4  Input           B4 <input path, relative to the repo root>
A5  QA repo commit  B5 <git rev-parse --short HEAD>
A6  Started         B6 <YYYY-MM-DD HH:MM:SS>
A7  Finished        B7 <YYYY-MM-DD HH:MM:SS>
A8  Total duration  B8 <n> minutes <m> seconds
A9  (empty)
A10 SCORECARD BY MODULE                (bold, fill 1F2937, white font)
A11 Module  B11 Total  C11 Pass  D11 Fail  E11 Blocked  F11 Skip  G11 % Pass
      (row 11 = header, bold, fill E7E6E6)
A12..  one row per module, in execution order
A<after last module + 1> TOTAL  (bold) — sum of each column, % Pass = round(pass / total * 100)
A<+2> (empty)
A<+3> FAILED CASES (BY PRIORITY)       (bold, fill 9C0006, white font)
A<+4> ID  B Title  C Priority  D Short reason  E Suspected  F Evidence
      (header, bold, fill E7E6E6)
      one row per FAIL then BLOCKED, sorted P0 → P1 → P2
      column F = hyperlink to the screenshot, same style as the Evidence column
      if nothing failed: one row `No failed cases.` in column A
A<+2> (empty)
A<+2> RISK ASSESSMENT                  (bold, fill 1F2937, white font)
A<+3> assessment paragraph, merged A:F, wrap_text, row height adjusted
```

`% Pass` is written as a whole number followed by `%` (for example `79%`),
calculated as `round(pass / total * 100)`; when `total` is 0 write `—`.

### `RISK ASSESSMENT` rules

Three to five sentences, written from the numbers in this sheet — not from a
generic template. It must mention: (1) the number and priority of FAIL cases,
(2) whether any `P0` case FAILed and what that means for release, (3) the number
of BLOCKED cases and whether that means an area was **untested** (BLOCKED ≠
safe), and (4) an explicit conclusion: `safe to release`, `not safe to release`,
or `safe to release with caveats`.

Example tone:

> 19 cases ran: 16 PASS, 2 FAIL, 1 BLOCKED. Both FAILs are P2 and are label
> consistency defects rather than lost functionality, so they do not block
> release. One BLOCKED in the admin module means the order-status flow was
> **not tested at all** and must be re-run before release. Conclusion: safe to
> release with caveats — fix the two label defects and re-run the blocked admin
> case.
