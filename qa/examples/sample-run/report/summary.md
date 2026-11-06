# QA Run Result — 2026-10-06-1518

| | |
|---|---|
| Base URL | https://easternstack-store.vercel.app/ |
| Input | qa/examples/test-cases.xlsx |
| QA repo commit | e7f22df |
| Started | 2026-10-06 15:18:04 |
| Finished | 2026-10-06 15:31:42 |
| Total duration | 13 minutes 38 seconds |

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

### TC-CART-001 — P0 — Add a variant product to the cart and compute the total with shipping
- Expected: the "Ringkasan" panel shows "Subtotal" at Rp489.000
- Actual: the panel shows Rp0 and no line item
- Technical signals: No technical signals; the failure is visible only in the UI.
- Suspected cause: the cart state is not updated after the add-to-cart action.
  Marked as a suspicion — based only on browser signals.
- Evidence: TC-CART-001-06.png

## Blocked cases

### TC-CHECKOUT-001 — P0 — Create an order from the cart and reach the payment gateway
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

- Result workbook: `qa/runs/2026-10-06-1518/test-cases.xlsx`
- Write-back: `qa/examples/test-cases.xlsx`
- Module results: `qa/runs/2026-10-06-1518/results/`
- Evidence: `qa/runs/2026-10-06-1518/evidence/` (7 files)
