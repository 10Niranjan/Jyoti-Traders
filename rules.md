# 📜 RULES.md
## Jyoti Kirana — Project Development Rules & Regulations

> These rules are **non-negotiable** and must be followed on **every single implementation**, every file, every feature, every session — without exception.  
> **Every AI agent, developer, or contributor working on this project must read and internalize this file before writing a single line of code.**

---

## ⚠️ RULE ZERO — The Prime Directive

> **Write code like a human senior developer would — not like an AI trying to impress.**

- Code must be **readable at a glance** by any competent Flutter developer.
- Prefer **simplicity over cleverness**. If a junior dev can't understand it in 5 seconds, rewrite it.
- No unnecessary abstractions. No premature optimization. No over-engineering.
- Every file must have **one clear responsibility** — if you can't explain what a file does in one sentence, it needs to be split.

---

## 1. ✅ WHAT TO USE — Approved Libraries Only

Only the following packages are approved for this project. **Do not introduce any new package without explicitly updating `ARCHITECTURE.md` and `pubspec.yaml` with a justification.**

| Category | Approved Package |
|---|---|
| State Management | `flutter_riverpod`, `riverpod_annotation` |
| Navigation | `go_router` |
| Backend | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`, `firebase_crashlytics` |
| Local Storage | `hive_flutter`, `flutter_secure_storage` |
| Networking | `dio`, `pretty_dio_logger` (dev only) |
| Images | `cached_network_image`, `shimmer` |
| Animations | `lottie` |
| Charts | `fl_chart` |
| Icons/SVG | `flutter_svg` |
| Fonts | `google_fonts` — Poppins + Inter only |
| Serialization | `freezed`, `json_annotation`, `json_serializable` |
| Utilities | `intl`, `equatable`, `uuid`, `url_launcher`, `geolocator`, `permission_handler` |
| Payments | `qr_flutter` — renders the UPI QR code client-side from the UPI ID string (Phase 5, approved by client-facing user in session) |
| Testing | `flutter_test`, `mocktail`, `integration_test` |
| Code Gen | `build_runner` |

---

## 2. 🚫 WHAT TO AVOID — Hard Bans

### 2.1 Banned Libraries
- ❌ `get` / `GetX` — Mixes routing, state, and DI in one mess. Violates SOLID.
- ❌ `provider` (standalone) — We use Riverpod. Mixing both causes conflicts.
- ❌ `bloc` / `flutter_bloc` — Not chosen for this project. Do not introduce.
- ❌ `shared_preferences` — Replaced by `hive_flutter`. Do not use both.
- ❌ `http` (dart:http) — Replaced by `Dio`. Never use bare `http` package.
- ❌ `auto_route` — We use `go_router`. Not both.
- ❌ Any charting library other than `fl_chart`.
- ❌ Any UI kit library (e.g., `velocity_x`, `getwidget`) — we build our own shared widgets.

### 2.2 Banned Code Patterns
- ❌ `setState()` inside a screen that uses Riverpod — pick one, always Riverpod.
- ❌ Business logic inside a Widget `build()` method — belongs in a Controller/UseCase.
- ❌ Direct Firestore calls from a screen or widget — must go through a DataSource → Repository.
- ❌ `print()` statements — use the centralized `logger.dart` utility wrapper only.
- ❌ Hardcoded strings inside widgets (prices, labels, routes) — use `app_constants.dart` and `route_names.dart`.
- ❌ Hardcoded colors (`Color(0xFF...)`) in widget files — use `AppColors.*` tokens only.
- ❌ Magic numbers — Every number must be a named constant.
- ❌ `.then()` chaining on Futures — always use `async/await`. It's cleaner and debuggable.
- ❌ Nested `if/else` more than 2 levels deep — refactor with early returns or guard clauses.
- ❌ Fat constructors with more than 5 parameters — use named params + `copyWith`.

---

## 3. 🏗️ ARCHITECTURE RULES — Never Break the Layers

```
Presentation  →  Domain  →  Data
```

- ✅ Screens (Presentation) may only call **Controllers** (Notifiers).
- ✅ Controllers may only call **UseCases** (Domain).
- ✅ UseCases may only call **Repository interfaces** (Domain) — never concrete implementations.
- ✅ Repository implementations (Data) call **DataSources** — remote (Firestore) or local (Hive).
- ❌ A Screen must NEVER import anything from `data/` directly.
- ❌ A UseCase must NEVER import Flutter widgets or `BuildContext`.
- ❌ A Model (DTO) and an Entity are NOT the same thing — never merge them.

---

## 4. 📏 CODE SIZE & QUALITY RULES

### 4.1 File Length
- **Screen files**: Max **300 lines**. If longer, extract sub-widgets into a `widgets/` subfolder inside the feature.
- **Controller files**: Max **150 lines**. If longer, split into multiple notifiers by concern.
- **UseCase files**: Max **60 lines**. A use case does ONE thing.
- **Model/Entity files**: Max **80 lines**.

### 4.2 Method / Function Length
- No function should exceed **40 lines**. Extract helpers aggressively.
- Every function must do exactly **one thing**. If it does two things, split it.

### 4.3 Widget Extraction Rule
- If a widget subtree inside `build()` exceeds **25 lines**, extract it to a private `_SomeWidget` class in the same file or a dedicated file.
- Always prefer `const` constructors for extracted widgets.

### 4.4 No Dead Code
- No commented-out code blocks — use Git to track old versions.
- No unused imports — enforced by `flutter analyze`.
- No unused variables or parameters.

---

## 5. 🧠 STATE MANAGEMENT RULES (Riverpod)

- ✅ Every provider that holds UI state must use `autoDispose`.
- ✅ Use `AsyncNotifier` for async data operations (loading/data/error states).
- ✅ Use `select()` to watch only specific fields — prevents unnecessary rebuilds.
- ✅ All providers must be defined at the **top level** of a file — never inside a class.
- ❌ Never use `ProviderContainer` manually inside widget code.
- ❌ Never use `ref.read()` inside `build()` — only inside callbacks/event handlers.
- ❌ Never store `BuildContext` in a provider or controller.

---

## 6. 🔥 FIRESTORE RULES

- ✅ All Firestore collection paths must be defined as constants in `core/constants/firestore_paths.dart`.
- ✅ Always use `.withConverter<ModelType>()` typed Firestore references — no raw `Map<String, dynamic>` parsing in business logic.
- ✅ Always call `.limit(n)` on list queries to prevent unbounded reads.
- ✅ Use `StreamProvider` for real-time data. Use `FutureProvider` for one-time reads.
- ❌ Never perform Firestore writes from a Widget directly.
- ❌ Never expose raw Firestore `DocumentSnapshot` outside the DataSource layer.
- ❌ No Firestore queries without an index confirmed in `firestore.indexes.json`.

---

## 7. 🚨 ERROR HANDLING RULES

- ✅ Use typed exception classes defined in `core/network/api_exceptions.dart`.
- ✅ Every `async` function in a Controller must be wrapped in `try/catch`.
- ✅ Show user-facing error messages using a centralized `SnackBar` or `ErrorStateWidget` — never raw exception messages.
- ✅ Log every caught exception to Firebase Crashlytics in release builds.
- ✅ Network errors must show a "No internet connection" state, not a blank screen.
- ❌ Never swallow exceptions silently with an empty `catch {}` block.
- ❌ Never show a stack trace to the user under any circumstance.
- ❌ Never use `!` (bang operator) on a nullable unless you have an explicit non-null guarantee — prefer `??` with a safe fallback.

**Standard error handling pattern:**
```dart
// ✅ Correct pattern — always follow this
Future<void> placeOrder(OrderEntity order) async {
  state = const AsyncLoading();
  try {
    await _placeOrderUseCase.execute(order);
    state = const AsyncData(null);
  } on MinimumOrderException catch (e) {
    state = AsyncError(e, StackTrace.current);
  } on NetworkException catch (e) {
    state = AsyncError(e, StackTrace.current);
  } catch (e, st) {
    // Unexpected — log it
    FirebaseCrashlytics.instance.recordError(e, st);
    state = AsyncError(AppException.unknown(), st);
  }
}
```

---

## 8. 🏷️ NAMING CONVENTIONS

| Item | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `product_detail_screen.dart` |
| Classes | `PascalCase` | `ProductDetailScreen` |
| Variables & functions | `camelCase` | `cartTotal`, `placeOrder()` |
| Constants | `camelCase` with `k` prefix | `kMinOrderAmount` |
| Providers | `camelCase` + `Provider` suffix | `cartProvider`, `authStateProvider` |
| Notifiers | `PascalCase` + `Controller` suffix | `CartController`, `AuthController` |
| Entities | `PascalCase` + `Entity` suffix | `ProductEntity`, `OrderEntity` |
| Models (DTOs) | `PascalCase` + `Model` suffix | `ProductModel`, `OrderModel` |
| Use Cases | `PascalCase` + `UseCase` suffix | `PlaceOrderUseCase` |
| Enums | `PascalCase`, values `camelCase` | `OrderStatus.outForDelivery` |
| Route names | `SCREAMING_SNAKE` in constants | `RouteNames.HOME` |

---

## 9. 🎨 UI & WIDGET RULES

- ✅ Use only `AppColors.*` — never raw hex in widget code.
- ✅ Use only `AppTextStyles.*` — never raw `TextStyle(...)` in widget code.
- ✅ Use only spacing constants from `AppSpacing.*` — never raw `SizedBox(height: 16)` everywhere.
- ✅ Every list screen must handle 3 states: **Loading** (shimmer), **Empty** (`EmptyStateWidget`), **Error** (`ErrorStateWidget`).
- ✅ Every async button tap must show a **loading indicator** and be **disabled** during loading.
- ✅ All form fields must use validators from `core/utils/validators.dart`.
- ❌ No `double.infinity` widths inside a `Column` — use `SizedBox.expand()` or `Expanded`.
- ❌ No `Opacity(opacity: 0)` to hide things — use `Visibility` or conditional rendering.
- ❌ Do not hardcode screen heights/widths — use `MediaQuery.sizeOf(context)` or `LayoutBuilder`.

---

## 10. 🔐 BUSINESS RULE ENFORCEMENT — Zero Tolerance

These are client-defined hard constraints. They must **never** be skippable:

| Rule | Where Enforced |
|---|---|
| **Minimum order ₹2,500** | `PlaceOrderUseCase` (throws `MinimumOrderException` if violated) AND `CartScreen` UI (disables checkout CTA with a warning) |
| **Manual approval required** | `GoRouter` redirect guard checks `user.status == "approved"` before allowing access to any home/product route |
| **Admin-only routes** | `GoRouter` guard checks `user.role == "admin"` — unapproved users get redirected immediately |
| **Support contact display** | `PendingApprovalScreen` must always show `+91 98604 60325` and `vishvatejkatkar007@gmail.com` |
| **Delivery charge calculation** | `CheckoutController` must always calculate and display delivery charge before order confirmation |
| **COD / UPI only** | Checkout screen must only offer these two options — no other payment method |

---

## 11. 🤖 BOUNDARIES FOR AI (Agent Rules)

These rules govern what an AI agent may and may not do autonomously during implementation:

### ✅ AI May Do Autonomously
- Implement a feature as described in `PRD.md` and `ARCHITECTURE.md`.
- Refactor code that violates the rules in this file.
- Fix compiler errors, lint warnings, and failing tests.
- Add missing null-safety guards, validators, and error states.
- Write unit tests for any implemented use case or value object.
- Update `agents.md` session log after completing a task.

### ⛔ AI Must NOT Do Without Explicit User Approval
- Add a **new package** to `pubspec.yaml` not listed in Section 1.
- Change the **Firestore data schema** (adding/removing fields from existing collections).
- Modify any **GoRouter route path** — routes are contractual.
- Change **Firebase security rules** logic.
- Delete or rename any **existing file** from the structure.
- Change the **minimum order amount** (`kMinOrderAmount`) value.
- Modify **`firebase_options.dart`** or any environment config.
- Commit or push to Git without being explicitly asked.
- Make any change that affects **more than 3 files** without first presenting a plan.

### ⚠️ AI Must Flag Before Proceeding
- If a requested feature contradicts a rule in this file → **stop and flag it**.
- If implementing a feature requires a new package → **propose it, wait for approval**.
- If unsure about a Firestore schema change → **ask, don't guess**.
- If two approaches exist and they have meaningfully different trade-offs → **present both, let the human decide**.

---

## 12. 📦 GIT & VERSION CONTROL RULES

- ✅ Every commit message must follow: `type(scope): short description`
  - Types: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`
  - Example: `feat(cart): add minimum order validation on checkout`
