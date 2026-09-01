# Handoff: Booking Lapangan (Field/Court Booking POS)

## Overview
Extension of an existing POS cashier app ("Arena Sports Club") that currently only sells swim-pool tickets. This adds a **court booking flow** to the same "Penjualan" (Sales) screen: cashier picks a court, picks an hour slot / duration, and checks out — for **same-day bookings only** (no future/past date selection; that belongs in a separate booking app).

## About the Design Files
The file in this bundle (`Booking Lapangan Multi Olahraga.dc.html`) is a **design reference / interactive prototype built in HTML**, not production code to copy directly. It demonstrates layout, states, and interaction logic. The task is to **recreate this design in the target codebase's existing environment** (whatever the POS app is actually built in — likely a native Android/iOS app or a web app, given the tablet POS screenshot this was based on) using that codebase's existing components, navigation, and data layer. If no environment exists yet, choose the framework that matches the rest of the POS app.

## Fidelity
**High-fidelity.** Colors, spacing, typography, and copy (in Bahasa Indonesia, matching the existing app's tone) are final. Recreate pixel-close using the target app's component library; only reach for the exact hex values below if the target app doesn't already have equivalent tokens.

## Screens / Views

This is a single screen: the **Penjualan** (Sales) tab, with a **Booking Lapangan** sub-tab added next to the existing **Ticket**, **Potongan**, **Item** tabs.

### Layout
- Full-height flex row: left icon sidebar (104px) → main content (flex:1) → right order summary panel (380px, fixed).
- Top: purple gradient header bar (`linear-gradient(90deg, #5C3BEB, #6E4CF5)`), 16px/28px padding, containing greeting + date (left) and club name (right).
- Main content area padding 26px/30px, vertical flex, gap 18px.

### 1. Tab bar (top of main content)
Pill-shaped tab group, background `#ECEBF4`, radius 12px, padding 5px, tabs: **Ticket**, **Booking Lapangan**, **Potongan**, **Item**. Active tab: white background, `box-shadow: 0 1px 4px rgba(30,20,80,.12)`, text `#1E1E28`, weight 700. Inactive: text `#6E6E80`, no background.

### 2. Booking Lapangan tab content
- **Court selector**: single-row, horizontally scrollable strip of pill chips (`overflow-x:auto`, `flex-wrap:nowrap`, chips have `flexShrink:0`, `whiteSpace:nowrap`) — NOT a wrapping grid, NOT grouped by sport category. Every physical court is a flat, individually-clickable chip labeled `"Lapangan {N} {Sport}"`, e.g.:
  - Lapangan 1 Badminton, Lapangan 2 Badminton, Lapangan 3 Badminton
  - Lapangan 1 Futsal, Lapangan 2 Futsal
  - Lapangan 1 Padel, Lapangan 2 Padel
  - Lapangan 1 Tenis, Lapangan 2 Tenis
  - Lapangan 1 Basket
  - Lapangan 1 Voli
  Active chip: `background:#5C3BEB`, `color:#fff`. Inactive: white bg, `border:1px solid #E4E1F5`, `color:#5A5A68`. Padding `9px 20px`, `border-radius:20px`, `font-weight:700`, `font-size:13.5px`.
- **Sub-header row**: left — "Pilih jam & durasi untuk {selected court label}" (13px, `#8A8A99`). Right — a **static, non-interactive** date pill (calendar icon + "{Hari, DD Mon YYYY} · Hari ini"). No prev/next arrows — **date cannot be changed**; the cashier can only book for today.
- **Legend row**: 3 color-coded swatches + labels — Tersedia (white, border `#DAD8E8`), Dipilih (`#5C3BEB` filled), Terisi (`#EFEFF2` filled) — plus a right-aligned price note "Harga **Rp 100.000** / jam".
- **Schedule grid**: `display:grid; grid-template-columns:repeat(auto-fill,minmax(128px,1fr)); gap:10px`. One cell per hourly slot from 06:00 to 23:00 (17 slots) for the **currently selected court only**. Each cell: time range (e.g. "06:00 - 07:00") + status label below it (Tersedia / Dipilih / Terisi).
  - Available: white bg, `border:1px solid #E4E4EA`, `color:#222`, clickable.
  - Selected: `background:#5C3BEB`, `color:#fff`, `box-shadow:0 4px 10px rgba(92,59,235,.3)`.
  - Booked/Terisi: `background:#F1F1F4`, `color:#B3B3BD`, `cursor:not-allowed`, not clickable.
  - Cell: `padding:14px 8px`, `border-radius:10px`, `font-weight:600`, `font-size:13.5px`, centered text.

### 3. Right panel — "Pesanan" (Order)
Fixed 380px, white bg, left border `1px solid #ECECF2`, padding 26px. Title "Pesanan" (`#5C3BEB`, 19px, weight 800). Three mutually-exclusive states:
- **Empty** (no slot selected): centered open-box icon (outline, `#C7C4E6`), "Belum Ada Pesanan" (15.5px bold), subtitle "Pilih jam pada jadwal untuk membuat pesanan" (12.5px, `#8A8A99`).
- **Selection made**: card (`border:1px solid #ECECF2`, `border-radius:12px`, padding 16px) showing court name, date, then a divider, then rows: Jam (time range), Durasi ("{n} jam"), Harga/jam ("Rp 100.000").
- **Paid / confirmed**: green circular check icon (bg `#E9F9EF`, icon `#28A862`), "Booking Berhasil" (16.5px bold), court · date · time (duration), total price (20px bold), and a "Buat Pesanan Baru" pill button (`#5C3BEB` bg, white text) to reset.

Bottom-pinned footer (`margin-top:auto`, top border): Total row (label 19px/800 left, amount 24px/800 right) then two buttons side by side: **Batal** (outline red `#E2574C`, pill, text red) and **Bayar** (pill, `#5C3BEB` bg white text when a selection exists, disabled/lighter `#D9D5F5` + `cursor:not-allowed` when nothing selected).

## Interactions & Behavior
- Clicking an available slot selects it. Clicking an **adjacent** available slot to the current selection **extends the range** (multi-hour duration) — selection is always a contiguous run of hours. Clicking a non-adjacent slot resets the selection to that single slot. Clicking an endpoint slot of the current selection removes it (shrinks the range). Booked slots are inert (no click).
- Switching the active court **resets the current slot selection** (a different court's schedule replaces the view; you can't carry a selection across courts).
- **Batal** clears the current selection back to empty state.
- **Bayar** (disabled until ≥1 slot selected) finalizes the booking: moves to the "paid" confirmation state, snapshotting court/date/time/duration/total into a receipt, and clears the working selection.
- **Buat Pesanan Baru** on the confirmation screen resets everything back to the empty state so the cashier can start the next transaction.
- Pricing: flat **Rp 100.000 per hour**, same rate for every court/sport. Total = selected hours × 100.000.
- **No date navigation.** This is a same-day, walk-in cashier flow only — do not add forward/back date controls; if the business needs advance bookings, that is explicitly a separate application.

## State Management
Minimal local UI state is sufficient:
- `activeTab`: 'ticket' | 'lapangan' | 'potongan' | 'item'
- `activeCourtIndex`: which court chip is selected (index into the flat court list)
- `selected`: array of selected hourly-slot indices for the active court (kept contiguous by the selection logic above)
- `paid`: boolean — whether we're showing the confirmation state
- `receipt`: snapshot object `{ court, date, time, duration, total }` captured at time of payment

Data needed from the backend (not present in this prototype — currently hardcoded):
- List of courts (id, name, sport category) — the prototype models this as a flat list but each court does belong to a sport category.
- Per-court, per-day hourly availability (which slots are already booked) — prototype hardcodes a few booked hours per court as a placeholder.
- Price per hour (currently flat 100.000 for all courts — confirm with product whether per-sport pricing is needed later).
- On "Bayar", the real implementation should create a booking/order record server-side (this prototype only simulates it client-side).

## Design Tokens
- Primary purple: `#5C3BEB` (gradient header uses `#5C3BEB → #6E4CF5`)
- Primary text: `#1E1E28`
- Secondary/muted text: `#8A8A99`, `#5A5A68`, `#6E6E80`
- Borders: `#ECECF2`, `#E4E4EA`, `#E4E1F5`, `#E7E5F5`
- Booked/disabled surface: `#F1F1F4`, disabled text `#B3B3BD`
- Success green: `#28A862` on `#E9F9EF`
- Danger red (Batal): `#E2574C`
- Font: Poppins (400/500/600/700/800), Google Fonts
- Radii: pills `20–30px`, cards `12–14px`, small controls `8–10px`
- Spacing scale used: 4, 6, 8, 10, 14, 16, 18, 22, 26, 28, 30px

## Assets
No image assets — the "Arena Sports Club" logo is a text placeholder (`Arena Sports Club` centered in a tinted box) in the Ticket tab mock; the real logo asset should be swapped in by the developer. All icons are inline SVG line icons (sidebar nav, calendar, checkmark, empty-state box) — recreate with the target codebase's icon set/library rather than copying raw SVG paths.

## Files
- `Booking Lapangan Multi Olahraga.dc.html` — the interactive HTML prototype covering the full flow described above (court selection → slot/duration selection → order summary → payment confirmation).
