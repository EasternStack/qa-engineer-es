# summary.md template

Written by the `qa-run` skill in Step 5 to
`qa/runs/<run-id>/report/summary.md`. It is the text version of the `Summary`
sheet — created so a run can be diffed and linked from a PR, because `.xlsx` is
binary and git cannot render it.

Screenshots are **not** embedded as relative links into `../../evidence/`; the
file names are enough. This file is read in a terminal more often than in a
Markdown renderer.

```markdown
# QA Run Result — 2026-09-29-1142

| | |
|---|---|
| Base URL | https://shop.example/ |
| Input | qa/examples/test-cases.xlsx |
| QA repo commit | e7f22df |
| Started | 2026-09-29 11:42:07 |
| Finished | 2026-09-29 12:04:33 |
| Total duration | 22 minutes 26 seconds |

## Scorecard

| Module | Total | Pass | Fail | Blocked | Skip | % Pass |
|---|---|---|---|---|---|---|
| auth | 1 | 1 | 0 | 0 | 0 | 100% |
| catalog | 1 | 1 | 0 | 0 | 0 | 100% |
| cart | 1 | 0 | 1 | 0 | 0 | 0% |
| checkout | 1 | 0 | 0 | 1 | 0 | 0% |
| admin | 1 | 0 | 0 | 0 | 1 | 0% |
| **Total** | **5** | **2** | **1** | **1** | **1** | **40%** |

## Failed cases

### TC-CART-001 — P0 — Add a variant product to the cart
- Expected: the "Ringkasan" panel shows "Subtotal" at Rp489.000
- Actual: the panel shows Rp0 and no line item
- Technical signals: No technical signals; the failure is visible only in the UI.
- Suspected cause: the cart state is not updated after the add-to-cart action.
  Marked as a suspicion — based only on browser signals.
- Evidence: TC-CART-001-06.png

## Blocked cases

### TC-CHECKOUT-001 — P0 — Create an order from the cart
- Blocked reason: login failed, so the checkout steps never ran.
- Evidence: TC-CHECKOUT-001-01.png

## Risk assessment

Five cases ran: two PASS, one FAIL, one BLOCKED, one SKIP. The single FAIL is
P0 and breaks the cart total, so the checkout flow cannot be trusted; this is
**not safe to release**. The BLOCKED checkout case means the order-creation flow
was **not tested at all**, and the SKIP admin case leaves the dashboard
unverified. Conclusion: not safe to release — fix the cart total, restore login,
and re-run checkout and admin.

## Artifacts

- Result workbook: `qa/runs/2026-09-29-1142/test-cases.xlsx`
- Write-back: `qa/examples/test-cases.xlsx`
- Module results: `qa/runs/2026-09-29-1142/results/`
- Evidence: `qa/runs/2026-09-29-1142/evidence/` (7 files)
```

## Rules

- The numbers in `summary.md` **must match** the numbers in the `Summary` sheet.
  Both are assembled from the same `results/<module>.md` files in the same step.
- A module that produced no `results/<module>.md` (the agent died mid-run) still
  appears in the scorecard: each of its cases counts as `BLOCKED` with reason
  `Not executed — module result file not found.`
- Section order is fixed: identity table, Scorecard, Failed cases, Blocked cases,
  Risk assessment, Artifacts. Empty sections still appear with a single
  `None.` line — do not delete them.
