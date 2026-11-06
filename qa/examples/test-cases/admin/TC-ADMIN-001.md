---
id: TC-ADMIN-001
module: admin
title: Admin signs in to the dashboard and sees KPIs and data panels
priority: P0
account: admin
precondition: The admin@demo.id account exists and the checkout module has run
steps:
  - Open /login and sign in as admin
  - Verify the "Admin" link is visible in the store header
  - Click the "Admin" link in the header
  - Take a snapshot of the whole page
  - Click the "7 hari" pill in the period selector
expected:
  - The URL becomes /admin
  - The heading "Dashboard" is visible
  - The sidebar shows "Easternstack Admin" and the menus "Dashboard", "Pesanan", "Produk & Stok", "Pengguna"
  - Four KPI cards are visible with the labels "Revenue 7 hari", "Pesanan dibayar", "Rata-rata pesanan", "User baru"
  - The panel "Revenue harian · 7 hari" is visible
  - The panel "Status pesanan · seluruh waktu" is visible
  - The panels "Produk terlaris", "Stok menipis · ≤ 5", and "Pesanan terbaru" are visible
  - The sidebar also shows the "← Toko" link
tags: [smoke]
status: Active
---

KPI and panel labels follow the selected period, so the assertions mention
`7 hari` after the pill is clicked. The SUT seed creates no orders; these numbers
only fill in after the `checkout` module has run — that is why `admin` is
scheduled last.

If every panel shows "Belum ada data." and "Belum ada pesanan.", that is BLOCKED
(precondition data missing), not FAIL.
