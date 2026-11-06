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

The most important baseline case: if it fails, almost every other case will be
BLOCKED. Run it first.
