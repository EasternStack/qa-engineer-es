# Test case template (Markdown)

Copy this file to `qa/examples/test-cases/<module>/<TC-ID>.md` (or your own input
directory). One file = one case.

Rules:
- `steps` mention **relative paths** and **visible labels** only. Never write
  CSS/XPath selectors — they bind the test case to the implementation, and a
  black-box QA engineer should not know them.
- `expected` = one observable assertion per line. A vague assertion ("the page
  looks fine") produces a vague verdict.
- `account` refers to a `username` in the frontmatter of the input directory's
  `README.md`. Omit the line for cases that must run without a login.
- Do not rename the frontmatter keys.

```markdown
---
id: TC-AUTH-001
module: auth
title: Login with valid customer credentials
priority: P0
account: customer
precondition: The customer@demo.id account exists in the SUT
steps:
  - Open /login
  - Verify the "Masuk" heading is visible, then fill "Email" with customer@demo.id
  - Fill "Password" with customer1234
  - Click the "Masuk" button
expected:
  - The URL becomes /
  - The header shows the "Pesanan Saya" link and the "Keluar" button
  - The header no longer shows the "Masuk" or "Daftar" links
  - No error message is visible on the page
tags: [smoke]
status: Active
---

Extra notes, test data, or known issues go here as prose. The agent does not use
this section to make decisions.
```

## Valid values

| Key | Values |
|---|---|
| `priority` | `P0`, `P1`, `P2` |
| `status` | `Active`, `Skipped` |
| `module` | Any module name used by your suite; examples: `auth`, `catalog`, `cart`, `checkout`, `admin` |
| `id` | `TC-<MODULE>-<NNN>`, unique across the whole library |
| `tags` | Free-form list; `smoke` and `demo-fail` are common choices |

The `demo-fail` tag marks cases that are **intentionally** designed to fail
during a demo, so the diagnosis flow, screenshots, and `Summary` sheet can be
shown working. The failure must be a real UI defect, not a mistyped test case.
