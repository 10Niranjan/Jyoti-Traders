# Jyoti Kirana

A closed, invite-only B2B wholesale ordering app for a local Kirana (grocery/FMCG) distributor and their network of ~30 verified retailers — built with Flutter, Clean Architecture, Riverpod, and Firebase (Auth + Firestore), with a Hive-backed simulation mode that runs the full app before a real Firebase project is configured.

See [`PRD.md`](PRD.md) for the product spec, [`ARCHITECTURE.md`](ARCHITECTURE.md) for the technical design, [`rules.md`](rules.md) for development rules, and [`phases.md`](phases.md) for the current build status — phases.md is the single source of truth for "what's done" and "what's next."

## Status

- **Phase 1 — Foundation**: ✅ Complete
- **Phase 2 — Domain Layer & Data Models**: ✅ Complete
- **Phase 3 — Core Commerce (Retailer Side)**: ✅ Complete
- **Phase 4 onward**: see [`phases.md`](phases.md)

## Getting Started

```bash
flutter pub get
flutter run
```

Firebase is currently on placeholder credentials (`lib/firebase_options.dart`) — the app automatically falls back to a Hive-backed simulation mode for auth, catalog, cart, and orders, so it's fully runnable and testable without a configured Firebase project. Quick test accounts in simulation mode:

| Role | Email | Password |
|---|---|---|
| Admin | `admin@jyoti.com` | `admin123` |
| Retailer | `retailer@jyoti.com` | `retailer123` |

## Testing

```bash
flutter analyze
flutter test
```