- ✅ `flutter analyze` must pass with **zero issues** before any commit.
- ✅ `flutter test` must pass with **zero failures** before any commit.
- ❌ Never commit `google-services.json`, `.env`, or any API keys.
- ❌ Never commit generated files (`*.g.dart`, `*.freezed.dart`) — they are in `.gitignore`.
- ❌ Never push directly to `main` — use feature branches.

---

## 13. 🧪 TESTING RULES

- ✅ Every `UseCase` must have a corresponding unit test.
- ✅ Every `Repository` must be tested with mocked DataSources using `mocktail`.
- ✅ Every shared widget must have a widget test covering its core states.
- ✅ The `PlaceOrderUseCase` must have a test that specifically validates the ₹2,500 minimum rule.
- ❌ No test file should use `sleep()` or real timers — use `FakeAsync` or `pump`.
- ❌ Never test implementation details — test **behavior and outcomes**.

---

## 14. 📝 DOCUMENTATION RULES

- ✅ Every public class and method must have a one-line `///` doc comment.
- ✅ Every file must have a top-level comment stating its purpose in 1–2 lines.
- ✅ Complex business logic (e.g., delivery charge formula) must have an inline comment explaining the **why**, not the **what**.
- ❌ Do not write comments that just re-state what the code does:
  ```dart
  // ❌ Bad — obvious from the code
  // Increment counter by 1
  counter++;

  // ✅ Good — explains the why
  // Delivery charge is capped at ₹200 per client agreement (PRD §4.4)
  final charge = min(rawCharge, kMaxDeliveryCharge);
  ```
- ✅ Update `agents.md` at the end of every session with tasks completed.
- ✅ Update `PRD.md` if any feature scope changes.
- ✅ Update `ARCHITECTURE.md` if any new file/folder is added to the structure.

---

## 15. 🏁 DEFINITION OF DONE

A feature is only considered **complete** when ALL of the following are true:

- [ ] Code compiles with zero errors
- [ ] `flutter analyze` shows zero issues
- [ ] All business rules from Section 10 are enforced in the feature
- [ ] All 3 UI states handled: Loading, Empty/Success, Error
- [ ] Unit tests written for all new Use Cases
- [ ] No hardcoded strings, colors, or numbers in widget code
- [ ] Code reviewed against this `rules.md` checklist
- [ ] `agents.md` updated with the session summary

---

> 🔒 *This file is the single source of truth for all development standards on this project. When in doubt — read this file first.*
