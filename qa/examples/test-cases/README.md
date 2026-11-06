---
base_url: https://easternstack-store.vercel.app/
logout_hint: Keluar
module_order: auth,catalog,cart,checkout,admin
accounts:
  - username: customer
    email: customer@demo.id
    password: customer1234
    role: CUSTOMER
    notes: Seed account with storefront access only.
  - username: admin
    email: admin@demo.id
    password: admin1234
    role: ADMIN
    notes: Seed account; shows the "Admin" link in the header and grants /admin.
---

# Example test case library

Black-box test cases for **Eastern Stack Store**, a demo e-commerce site. They
are written from observed UI behavior, **not** from source code — this repo does
not contain the SUT source.

The full demo suite has 19 cases. This directory contains a five-case subset,
one per module, so the kit stays small while still showing every input feature.

## How to use

```
/qa-run --input qa/examples/test-cases
/qa-run --input qa/examples/test-cases.xlsx
```

The frontmatter above is the Markdown equivalent of the Excel `Config` and
`Accounts` sheets. The skill combines it with each case file's frontmatter into
one normalized schema, so the agent never knows where the test cases came from.

To test a different application, replace `base_url`, `accounts`, and the cases.
Nothing in the harness is tied to this SUT.

## Adding cases

Copy `qa/templates/test-case.md` to `<module>/TC-<MODULE>-<NNN>.md`. The `id`
must be unique across the whole library. If a new case needs a new account, add
it to the `accounts` frontmatter above — never put credentials in a case file.

## Module order

`module_order` is explicit because `admin` asserts on a dashboard that only fills
in after `checkout` has created an order. For your own suite, set the order that
matches your data dependencies; otherwise the skill uses first appearance in the
input.

## SUT data referenced by the cases

These values come from the SUT seed and are used so the assertions are concrete:

- 12 products, 5 categories: `Pria`, `Wanita`, `Tas`, `Kacamata`, `Beanie`
- `Jaket Ringer Knit Pria` — `/produk/jaket-ringer-pria`, `Rp489.000`,
  category `Pria`, variants `Hitam` (S/M/L) and `Sage` (S/M/L)
- `Beanie Rajut Wol` (`Rp154.000`) and `Beanie Ombre Knit` (`Rp174.000`) — two
  products in the `Beanie` category, used for search-result assertions
- Flat shipping of `Rp15.000` on every order
- Mock cards: `4242 4242 4242 4242` succeeds, `4242 4242 4242 0002` is declined,
  expiry `12/29`, CVC `123`
- Order codes follow `ESV-<8 date digits>-<4 characters>`

If the SUT is reseeded with different data, update this section and every case
that references it — that is a human task, not part of the harness.

## Cases designed to fail

The full demo suite tags two real UI defects with `demo-fail`:

- `TC-CAT-005` — `/cari` without a query renders the word `undefined` in the heading
- `TC-CHECKOUT-004` — the status chip uses Indonesian labels while the tracking
  section uses raw enum values

They are not part of this five-case subset. Their purpose in the full demo is to
prove the agent reports FAIL honestly and does not invent a cause when console
and network are clean.
