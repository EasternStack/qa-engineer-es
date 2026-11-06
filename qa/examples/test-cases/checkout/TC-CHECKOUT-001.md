---
id: TC-CHECKOUT-001
module: checkout
title: Create an order from the cart and reach the payment gateway
priority: P0
account: customer
precondition: The cart contains at least one item
steps:
  - Open /cart
  - If the cart is empty, add Beanie Rajut Wol in color Hitam, size All, then return to /cart
  - Click the "Lanjut ke Checkout" button
  - In the "Alamat Pengiriman" section, fill "Nama penerima" with QA Tester
  - Fill "No. handphone" with 081200001111
  - Fill "Alamat (jalan, nomor, RT/RW)" with Jl. QA No. 1 RT 01 RW 02
  - Fill "Kota" with Jakarta
  - Fill "Provinsi" with DKI Jakarta
  - Fill "Kode pos" with 12340
  - Click the "Buat Pesanan" button
  - Wait for the payment page to finish loading, then take a snapshot
expected:
  - The URL becomes /payment/<order code> with a code matching ESV-<8 digits>-<4 characters>
  - The text "MockPay — Gateway Tiruan" is visible
  - The heading "Pembayaran" is visible
  - The line "Pesanan <order code> — tagihan Rp<number>" is visible and the code matches the URL
  - The fields "Nomor kartu (16 digit)", "MM/YY", and "CVC" are visible
  - The "Bayar Sekarang" button is visible
tags: [smoke]
status: Active
---

Checkout has no courier selection and no notes field; shipping is flat at
Rp15.000. Do not add a step to choose shipping.

This case creates a real order in the SUT with an awaiting-payment status. Leave
it as is; the order stays awaiting payment.
