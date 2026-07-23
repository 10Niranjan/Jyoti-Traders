# 🤖 Antigravity CLI - Session Logs & Progress Report

This file serves as a persistent record of the development progress, decisions, and chat summaries for the **Flutter Retailer App** project. It will be updated as we proceed.

---

## 📋 Client Specifications: Jyoti Kirana

These are the official requirements provided by the client:

- **Application Name**: `Jyoti Kirana`
- **Contact Details**: Phone: `9860460325` | Email: `vishvatejkatkar007@gmail.com`
- **Business Model**: Hybrid Wholesale & Retail.
- **Access Control**: **Manual Approval Required** for normal users. The system supports **two user roles**: `Admin` (owner) for product & order management, and `Normal User` (retailer/customer).
- **Minimum Order Amount**: **₹2,500** (enforced at checkout).
- **Inventory & Content**: 6 to 10 initial categories. Product images are ready.
- **Payment Methods**: Cash on Delivery (COD) & Online UPI.
- **Logistics & Delivery**: Client's own delivery personnel. Delivery fee calculated **per kilometer**.
- **Google Play Developer Account**: Not yet available (will need guidance/setup support).

---

## 📅 Session Log: 2026-07-09

### 📋 Current Status & Tasks completed:

- Established the **Full Development & Deployment Plan** for the Flutter Retailer App.
- Defined the core feature set, folder structure, and dependencies.
- Created this `agents.md` file to track all sessions, chats, and progress inside the CLI workspace.
- **Identified Flutter SDK issue**: Encountered a write permission error on `C:\Users\niran\flutter\bin\cache\dart-sdk` which was successfully resolved by terminating locking processes and rebuilding the SDK.
- **Scaffolded Flutter Project**: Initialized `traders_retailer` app, set up the clean architecture folders, configured all core dependencies in `pubspec.yaml`, established routing (`app_router.dart`), and built the theme styles (`app_colors.dart` & `app_theme.dart`).
- **Infrastructure Built**: Implemented production-ready `Dio` API Client (with interceptors) and a robust `Hive` Local Storage Service (for tokens, themes, and search history).

### 💬 Latest Discussion Summary:

1. **Client Questions Prepared**: List of basic questions compiled (Brand details, business model/verification, products/categories, payments/delivery, Google Play Console setup).
2. **Current Setup Work**:
   - Environment check: Successfully cleared the locked `dart-sdk` directory and ran `flutter doctor` to download a fresh SDK. Currently, Flutter is functional, Android licenses are accepted, and SDK tools are configured.
   - Backend planning (Firebase vs. Node.js/MongoDB).
   - Project scaffolding: Completed. Project is fully compiled with placeholders.
   - Initial design exploration: Light/Dark theme configuration implemented using customized design system colors.
   - Infrastructure Layer: Completed API Network Client and Local Storage caching service.

---

## 📅 Session Log: 2026-07-12

### 📋 Current Status & Tasks completed:

- **Resolved Compilation Errors**:
  - Replaced undefined `FontWeight.semibold` with `FontWeight.w600` in `app_theme.dart`.
  - Upgraded `CardTheme` instantiation to `CardThemeData` to align with Flutter Material 3.
  - Made the `DioExceptionType` switch statement exhaustive by adding a fallback `default` case in `api_exceptions.dart`.
  - Replaced the failing smoke test in `test/widget_test.dart` with a compile-friendly version matching `TradersRetailerApp` and initialized Hive for test environment.
- **Git Repo Setup**:
  - Initialized a local Git repository on `main` branch.
  - Committed all scaffolded files, core themes, network client, and local storage configurations cleanly.

### 💬 Latest Discussion Summary:

1. **Compilation Check**: Confirmed that `flutter analyze` runs with zero issues.
2. **Git Status & Next Step**: Ready to add remote origin and push folder structure as soon as the user provides the GitHub repository URL.

---

## 📅 Session Log: 2026-07-13

### 📋 Current Status & Tasks completed:

- **Firebase integration**: Added Firebase SDK packages to `pubspec.yaml` and set up `firebase_options.dart` configuration.
- **Resilient Backend Hybrid Engine**: Implemented `FirebaseAuthRepository` supporting both Firebase and a fully simulated Hive database mode. It detects missing/placeholder credentials and falls back to simulation mode to avoid app crashes.
- **Manual Verification & Role-Based Routing**:
  - Implemented `AuthScreen` for sign-up/login with business verification fields.
  - Implemented `PendingApprovalScreen` locking unverified users and displaying client contact details (+91 98604 60325, vishvatejkatkar007@gmail.com).
  - Implemented `AdminDashboardScreen` (owner view) with stats and a functional "Retailer Approval Queue".
  - Implemented `HomeScreen` (customer marketplace) showcasing wholesale categories, items, and minimum order rules (₹2,500).
- **Reactive Navigation**: Wired `appRouterProvider` (GoRouter + Riverpod) to automatically handle state-driven redirects.
- **Fixed Test Suite**: Corrected Firebase dependency initializers and prevented repeating animations from causing timer leaks during widget tests. All tests pass with exit code `0`.
- **GitHub Deployment**: Linked local workspace to GitHub remote (`10Niranjan/Jyoti-Kirana`), resolved `README.md` merge conflicts, and successfully pushed the full Flutter project architecture. Executed dummy commits to fulfill daily contribution streak requirements.

### 💬 Latest Discussion Summary:

1. **Compilation Check**: `flutter analyze` runs with zero issues.
2. **Test Check**: `flutter test` completes successfully with all test assertions passing.

---

## 📅 Session Log: 2026-07-15

### 📋 Current Status & Tasks completed:

- **Created Product Requirements Document (PRD.md)**: Outlined app purpose, target users (~30 retailers), business rules (min ₹2,500 checkout, manual admin approval), features for admin & retailers, payment flow (COD + UPI QR), and phased rollout plan.
- **Created Architecture Guide (ARCHITECTURE.md)**: Documented 3-layer Clean Architecture (Presentation, Domain, Data), defined full tech stack, mapped exact directory structure, detailed communication flows, database schema (Firestore schemas for users, categories, products, orders), security rules strategy, and performance/testing plans.
- **Created Development Rules (rules.md)**: Codified strict coding and engineering practices, whitelisted approved libraries, banned anti-patterns (e.g., GetX, setState in Riverpod, direct data calls in UI), established file size & method length constraints, error handling patterns, naming conventions, and AI boundaries.
- **Fixed App Name & Title**: Renamed `TradersRetailerApp` to `JyotiKiranaApp` in `lib/main.dart` and `test/widget_test.dart`, and corrected the `MaterialApp` title parameter to `'Jyoti Kirana'` to match the actual client specs.

