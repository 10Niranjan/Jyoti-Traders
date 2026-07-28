# Devlog

Running notes on planning/decisions that don't belong in phases.md or PRD.md.

## 2026-07-28 — Play Store & Apple Store deployment planning

- Estimated Play Store launch cost: ₹2,100 one-time (Developer account), ₹0–₹1,000/month running cost on Firebase's free/Blaze tier at current scale.
- Confirmed stack has no separate backend server — Firebase (Auth, Firestore, Storage, Cloud Messaging) covers it entirely.
- Admin price/stock edits sync to customers via Firestore real-time listeners, ~1–2 sec propagation; no bulk-edit UI yet (one product at a time).
- iOS is technically ready (Flutter `ios/` target already present) but requires Apple Developer Program ($99/yr recurring) and a Mac for builds — deferred until there's demand.
