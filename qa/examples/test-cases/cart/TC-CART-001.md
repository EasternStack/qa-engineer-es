---
id: TC-CART-001
module: cart
title: Add a variant product to the cart and compute the total with shipping
priority: P0
account: customer
precondition: Logged in as customer
steps:
  - Open /produk/jaket-ringer-pria
  - In the "Warna" section, select the "Hitam" swatch
  - In the "Ukuran" section, select "M"
  - Click the "Tambah ke Keranjang" button
  - Take a snapshot of the cart page
expected:
  - The URL becomes /cart
  - The "Jaket Ringer Knit Pria" line is visible with variant "Hitam / M"
  - The "Ringkasan" panel shows a "Subtotal" line of Rp489.000
  - The "Ongkir" line is Rp15.000
  - The "Total" line is Rp504.000
  - The "Lanjut ke Checkout" button is visible
  - The numeric badge next to "Keranjang" in the header increased compared with before adding
tags: [smoke]
status: Active
---

Record the header badge count **before** clicking "Tambah ke Keranjang" so the
last assertion has a baseline. The cart persists in the SUT between runs, so the
initial count is not always 0.