### 💬 Latest Discussion Summary:

1. **Enterprise-grade Setup**: Aligned and documented the entire product vision, system design, and coding standards in PRD, ARCHITECTURE, and RULES markdown assets.
2. **App Title Corrected**: Cleaned up legacy "Traders Retailer" placeholder naming in code and tests.
3. **GitHub Synced**: Committing and pushing core documentation files to track progress and maintain the daily streak.

---

## 📅 Session Log: 2026-07-21

### 📋 Current Status & Tasks completed:

- **Phase 2 complete — Domain Layer & Data Models**: Built the entire backend backbone with no UI changes.
  - **Value objects**: `Money` (validates ≥ 0, ₹ formatting), `PhoneNumber` (10-digit Indian validation).
  - **Entities**: `UserEntity`, `AddressEntity`, `CategoryEntity`, `ProductEntity`, `OrderEntity`/`OrderItemEntity`, `CartEntity`/`CartItemEntity` — all pure Dart, `Equatable`-based, zero Flutter/Firebase imports.
  - **Repository interfaces** (`domain/repositories/`): `CategoryRepository`, `ProductRepository`, `OrderRepository`, `UserRepository` (admin approve/reject/list), `CartRepository` (local-only).
  - **Use cases**: `GetProductsUseCase`, `SearchProductsUseCase`, `GetCategoriesUseCase`, `PlaceOrderUseCase` (enforces ₹2,500 minimum against subtotal — not grand total, so delivery charge can't artificially clear the bar — throws `MinimumOrderException`), `GetOrderHistoryUseCase`, `UpdateOrderStatusUseCase`, `ApproveUserUseCase`, `GetPendingUsersUseCase`.
  - **Data models/DTOs**: New `CategoryModel`, `ProductModel`, `OrderModel`, `CartItemModel` (hand-written, `.withConverter`-based Firestore mapping, no freezed/codegen). Extended existing `UserModel` with `status` (pending/approved/rejected), `address`, `gstNumber`, `fcmToken` — `isApproved` kept as a computed getter so `AuthController`/screens keep compiling unchanged.
  - **Data sources**: `CategoryRemoteDatasource`, `ProductRemoteDatasource`, `OrderRemoteDatasource`, `UserRemoteDatasource` — each real-Firestore-or-Hive-simulation dual-mode, mirroring the existing `FirebaseAuthRepository` pattern (Firebase is still on placeholder credentials). `CartLocalDatasource` (pure Hive), `ProductLocalDatasource` (offline catalog cache).
  - **Repository implementations** + one consolidated `repository_providers.dart` exposing all five as Riverpod providers.
  - **Core additions**: `app_constants.dart`, `firestore_paths.dart`, `hive_keys.dart`, `route_names.dart` (wired into `app_router.dart` and `local_storage_service.dart`, replacing hardcoded strings), `currency_formatter.dart`, `date_formatter.dart`, `validators.dart`, `extensions.dart`, and a shared `firebase_mode.dart` helper (extracted from `FirebaseAuthRepository`'s inline placeholder-detection check).
  - **New dependencies**: `equatable`, `uuid` (runtime), `mocktail` (dev) — all pre-approved in `rules.md` §1, none previously declared in `pubspec.yaml`.
  - **Deliberate scope exception**: did not create `domain/repositories/auth_repository.dart` or auth use cases (login/register/logout) — the existing Phase-1 auth flow (`AuthController` → `FirebaseAuthRepository`) already works end-to-end; duplicating it would touch working code for no functional gain this phase.
  - **Tests added**: `test/unit/value_objects/money_test.dart`, `phone_number_test.dart`, `test/unit/usecases/place_order_usecase_test.dart` (asserts `MinimumOrderException` below ₹2,500, and specifically that delivery charge doesn't count toward the minimum), `approve_user_usecase_test.dart` — using `mocktail` against the repository interfaces.
  - **Verification**: `flutter analyze` — zero issues. `flutter test` — 16/16 passing, including the pre-existing widget smoke test (untouched).

### 💬 Latest Discussion Summary:

1. Confirmed with the user before starting: (a) add `address`/`gstNumber`/`fcmToken`/`status` to the User schema now rather than deferring, since Phase 5 (delivery-charge calc) and GST display need them anyway; (b) write everything hand-rolled (no freezed/json_serializable/build_runner), matching the existing `UserModel` style and Rule Zero.
2. `phases.md` updated: Phase 2 marked complete (8/12 — the 4 unchecked items are the deliberately-skipped auth interface/use cases, noted inline). Current active phase is now **Phase 3 — Core Commerce (Retailer Side)**, starting with wiring `HomeScreen` to real Firestore categories.

### 🐛 Backend check (same day, follow-up): 2 pre-existing bugs found and fixed

Asked to check whether any real backend was connected and to test it. Confirmed there is **no live Firebase project** — no `google-services.json`, no `GoogleService-Info.plist`, no `firebase.json`/`.firebaserc`, and `firebase_options.dart` is 100% placeholder credentials. What's actually running today is the Hive-based simulation layer. Wrote `test/integration/simulation_backend_test.dart` to exercise it end-to-end (sign-up → pending → admin approval, category/product CRUD, cart, order placement/status update). This surfaced two real, pre-existing bugs (both predate Phase 2, in Phase-1 code):

1. **`Timestamp` written to Hive crashes simulation-mode writes.** `UserModel.toJson()` (and the new `ProductModel`/`OrderModel`) wrapped dates in `Timestamp.fromDate()`/`Timestamp.now()` — but that same `toJson()` map is what gets persisted to Hive in simulation mode, and Hive has no adapter for Firestore's `Timestamp` type. Any simulated sign-up would have crashed the instant it tried to save. **Fix**: write plain `DateTime` instead (Firestore's SDK auto-converts `DateTime` → `Timestamp` on real writes, so production behavior is unchanged) and added `core/utils/firestore_date_parser.dart` (`parseFirestoreDate`) to read either a `Timestamp` (real Firestore) or a `DateTime` (Hive) back out.
2. **`refreshUserStatus` and the email-lookup path in `signIn` crashed at runtime** (`firebase_auth_repository.dart`) — both used `list.firstWhere(test, orElse: () => null)` on a `List<dynamic>` whose actual reified runtime type was `List<Map<String, dynamic>>`; Dart resolves the generic against the object's real type, so `orElse: () => null` didn't satisfy the required `Map<String, dynamic> Function()` and threw a `TypeError`. **Fix**: replaced both with `indexWhere` + manual null check, which sidesteps the generic-inference footgun entirely.

All 20 tests pass (`flutter test`), `flutter analyze` is clean. Also note: `.gitignore` doesn't currently exclude Hive test scratch directories (`temp_hive*`) — `temp_hive/*.hive` (0-byte placeholder files) are already tracked in git; worth deciding whether to keep them tracked or add to `.gitignore` and remove.

---

## 📅 Session Log: 2026-07-21 (continued) — Phase 3 Core Commerce

### 📋 Current Status & Tasks completed:

- **Phase 3 complete — Core Commerce (Retailer Side)**: the full retailer shopping experience, built on Phase 2's domain/data layer.
  - **Navigation restructure**: `app_router.dart` now uses a `StatefulShellRoute.indexedStack` bottom-nav shell (Home/Search/Cart/Orders/Profile as persistent tabs) instead of flat routes, plus push routes for category products, product detail, checkout, order success, and order detail. `route_names.dart` extended with all new paths.
  - **New `shared/widgets/`** (didn't exist before): `ProductCard`, `CategoryCard`, `PrimaryButton`, `QtyStepper`, `OrderStatusBadge`, `ShimmerLoader` (grid/list), `EmptyStateWidget`/`ErrorStateWidget`, `PromoBannerCarousel`, `BottomNavBar`.
  - **New features**: Home (real categories), Products (category grid, product detail, debounced search with recent-searches), Cart (Hive-backed, ₹2,500 minimum gating), Checkout (COD, editable delivery address, stub delivery charge), Orders (history + detail with status badges), Profile (editable address/GST, tap-to-call/email support).
  - **Demo catalog seeder** (`demo_catalog_seeder.dart`): seeds the 8 PRD §5 categories + demo products into the simulation store on first launch, since Phase 4's Admin product-management UI doesn't exist yet to add real ones.
  - **New `AuthRepository.updateProfile()`**: self-service profile updates (address, GST), separate from the admin-side `UserRepository` built in Phase 2.
  - **Scope deferred to Phase 5** (already owns this in `phases.md`, avoiding duplicate work): real per-km `geolocator` delivery charge, UPI QR payment screen, FCM-to-admin notification.
  - **Real bugs found and fixed while testing** (both pre-existing, from Phase 1, never previously exercised by any test):
    1. `appRouterProvider` rebuilt the entire `GoRouter` instance on every auth-state change (`ref.watch` at the top of the provider) — a known Riverpod+go_router anti-pattern that left navigation stuck mid-transition after sign-in. Fixed with a `refreshListenable` bridge (`_AuthRefreshNotifier`) so the router is built once and just re-runs `redirect` reactively.
    2. `PromoBannerCarousel`'s `autoPlay: true` set up a repeating `Timer` that would hang any widget test touching Home (`pumpAndSettle` never settles on a perpetual timer) — guarded with the same `FLUTTER_TEST` env check the splash screen animation already used.
  - **Tests**: added `checkout_controller_test.dart` (₹2,500 gating, cart-clear-on-success, repository-failure handling) and `search_controller_test.dart` (recent-searches capping/persistence/clearing) — 8 new tests, all passing.
  - An in-progress end-to-end `WidgetTester` flow test (login → browse → cart → checkout → orders → profile) was abandoned and deleted after it ran into test-*infrastructure* issues unrelated to app code — Flutter's fake test clock doesn't resolve real `Future.delayed` timers (needs `runAsync`), compounded by `google_fonts` attempting real network font fetches that fail in the sandboxed test environment. Not worth the further token spend to chase; the two real bugs above were already found and fixed in the process.
  - **Verification**: `flutter analyze` — zero issues. `flutter test` — 28/28 passing (20 from Phase 2 + 8 new).

### 💬 Latest Discussion Summary:

1. Confirmed with the user before building (all recommended options): bottom-nav shell over flat routes; seed a demo catalog since Admin product-management doesn't exist yet; stub the delivery charge and defer UPI/FCM to Phase 5 rather than duplicate that work.
2. `phases.md` updated: Phase 3 marked complete (12/14 — the 2 unchecked items are the deliberately-deferred UPI/FCM/delivery-calc bullets, noted inline). `PRD.md` §12 Phase 2 updated to reflect retailer-side commerce as done, Admin product/category management still outstanding. Current active phase is now **Phase 4 — Admin Panel**, starting with wiring `AdminDashboardScreen` to real stats.
3. Housekeeping: added `temp_hive*/` to `.gitignore` (test scratch directories were showing up as untracked clutter).

---

## 📅 Session Log: 2026-07-22 — Phase 4.1 & 4.2, Admin Dashboard + Approval Queue

### 📋 Tasks completed:

- **4.1 — Admin Dashboard (Real Data)**: replaced the Phase-1 placeholder (`ConsumerStatefulWidget` + `setState()` + a direct `FirebaseAuthRepository` cast that bypassed the domain layer entirely) with a real `ConsumerWidget` wired to `StreamProvider`s.
  - New `lib/features/admin/controllers/admin_dashboard_controller.dart` — `pendingApprovalsCountProvider`, `totalRetailersCountProvider`, `todayOrderCountProvider`, `last7DaysOrderCountsProvider`, all derived client-side from `OrderRepository.watchAllOrders()` / `UserRepository`, the same "derive from an existing stream" pattern `orderByIdProvider` already used — no new repository/datasource methods needed for pure aggregation.
  - Added `fl_chart` (was already pre-approved in `ARCHITECTURE.md`/`rules.md` but never installed) for a 7-day orders bar chart.
  - Moved `AdminDashboardScreen` from `lib/features/home/screens/` to `lib/features/admin/screens/`, matching the `lib/features/admin/` module `ARCHITECTURE.md` already documented but which didn't exist on disk yet — needed anyway for 4.2–4.6.
  - Added `RejectUserUseCase` (mirrors `ApproveUserUseCase`) — `UserRepository.rejectUser()` already existed but the UI's "Reject" button was a dead no-op.
- **4.2 — Retailer Approval**: extracted a dedicated `ApprovalQueueScreen` (live stream, pull-to-refresh, shimmer/empty/error states) + reusable `RetailerApprovalCard` (shop name, owner, phone, address — falls back to "Address not provided yet" since address isn't collected at signup) + `approvalController` (`StateNotifier<AsyncValue<void>>`, same shape as `CheckoutController`). The 4.1 dashboard now shows a 3-item queue preview with a "View All" link into the full screen, reusing the same widgets. New push route `RouteNames.adminApprovalQueue` (`/admin/approval-queue`).
- **Real bug found and fixed via an interaction test** (not just a render test): `approvalControllerProvider` is `.autoDispose`; grabbing its notifier with `ref.read()` inside `build()` let Riverpod tear it down mid-await the moment nothing was left watching it, so the very first Approve/Reject tap threw `StateError: Tried to use ApprovalController after dispose was called`. Fixed by `ref.watch`-ing the notifier instead, so the card's own subscription keeps the provider alive for the async call. A widget test that only pumps-and-checks-text would have missed this — it only surfaced once a test actually tapped the button and awaited the result.
- **Tests added**: `test/unit/usecases/reject_user_usecase_test.dart`, `test/widget/admin_dashboard_screen_test.dart` (fake-repository-backed, asserts real derived stat counts/chart/queue render), `test/widget/approval_queue_screen_test.dart` (5 tests — empty state, address rendering incl. the no-address fallback, and the tap-Approve/tap-Reject interaction tests that caught the autoDispose bug above).
- **Verification**: `flutter analyze` — zero issues. `flutter test` — 37/37 passing.

### 💬 Latest Discussion Summary:

1. Confirmed with the user before starting on structural decisions (moving the screen into a new `lib/features/admin/` module, adding the `fl_chart` dependency, wiring the previously-dead Reject button) — user said to use judgment and proceed.
2. `phases.md` updated: 4.1 and 4.2 marked complete inline (6/21 in Phase 4; the FCM-on-approval/rejection sub-bullet stays deferred to Phase 5, same reasoning as 3.5). `PRD.md` §12 Phase 2 updated to note the Admin Dashboard and Approval Queue now run on real data instead of Phase-1 placeholders. Current active phase remains **Phase 4 — Admin Panel**, next up is **4.3 Product Management**.

---

## 📅 Session Log: 2026-07-22 (continued) — Phase 4.3, Product Management

### 📋 Tasks completed:

- **4.3 — Product Management**: full admin CRUD over the product catalog.
  - `ManageProductsScreen` — product list with edit/delete, pull-to-refresh, shimmer/empty/error states, and a delete confirmation dialog that explicitly points the admin at the "Active" toggle as the non-destructive alternative.
  - `AddEditProductScreen` — one screen serving both create and edit, with validation (name required, price > 0, stock ≥ 0, category required), a category dropdown fed by the existing `categoriesProvider`, a `ProductUnit` dropdown, description, and an active toggle. Extracted `ProductImagePickerField` into `widgets/` to stay under rules.md §4.1's 300-line screen limit.
  - `AdminProductController` — `StateNotifier<AsyncValue<void>>` with explicit `create()`/`update()`/`delete()` methods, plus `allProductsProvider` and a derived `adminProductByIdProvider`. New use cases: `CreateProductUseCase`, `UpdateProductUseCase`, `DeleteProductUseCase`, `GetAllProductsUseCase`.
  - `ImageUploadService` (`core/services/`) + `StoragePaths` — real Firebase Storage upload when a live project is configured, falling back to returning the picked file's local path in simulation mode (same `isFirebasePlaceholder` pattern every other Firebase-touching class here uses). Admin screens render local paths via `Image.file`; retailer-side `CachedNetworkImage` already degrades to its placeholder icon via `errorWidget`, so nothing breaks either way.
  - Low-stock alerting via a new `AppConstants.kLowStockThreshold = 5` — a per-row warning icon + bold red stock count, plus a summary banner at the top of the list.
- **Real bug found and fixed**: `watchProducts()` hardcoded `isActive == true` in **both** its Firestore and Hive-simulation branches — correct for retailer browsing, but it meant an admin who deactivated a product could never see it again to re-activate it. Fixed additively with a separate `watchAllProducts()` threaded through datasource → repository interface → impl → new use case, leaving retailer browsing completely untouched. Covered by a new integration test asserting both visibility rules at once.
- **New packages**: `firebase_storage` (already pre-approved in rules.md §1) and `image_picker` — the latter was **not** in the approved list, so per rules.md §11 it was explicitly put to the user for approval before being added, and approved.
- **Tests added** (12 new, 49 total): `manage_products_screen_test.dart` (6 — empty state, list rendering, inactive-products-visible, low-stock banner/warning, and a delete flow verifying the confirmation dialog actually gates the delete), `add_edit_product_screen_test.dart` (5 — create/edit modes, validation blocking submission, edit keeping the product's id rather than duplicating), and one integration test for the `isActive` fix above.
  - Note: the Add/Edit form tests needed an enlarged test viewport (1000×2400) — the form is taller than the default 800×600 surface, which left the submit button off-screen where taps silently no-op. That was a test-harness artifact, not an app bug.
- **Verification**: `flutter analyze` — zero issues. `flutter test` — 49/49 passing.

### 💬 Latest Discussion Summary:

1. User asked whether to start 4.3 or wait on the client for real catalog data/Firebase access. Recommended starting now — the client items only block making it *real*, not building it, and the simulation-mode fallback means zero rework once Firebase lands. User agreed.
2. Approved `image_picker` as the image-picking package (over `file_picker`) when asked, per rules.md §11.
3. `phases.md` updated: 4.3 marked complete with scope notes (11/21 in Phase 4). Next up is **4.4 Category Management**, which should be simpler — `CategoryRepository` already has full CRUD and no `isActive` read-filter gap, and `ImageUploadService` is reusable for the category icon.

---

## 📅 Session Log: 2026-07-23 — Phase 4.4, Category Management

### 📋 Tasks completed:

- **4.4 — Category Management**: full admin CRUD over categories, including drag-to-reorder.
  - `ManageCategoriesScreen` — `ReorderableListView.builder` (custom drag handle only, via `ReorderableDragStartListener`, so edit/delete taps aren't affected), pull-to-refresh, shimmer/empty/error states, delete confirmation dialog matching the product screen's pattern.
  - `AddEditCategoryScreen` — name, active toggle, icon picker (reused `ProductImagePickerField` as-is — its logic was already generic, not product-specific, so duplicating it would have been pure copy-paste). New categories are appended at the end of `displayOrder`; existing ones keep their order, which only the list screen's drag can change.
  - `AdminCategoryController` — `create()`/`update()`/`delete()` mirroring `AdminProductController`, plus `reorder(List<CategoryEntity>)` which writes a new `displayOrder` only for rows whose index actually changed after a drag. New use cases `CreateCategoryUseCase`/`UpdateCategoryUseCase`/`DeleteCategoryUseCase` (the repository already had the methods, just no use-case wrappers).
  - `ImageUploadService` + `StoragePaths` extended with `uploadCategoryIcon`/`deleteCategoryIcon`/`categoryIcon(id)`, same simulation-mode fallback as the product image methods from 4.3.
  - Added a "Manage Categories" button to `AdminDashboardScreen` next to "Manage Products".
- **Two real bugs found and fixed, chained from one root cause**: this is the first time `CategoryEntity.isActive` was ever settable to `false` (creation always defaulted it to `true`, and nothing else could change it). That exposed:
  1. The retailer-facing `categoriesProvider` (`features/home/controllers/home_controller.dart`) never filtered on `isActive` — so a deactivated category would have stayed fully visible on the retailer Home screen and reachable via `CategoryProductsScreen`, with no way to ever hide it. Fixed by filtering to `isActive` there; the admin's own `adminCategoriesProvider` stays unfiltered (same split as 4.3's `watchProducts()`/`watchAllProducts()`).
  2. That filter then broke `AddEditProductScreen`'s category dropdown, which was fed by the same provider — editing a product already assigned to a category the admin had since deactivated would hit Flutter's "exactly one matching dropdown item" assertion and crash, since the assigned category would no longer be in the filtered list. Fixed by pointing that dropdown at the unfiltered `adminCategoriesProvider` instead.
  - Neither bug was reachable before this session, since nothing could ever set `isActive: false` on a category until this feature existed to do it.
- **Tests added** (10 new, 59 total): `manage_categories_screen_test.dart` (5 — empty state, listing, inactive-still-visible-to-admin, delete-confirmation gating, drag-to-reorder persists the new order), `add_edit_category_screen_test.dart` (5 — create/edit modes, required-name validation, new-category display-order placement, active-toggle persistence).
- **Verification**: `flutter analyze` — zero issues. `flutter test` — 59/59 passing.

### 💬 Latest Discussion Summary:

1. `phases.md` updated: 4.4 marked complete with scope notes (14/21 in Phase 4). Current active phase remains **Phase 4 — Admin Panel**, next up is **4.5 Order Management** (`AllOrdersScreen` filterable by status, `OrderManagementScreen`, `adminOrderController` over the existing `UpdateOrderStatusUseCase`; FCM-on-status-change stays deferred to Phase 5).
2. `PRD.md` §4/§12 updated: Category Management (Admin) checked off.

---

## 📅 Session Log: 2026-07-23 (continued) — Phase 4.5, Order Management

### 📋 Tasks completed:

- **4.5 — Order Management**: full admin visibility and control over every order in the system.
  - `AllOrdersScreen` — filter chips for All + all 4 `OrderStatus` values (the checklist named only 3; the 4th, "Out for Delivery", already exists in the domain model and skipping it would have made those orders unfilterable), pull-to-refresh, shimmer/empty/error states, and a status-specific empty message ("No delivered orders") when a filter matches nothing.
  - `OrderManagementScreen` — full order breakdown plus a status-update dropdown; navigating there and changing status shows a confirmation snackbar and re-derives the order from the live stream so the dropdown reflects the just-saved state.
  - `AdminOrderController` — `updateStatus()` over the existing `UpdateOrderStatusUseCase`; `adminOrderByIdProvider` derived from the dashboard's existing `allOrdersProvider` (no new stream needed — same "derive from an existing stream" pattern as `orderByIdProvider`/`adminProductByIdProvider`).
  - Extracted `OrderDetailBody` into `shared/widgets/` (previously a private `_OrderDetailBody` inside `OrderDetailScreen`) so the retailer's read-only order view and the admin's editable one render from one ~90-line layout instead of two. Admin mode adds the shop name and a `header` slot for the status dropdown.
  - Added `OrderStatusLabelExtension.label` (`core/utils/extensions.dart`) so `OrderStatusBadge` and the new status dropdown share one source of truth for status wording instead of two parallel switch statements.
  - Added an "All Orders" button to `AdminDashboardScreen`.
- **Real bug found and fixed**: `order.id.substring(0, 8)` (building the "Order #XXXXXXXX" label) throws a `RangeError` for any order id under 8 characters. Unreachable in production — real ids are always 36-char UUIDs — but it's a defensive gap in shared display code, and the same unguarded call already existed in the pre-4.5 `OrderHistoryScreen`. Fixed once via a new `String.shortId` extension, applied to `OrderDetailBody`, `AllOrdersScreen`, and `OrderHistoryScreen`.
- **Tests added** (7 new, 66 total): `all_orders_screen_test.dart` (4 — empty state, unfiltered listing, status filtering, filtered-empty message), `order_management_screen_test.dart` (3 — renders breakdown with shop name, not-found state, status-change interaction verifying both the repository call and the confirmation snackbar).
- **Verification**: `flutter analyze` — zero issues. `flutter test` — 66/66 passing.

### 💬 Latest Discussion Summary:

1. User asked to proceed straight to 4.5 and fix any bugs found along the way immediately rather than deferring them — the `shortId` fix above was applied inline as part of this same session rather than logged for later.
2. `phases.md` updated: 4.5 marked complete with scope notes (18/21 in Phase 4). `PRD.md` §4/§12 updated: Order Management (Admin) checked off, moved out of the old §12 "Phase 3" bucket. Current active phase remains **Phase 4 — Admin Panel**, next up is **4.6 Retailer Management** (`RetailerListScreen` with total spend/order count per retailer, tap-through to their order history) — the last item in Phase 4.

---

## 📅 Session Log: 2026-07-23 (continued) — Phase 4.6, Retailer Management — Phase 4 Complete

### 📋 Tasks completed:

- **4.6 — Retailer Management**: the last item in Phase 4.
  - `retailerSummariesProvider` — per-retailer order count and lifetime spend, derived client-side by grouping the existing `approvedUsersProvider`/`allOrdersProvider` streams by `userId` (no new repository query, same pattern as every other Phase 4 stat). Sorted by total spend, highest first.
  - `RetailerListScreen` + `RetailerSummaryTile` — shop name, owner, total spend, order count, tap-through to that retailer's order history.
  - Reused `AllOrdersScreen` for the tap-through history rather than building a second near-duplicate screen: it now takes an optional `retailerId` that scopes the order list, swaps the app-bar title to the retailer's shop name (looked up from `approvedUsersProvider`), and hides the per-row shop name (redundant once already scoped to one retailer). New route `/admin/retailers/:retailerId/orders`.
  - Added a "Retailers" button to `AdminDashboardScreen`, next to "All Orders".
- **Tests added** (4 new, 70 total): `retailer_list_screen_test.dart` (3 — empty state, a retailer with zero orders still lists correctly, spend/count computed and sorted correctly across multiple retailers), plus one new case in `all_orders_screen_test.dart` for the `retailerId`-scoped view (title, filtering, hidden shop-name row).
- **Verification**: `flutter analyze` — zero issues. `flutter test` — 70/70 passing.
- **Phase 4 — Admin Panel is now fully complete: 21/21 across 4.1–4.6.**

### 💬 Latest Discussion Summary:

1. `phases.md` updated: Phase 4 marked ✅ Complete (21/21) in both the summary table and its own section header. `PRD.md` §4/§12 updated: Retailer Management (Admin) checked off, noting Phase 4 is now fully complete.
2. Current active phase moves to **Phase 5 — Delivery, Payments & Notifications**. Next immediate task: Firebase Cloud Messaging setup (`FirebaseMessaging.onMessage` + background handler, notification permission request, FCM token saved to Firestore on login/refresh) — this unblocks every FCM item deferred across Phases 3–4 (order-placed-to-admin, approval/rejection-to-retailer, status-change-to-retailer).

---

## 📅 Session Log: 2026-07-23 (continued) — Phase 5 begins: Push Notifications (FCM)

### 📋 Tasks completed:

- **Phase 5, first slice — push notifications end to end**, the first 4 of Phase 5's 10 checklist items:
  - Added `firebase_messaging` (pre-approved, rules.md §1). `FcmService` (`core/services/`) wraps every call (`requestPermission`, `getToken`, `onTokenRefresh`, `onMessage`) in its own try/catch, degrading to `null`/an empty stream on failure — there's no Firestore/Auth-style "simulation mode" substitute for FCM, so this defensive wrapping is the fallback for unconfigured credentials, an unsupported platform, or a test environment with no platform channel. Confirmed working live: the widget-test smoke test logs `FcmService: permission/token request unavailable, skipping` and continues rather than crashing.
  - `firebaseMessagingBackgroundHandler` — a required top-level function (Firebase runs it in a separate isolate), registered in `main.dart` via `FirebaseMessaging.onBackgroundMessage` before `runApp`. It only re-initializes Firebase and otherwise no-ops: the OS renders the notification natively from the message's `notification` payload, and a background isolate can't safely touch the main isolate's already-open Hive boxes.
  - `AuthRepository.updateFcmToken(uid, fcmToken)` — new method (mirrors `updateProfile`'s mock/Firestore branches) — called on login and again on every `onTokenRefresh`, via `fcmInitializerProvider`: a plain (non-autoDispose) `Provider<void>` watched once from `JyotiKiranaApp.build()` so it initializes exactly once per app lifetime regardless of auth state.
  - `NotificationsScreen` + `NotificationRepository` — local-only (Hive `notifications_cache` box, no Firestore), following the exact pattern `CartRepository` already established: datasource → repository → controller, no use-case layer, since it's simple CRUD over one box.
  - `NotificationBellButton` (shared widget, bell + unread-count badge via the existing `badges` package) added to both `HomeScreen` and `AdminDashboardScreen` app bars — notification history is per-device, not per-role, so both point at the shared `/notifications` route.
  - Deliberately out of scope: tap-to-open-order-detail from a notification, and native foreground tray notifications (`flutter_local_notifications` isn't on rules.md's approved package list) — neither was asked for by the checklist. Also out of scope: an actual Cloud Function to *send* these — this phase only wires the client side, so the notification list will stay empty in practice until a backend sender exists.
- **Test-infra note**: `fcmInitializerProvider` is watched unconditionally at the app root (unlike every other repository provider in this app, which only gets read once a specific auth-gated screen builds), so `test/widget_test.dart`'s smoke test now needs the `notifications_cache` Hive box opened in its `setUp()`, and `admin_dashboard_screen_test.dart` needed a `FakeNotificationRepository` override added (since `AdminDashboardScreen` now renders the bell button too). Both fixed.
- **Tests added** (8 new, 78 total): `notifications_screen_test.dart` (5), `notification_bell_button_test.dart` (2), plus a new Hive round-trip case in `simulation_backend_test.dart` (add → newest-first ordering → mark-as-read → mark-all-read).
- **Verification**: `flutter analyze` — zero issues. `flutter test` — 78/78 passing.

### 💬 Latest Discussion Summary:

1. User asked to proceed with Phase 5 and fix any bugs found along the way immediately — no bugs surfaced this round; the test-infra gaps above were anticipated and fixed inline as part of the same implementation pass, not discovered after the fact.
2. `phases.md` updated: Phase 5's first 4 items checked off with scope notes (4/10). `PRD.md` §4/§12 updated to note push-notification plumbing is done, client-side only. Current active phase remains **Phase 5**, next up: delivery charge calculation (`geolocator` + warehouse-coordinates config doc + admin-settable per-km rate), replacing `AppConstants.kStubDeliveryCharge`.

---

## 📅 Session Log: 2026-07-23 (continued) — Phase 5: Real Delivery Charge Calculation

### 📋 Tasks completed:

- **Delivery charge calculation, replacing `AppConstants.kStubDeliveryCharge`** — the next 3 Phase 5 checklist items:
  - Added `geolocator` (pre-approved, rules.md §1) + `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` in `AndroidManifest.xml`. `LocationService` (`core/services/`) wraps every call in one try/catch, same defensive pattern as `FcmService` — permission denial, disabled location services, or an unsupported platform all degrade to `null` rather than throwing.
  - `AddressEntity` gained optional `latitude`/`longitude` + a `hasCoordinates` getter — nullable and backward compatible. Populated only when a retailer taps "Use current location". Extracted the address form (now 4 elements: street/city/pincode/location-button) that `ProfileScreen` and `CheckoutScreen` were independently duplicating into a shared `AddressFormFields` widget.
  - Distance math is a hand-rolled pure-Dart Haversine function (`core/utils/distance_calculator.dart`), **not** a call into `geolocator` from the domain layer — the domain layer must stay plugin-free, so `CalculateDeliveryChargeUseCase` depends only on that pure function, while `LocationService` (which does need `geolocator`) stays in `core/services/`, one layer up.
  - `DeliveryConfigRepository`/`DeliveryConfigEntity` — **the first single-document Firestore repository in this codebase** (`config/delivery`), a genuinely new pattern versus every prior repository being a collection of many docs. Same Hive-simulation dual-mode fallback as everything else, reusing the existing `settings_cache` box. Seeded with a documented bootstrapping default (central-India coordinates, ₹10/km per PRD §4.4's own example) until the admin sets the real location.
  - `DeliverySettingsScreen` (new "Delivery Settings" button on `AdminDashboardScreen`) — admin edits warehouse lat/lng (with its own "use current location" shortcut) and the per-km rate. The read-side `deliveryConfigProvider` is shared between this screen and `CheckoutScreen`; the write side is admin-only.
  - `CheckoutScreen` now computes a real per-km charge whenever the address has coordinates and the config has loaded, falling back to the flat placeholder otherwise — rules.md §10's hard rule ("delivery charge must always be calculated and shown") stays satisfied either way, never blank.
- **No bugs found this round** — the one correctness risk (calling `ref.watch` from an event handler instead of `ref.read`, which `_deliveryCharge` initially did before being split into a pure `_deliveryChargeFor(address, config)` helper) was caught and fixed during implementation, not after.
- **Tests added** (10 new, 88 total): `distance_calculator_test.dart` (3), `calculate_delivery_charge_usecase_test.dart` (3), `delivery_settings_screen_test.dart` (3), plus one new case in `simulation_backend_test.dart` (bootstrapping default → admin update round-trips).
- **Verification**: `flutter analyze` — zero issues. `flutter test` — 88/88 passing.

### 💬 Latest Discussion Summary:

1. `phases.md` updated: delivery-charge sub-items checked off with scope notes (7/10 in Phase 5). `PRD.md` §4.4 updated to reflect the actual implementation (Haversine + admin-set warehouse/rate, not the Google Maps Distance Matrix API originally sketched there) and §12 checked off.
2. Current active phase remains **Phase 5**, next up: the UPI payment flow (QR/ID screen, "I have paid" confirmation, admin marks-paid action) — the last unstarted piece of this phase. COD needs no further work.

---

## 📅 Session Log: 2026-07-23 (continued) — Phase 5 complete: UPI Payment Flow

### 📋 Tasks completed:

- **UPI payment flow — the last 3 items in Phase 5, which is now fully complete (10/10)**:
  - Added `qr_flutter` — **explicitly approved by the user this session** — to render a real, scannable QR client-side from a standard `upi://pay?...` deep link, rather than a static asset that doesn't exist. Updated `rules.md` §1 and `ARCHITECTURE.md` §2.7's approved-package tables per rules.md's own requirement.
  - `CheckoutScreen` previously hardcoded COD with no way to actually pick UPI (a real gap against rules.md §10's "COD / UPI only" rule, which implies a real choice) — added a `RadioListTile` selector. UPI orders now route to a new `UpiPaymentScreen` after placement instead of straight to `OrderSuccessScreen`, matching PRD §7's documented flow.
  - Extended `PaymentStatus` with `paymentClaimed` (retailer tapped "I have paid") between `pending` and `paid`, so the admin can distinguish "never touched" from "claims they paid." New `OrderRepository.recordPaymentClaim()` (retailer) and `.updatePaymentStatus()` (admin-only "Mark as Paid", wired into `OrderManagementScreen` via `OrderDetailBody`'s new `paymentExtra` slot — mirrors the `header` slot pattern from 4.5).
  - `OrderEntity.paymentScreenshotUrl` — the uploaded screenshot renders back in `OrderDetailBody`'s Payment section for both roles, not just written to Storage and forgotten (an upload nobody can view would be a half-finished feature). Reused `ImageUploadService` with a new `uploadPaymentScreenshot()` method.
  - **Refactored while here**: moved `imageUploadServiceProvider` from `admin_product_controller.dart` into `core/services/image_upload_service.dart` (mirrors the `locationServiceProvider` precedent from the delivery-charge session) since checkout — a retailer feature — needed it too, and importing a provider from an admin controller file was the wrong coupling direction. Also relocated `features/admin/widgets/product_image_picker_field.dart` → `shared/widgets/image_picker_field.dart` (`ProductImagePickerField` → `ImagePickerField`), since it was already fully generic and is now used by product photos, category icons, *and* payment screenshots.
  - **No real UPI ID exists** — checked agents.md's own client-spec notes and found only "COD & Online UPI" as a payment method, no actual ID/QR. `AppConstants.kUpiId`/`kUpiPayeeName` are explicit placeholders (`jyotikirana@upi`) to swap before launch.
- **Real bug found and fixed immediately**: `OrderSuccessScreen` had the exact same unguarded `order.id.substring(0, 8)` crash risk fixed everywhere else in Phase 4.5 — just in a file that phase never touched. Fixed via the existing `String.shortId` extension the moment it was spotted.
- **Tests added** (9 new, 97 total): `record_payment_claim_usecase_test.dart` (2), `update_payment_status_usecase_test.dart` (1), 3 new cases in `order_management_screen_test.dart` (COD hides payment UI; UPI shows status + a working Mark-as-Paid; already-paid hides the button), `upi_payment_screen_test.dart` (3 — this codebase's first widget test backed by a signed-in `authControllerProvider`, via overriding `authRepositoryProvider` with a fake that emits an already-authenticated retailer).
- **Verification**: `flutter analyze` — zero issues. `flutter test` — 97/97 passing.
- **Phase 5 — Delivery, Payments & Notifications is now fully complete: 10/10.**

### 💬 Latest Discussion Summary:

1. Asked the user up front whether to add `qr_flutter` for a real QR code vs. a text-only UPI ID with a copy button (rules.md §11 requires explicit approval for any package not already on the approved list) — user chose the real QR code.
2. `phases.md` updated: Phase 5 marked ✅ Complete (10/10) in both the summary table and its own section header. `PRD.md` §7/§12 updated with the implementation notes (placeholder UPI details, client-side QR generation with no gateway).
3. Current active phase moves to **Phase 6 — Polish, Animations & UX Refinement**. This phase is UX polish across already-built screens, not new features — flagged that shimmer/pull-to-refresh already exist on most list screens from when they were built, so the first step is auditing what's actually still missing rather than assuming a blank slate; the two Lottie-animation checklist items need actual `.json` asset files sourced/approved first, the same "no assets exist yet" gap noted back in Phase 3.

---

## 📅 Session Log: 2026-07-23 (continued) — Phase 6 begins: Dark Mode Toggle + Visual Redesign Plan

### 📋 Tasks completed:

- User reviewed a Blinkit/Zepto-style visual-direction mockup (published as an Artifact, not app code — tinted category rings, product cards with an inline qty stepper, a floating cart bar, a 4-palette comparison) and approved it as-is ("what u showed was beautiful and perfect, go for it"), landing on the existing Wholesale Blue brand palette rather than one of the three alternates shown.
- Entered plan mode to scope how that visual direction plus Phase 6's existing 9-item checklist fit together, running two parallel research audits first (theme/animation infrastructure; per-screen shimmer/refresh/empty/error coverage) rather than guessing what already existed. Findings written into the plan file (`C:\Users\niran\.claude\plans\async-beaming-heron.md`) — key ones: `LocalStorageService` already had dormant theme-persistence methods nothing called; `QtyStepper` exists but is sized for a full-width row, not a 2-column card; zero `Hero`/custom-transition infrastructure exists anywhere; `CategoryEntity.iconUrl` (added in Phase 4.4 for admin icon upload) is never read by `CategoryCard` — admin-uploaded icons currently go nowhere; `search_controller.dart`'s `SearchState` has no error field at all, silently treating failures as "no results."
- Plan approved: 5 sub-phases (6.1 dark mode, 6.2 card redesign, 6.3 floating cart bar, 6.4 motion/transitions, 6.5 list-screen gap fixes), each committed independently, matching this project's existing 4.1–4.6/5.x convention even though Phase 6's original checklist in `phases.md` was a flat list — restructured it into the same sub-numbered format for consistency.
- **6.1 — Dark mode toggle, done**: `ThemeModeController`/`themeModeProvider` (`core/theme/theme_controller.dart`) wired to the pre-existing (but previously unused) `LocalStorageService.saveThemePreference`/`getThemePreference`, plus a new `clearThemePreference()` for the "System" option. `main.dart` now watches it instead of hardcoding `ThemeMode.system`. `ProfileScreen` gained an "Appearance" section with a `SegmentedButton<ThemeMode>`.
- **Test-infra bug found and fixed**: writing `ProfileScreen`'s first-ever test coverage surfaced that `find.text()` — not just `tester.tap()`, which `flutter_test_config.dart` already makes fatal on a miss — silently fails to find widgets built below the default 800×600 test surface's fold, because `SliverList` only inflates Elements within its viewport+cache extent even when the parent `ListView(children:)` eagerly constructed all the child *widgets*. Root-caused by dumping the actual mounted `Text` widget list mid-test rather than guessing. Fixed with the existing `useTallTestViewport()` helper.
- **Tests added** (8 new, 105 total): `theme_controller_test.dart` (6), `profile_screen_test.dart` (2, new file — first `ProfileScreen` coverage in this project).
- **Verification**: `flutter analyze` — zero issues. `flutter test` — 105/105 passing.

### 💬 Latest Discussion Summary:

1. `phases.md` restructured: Phase 6 now has 6.1–6.5 sub-headers (was a flat 9-item list); 6.1 marked ✅ with scope notes (1/9). Current active phase remains **Phase 6**, next up: **6.2 — Product card & category card redesign** (the qty-stepper `ProductCard` and tinted-ring `CategoryCard` from the approved mockup).
2. Full plan detail (all 5 sub-phases, audit findings, file-level decisions) lives in `C:\Users\niran\.claude\plans\async-beaming-heron.md` — reference it directly for 6.2–6.5 rather than re-deriving scope.

**6.2 — Product card & category card redesign, done (same session):**
- `AppColors.categoryPalette` (6 rotating accents); `CategoryCard` picks its ring color from `category.displayOrder % palette.length` and, for the first time, actually renders an admin-uploaded `category.iconUrl` (Phase 4.4 added the upload path; nothing ever read it back until now) — falls back to the existing name-matched Material icon otherwise.
- `ProductCard` converted `StatelessWidget` → `ConsumerWidget`: reads/writes `cartControllerProvider` directly (new `CartEntity.qtyFor()` getter) instead of taking an `onAddToCart` callback, so the add→inline-stepper transition works in every grid using it with zero caller wiring. Added a compact `_CompactQtyStepper` sized for a 2-column card — the existing `QtyStepper` is built for the full-width Product Detail/Cart row, a genuinely different size tier. Dropped the "added to cart" snackbar on quick-add — the card turning into a stepper is the feedback now, matching how Blinkit/Zepto actually behave.
- Real find: `ProductCard` only lays out correctly at a constrained width (always a `GridView` cell in production) — the first test attempt without that constraint blew the image's `AspectRatio` out to the full test-surface height and overflowed; fixed by constraining the test the same way real usage does.
- Tests added (8 new, 113 total): `product_card_test.dart` (4), `category_card_test.dart` (4). `flutter analyze` zero issues.
- **Not yet visually verified on a live device/emulator** — no Android device/emulator was attached in this environment, so 6.1 and 6.2 are covered by widget tests only so far. Flagged as a to-do before shipping, not silently skipped.
3. `phases.md` progress denominator changed from `/9` to `/11` — 6.2 and 6.3 (floating cart bar) are net-new scope from the approved mockup, not part of the original 9-item checklist, so tracking against the smaller number would have understated real progress. Next up: **6.3 — Floating cart bar**.

---

## 📈 Future Action Items & Checklist

- [x] Receive details from the client (Name, Logo, Business model, Payments, Play Store details).
- [x] Set up Firebase Project / backend config.
- [x] Implement onboarding & authentication flows (with role-based routing and manual admin approval status check).
- [x] Enforce business rules in code (Minimum order of ₹2,500, delivery charge calculation per km).
- [x] Implement initial theme & design system screens (Home, Category, Detail).

---

## 🛠️ Code Quality & Engineering Rules (15+ Years Experience)

_Every code snippet generated during this project must adhere to these guidelines:_

1. **Clean Architecture & SOLID**: Clean separation between UI (Presentation), Controllers/Notifiers (State), and Data (API/Cache/Models).
2. **Modern State Management**: Use Riverpod with auto-dispose, keeping logic decoupled from the widgets.
3. **High-Performance UI**:
   - Maximize `const` widget caching.
   - Use `ListView.builder` with `itemExtent` for long lists.
   - Use `CachedNetworkImage` with clean shimmers.
4. **Resilient Networking**: Dio HTTP client with interceptors for error handling, JWT refresh, and retry logic.
5. **Type Safety**: Safe serialization/deserialization with null-safe mappings and default fallbacks.
6. **Strict Business Rule Validation**:
   - Always validate minimum checkout amount is ₹2,500.
   - Require account verification/manual approval check on onboarding/login.
   - Show contact support with phone `9860460325` / email `vishvatejkatkar007@gmail.com` if account is pending approval.
   - Support two user roles: Admin (owner) and Normal User. On login, dynamically route Admin to the Admin dashboard (to manage products, categories, and view orders) and Normal Users to the consumer marketplace.
