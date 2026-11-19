# Devlog

Running notes on planning/decisions that don't belong in phases.md or PRD.md.

## 2026-07-28 — Play Store & Apple Store deployment planning

- Estimated Play Store launch cost: ₹2,100 one-time (Developer account), ₹0–₹1,000/month running cost on Firebase's free/Blaze tier at current scale.
- Confirmed stack has no separate backend server — Firebase (Auth, Firestore, Storage, Cloud Messaging) covers it entirely.
- Admin price/stock edits sync to customers via Firestore real-time listeners, ~1–2 sec propagation; no bulk-edit UI yet (one product at a time).
- iOS is technically ready (Flutter `ios/` target already present) but requires Apple Developer Program ($99/yr recurring) and a Mac for builds — deferred until there's demand.

## 2026-10-15 — When does stock move?

- Until now nothing reduced stock; the admin had to edit it by hand after every order. Chosen default: **take stock when the order is placed, give it back when it's cancelled** (by either side). Taking it at placement is what stops two retailers buying the same last box; waiting for "Confirmed" or "Delivered" would let the shop oversell in between.
- Alternatives the client may prefer: take stock only at "Confirmed" (owner checks the shelf first) or at "Delivered". Either is a small change in `PlaceOrderUseCase` / `UpdateOrderStatusUseCase`. **Confirm with the client.**
- Kg products needed fractional stock (50 kg − 2.5 kg), so `stock` became a decimal number — a Firestore field-type widening, existing whole-number values read unchanged.
- Known limit: the stock update is read-then-write. Fine on one phone; with live Firestore and several retailers checking out the last unit at the same moment it should become a transaction.
- Manual QA lives in `TEST_PLAN.md` + `Jyoti_Traders_Test_Cases.xlsx`. Emulator automation tip: adb `input text` only reaches plain-text Flutter fields with Gboard disabled (`adb shell ime disable …LatinIME`), and must be re-enabled afterwards.
