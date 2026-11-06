---
id: TC-CAT-001
module: catalog
title: Homepage loads the hero, product sections, and category strip
priority: P1
steps:
  - Open /
  - Take a snapshot of the whole page
expected:
  - The heading "Melangkah ke Masa Depan Gaya" is visible
  - The "Belanja Koleksi Baru" link is visible
  - The "Favorit Minggu Ini" section is visible with 4 product cards
  - The text "12 produk · 5 kategori" is visible
  - The "Terbaru untuk Wanita" section is visible with 4 product cards
  - Product cards show a name and a price matching Rp<number>.<number>
tags: [smoke]
status: Active
---

The number of products per section depends on the seed. If the SUT uses a
different seed, update the `4`, `12`, and `5` values in the expected lines —
do not loosen the assertion to "some products".
