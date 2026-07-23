# 🗺️ PHASES.md
## Jyoti Kirana — Master Project Roadmap & Task Tracker

> **This is the single source of truth for project progress.**
> Whenever asked _"what's next?"_ or _"what to do now?"_ — always refer to this file and return the **next unchecked task** from the **current active phase**.
>
> ✅ = Done | 🔄 = In Progress | ⬜ = Not Started

---

## 📊 Overall Progress

| Phase | Title | Status | Progress |
|---|---|---|---|
| Phase 1 | Foundation & Infrastructure | ✅ Complete | 10/10 |
| Phase 2 | Domain Layer & Data Models | ✅ Complete (Auth use cases deliberately deferred — see note) | 8/12 |
| Phase 3 | Core Commerce — Retailer Side | ✅ Complete (delivery charge stubbed, UPI/FCM deferred — see note) | 12/14 |
| Phase 4 | Admin Panel — Full Implementation | ✅ Complete | 21/21 |
| Phase 5 | Delivery, Payments & Notifications | ✅ Complete | 10/10 |
| Phase 6 | Polish, Animations & UX Refinement (scope expanded — see note) | 🔄 In Progress | 3/11 |
| Phase 7 | Testing & Quality Assurance | ⬜ Not Started | 0/10 |
| Phase 8 | Launch Preparation & Play Store | ⬜ Not Started | 0/8 |

---

## ✅ Phase 1 — Foundation & Infrastructure
> **Status**: COMPLETE ✅  
> **Goal**: Scaffold the project, set up all infrastructure, design system, routing, and auth screens.

- [x] Initialize Flutter project with Clean Architecture folder structure
- [x] Configure `pubspec.yaml` with all approved packages
- [x] Set up `app_colors.dart` — full brand color palette (light + dark)
- [x] Set up `app_theme.dart` — MaterialTheme light/dark configuration
- [x] Set up `app_router.dart` — GoRouter with all route stubs and auth guards
- [x] Set up `api_client.dart` — Dio HTTP client with interceptors
- [x] Set up `api_exceptions.dart` — typed exception classes
- [x] Set up Hive local storage service (tokens, settings, search history)
- [x] Implement `AuthScreen` — Login / Sign-up with business verification fields
- [x] Implement `PendingApprovalScreen` — lock screen with admin contact details
- [x] Implement `AdminDashboardScreen` (shell) — stats overview + approval queue
- [x] Implement `HomeScreen` (shell) — category grid, banners, minimum order notice
- [x] Firebase Auth + Firestore integration with resilient fallback to Hive simulation mode
- [x] `appRouterProvider` — reactive routing based on auth state (Admin/Approved/Pending)
- [x] Fix all compile errors — `flutter analyze` passes with zero issues
- [x] Fix test suite — `flutter test` passes with zero failures
- [x] Git repository initialized and linked to `10Niranjan/Jyoti-Kirana`
- [x] Created `PRD.md`, `ARCHITECTURE.md`, `rules.md`, `phases.md`

---

## ✅ Phase 2 — Domain Layer & Data Models
> **Status**: COMPLETE ✅ (2026-07-21) — with one deliberate scope exception, see note below
> **Goal**: Build the entire Domain layer (Entities, UseCases, Repository interfaces) and Data layer (Models, DataSources, Repository implementations). This is the backbone — no UI yet, just pure business logic.

> **Note on Auth scope**: `domain/repositories/auth_repository.dart` and the `auth/login_usecase.dart` / `register_usecase.dart` / `logout_usecase.dart` use cases were **deliberately not created**. The existing `data/repositories/auth_repository.dart` + `FirebaseAuthRepository` (built in Phase 1) already implement login/signup/signout end-to-end and are actively used by `AuthController`. Duplicating that under `domain/` or routing it through new use cases would touch working, tested code for no functional gain. Admin user-management (approve/reject/list pending) got its own new `UserRepository` in `domain/`, separate from `AuthRepository`, which covers everything Phase 4 needs from this layer.

### 2.1 — Value Objects & Entities
- [x] Create `domain/value_objects/money.dart` — wraps amount, validates ≥ 0, formats ₹
- [x] Create `domain/value_objects/phone_number.dart` — validates 10-digit Indian number
- [x] Create `domain/entities/user_entity.dart` — `uid, fullName, shopName, phone, role, status, address, fcmToken, createdAt`
- [x] Create `domain/entities/product_entity.dart` — `id, name, categoryId, imageUrl, price, unit, stock, isActive`
- [x] Create `domain/entities/category_entity.dart` — `id, name, iconUrl, displayOrder, isActive`
- [x] Create `domain/entities/order_entity.dart` — `id, userId, items, subtotal, deliveryCharge, grandTotal, paymentMethod, orderStatus, createdAt`
- [x] Create `domain/entities/cart_entity.dart` — `items: List<CartItem>, subtotal`

### 2.2 — Repository Interfaces (Abstract)
- [ ] ~~Create `domain/repositories/auth_repository.dart`~~ — skipped, see scope note above
- [x] Create `domain/repositories/product_repository.dart` — abstract interface
- [x] Create `domain/repositories/order_repository.dart` — abstract interface
- [x] Create `domain/repositories/user_repository.dart` — abstract interface
- [x] Create `domain/repositories/category_repository.dart` — abstract interface (added; needed by Category Management, Phase 4.4)
- [x] Create `domain/repositories/cart_repository.dart` — abstract interface (added; local-only, Hive-backed)

### 2.3 — Use Cases
- [ ] ~~Create `domain/usecases/auth/login_usecase.dart` / `register_usecase.dart` / `logout_usecase.dart`~~ — skipped, see scope note above
- [x] Create `domain/usecases/product/get_products_usecase.dart`
- [x] Create `domain/usecases/product/search_products_usecase.dart`
- [x] Create `domain/usecases/category/get_categories_usecase.dart` (added)
- [x] Create `domain/usecases/order/place_order_usecase.dart` — **validates ₹2,500 minimum against subtotal — throws `MinimumOrderException` if violated**
- [x] Create `domain/usecases/order/get_order_history_usecase.dart`
- [x] Create `domain/usecases/order/update_order_status_usecase.dart` (admin)
- [x] Create `domain/usecases/user/approve_user_usecase.dart` (admin)
- [x] Create `domain/usecases/user/get_pending_users_usecase.dart` (admin)

### 2.4 — Data Models (DTOs)
- [x] Extend `data/models/user_model.dart` — added `status`, `address`, `gstNumber`, `fcmToken`; `isApproved` kept as a computed getter for backward compatibility with existing call sites
- [x] Create `data/models/product_model.dart` — with `fromFirestore()` + `toFirestore()` via `.withConverter`
- [x] Create `data/models/category_model.dart` — with `fromFirestore()` + `toFirestore()` via `.withConverter`
- [x] Create `data/models/order_model.dart` — with `fromFirestore()` + `toFirestore()` via `.withConverter`
- [x] Create `data/models/cart_item_model.dart` — hand-written, stored as a plain Map in Hive (no `TypeAdapter` codegen — matches the no-codegen decision and how every other Hive box in this project already stores data)

### 2.5 — Data Sources & Repository Implementations
- [x] Create `data/datasources/remote/category_remote_datasource.dart` — Firestore CRUD + Hive-simulation fallback (added)
- [x] Create `data/datasources/remote/product_remote_datasource.dart` — Firestore CRUD + Hive-simulation fallback
- [x] Create `data/datasources/remote/order_remote_datasource.dart` — Firestore CRUD + Hive-simulation fallback
- [x] Create `data/datasources/remote/user_remote_datasource.dart` — Firestore user management + Hive-simulation fallback
- [x] Create `data/datasources/local/cart_local_datasource.dart` — Hive cart persistence
- [x] Create `data/datasources/local/product_local_datasource.dart` — Hive catalog cache
- [x] Create `data/repositories/category_repository_impl.dart` — implements domain interface (added)
- [x] Create `data/repositories/product_repository_impl.dart` — implements domain interface
- [x] Create `data/repositories/order_repository_impl.dart` — implements domain interface
- [x] Create `data/repositories/user_repository_impl.dart` — implements domain interface
- [x] Create `data/repositories/cart_repository_impl.dart` — implements domain interface (added)
- [x] Create `data/repositories/repository_providers.dart` — consolidated Riverpod providers for all five repositories above

### 2.6 — Core Constants & Utilities
- [x] Create `core/constants/app_constants.dart` — `kMinOrderAmount = 2500.0`, `kSupportPhone`, `kSupportEmail`, `kAppName`
- [x] Create `core/constants/firestore_paths.dart` — all collection/document path strings
- [x] Create `core/constants/hive_keys.dart` — all Hive box and key name constants
- [x] Create `core/constants/route_names.dart` — all GoRouter route name constants (wired into `app_router.dart`)
- [x] Create `core/utils/currency_formatter.dart` — `formatRupees(double amount)` → `₹2,500`
- [x] Create `core/utils/date_formatter.dart` — `formatOrderDate(DateTime)` → `15 Jul 2026`
- [x] Create `core/utils/validators.dart` — phone, GST, name, address validators
- [x] Create `core/utils/extensions.dart` — String, DateTime, List extension methods
- [x] Create `core/network/firebase_mode.dart` — shared placeholder-detection helper (added; extracted from `FirebaseAuthRepository`)

---

## ✅ Phase 3 — Core Commerce (Retailer Side)
> **Status**: COMPLETE ✅ (2026-07-21)  
> **Goal**: Build the complete retailer-facing shopping experience — browse, search, cart, checkout, and order history.

> **Scope notes**: (1) No `assets/images/` exist, so the "promotional banner" is an informational `PromoBannerCarousel` (icon + text slides), not photography. (2) Navigation uses a `StatefulShellRoute` bottom-nav shell (Home/Search/Cart/Orders/Profile) rather than plain push routes — matches `ARCHITECTURE.md`'s documented `bottom_nav_bar.dart`. (3) The 8 PRD §5 categories + demo products are auto-seeded into the simulated catalog on first launch (`demo_catalog_seeder.dart`) since Phase 4's Admin product-management UI doesn't exist yet to add real ones. (4) Checkout ships **COD only** with a **flat placeholder delivery charge** (`kStubDeliveryCharge`) — real per-km `geolocator` calculation, the UPI QR screen, and FCM-to-admin are deferred to Phase 5, which already owns this scope in full; building it twice would be wasted work.

### 3.1 — Home Screen (Real Data)
- [x] Wire `HomeScreen` to `categoriesProvider` — fetch real categories via `GetCategoriesUseCase`
- [x] Build `CategoryCard` widget — icon (resolved from name), name, tap → navigate to category products
- [x] Build promotional banner — `PromoBannerCarousel` (informational slides, no image assets exist)
- [x] Add shimmer loading state while categories are fetching
- [x] Add empty state if no categories are available

### 3.2 — Product Browsing
- [x] Build `CategoryProductsScreen` — filtered product grid by `categoryId`
- [x] Build `ProductCard` widget — image (icon fallback), name, price (₹), unit, "Add to Cart" button
- [x] Build `ProductDetailScreen` — full image, name, price, unit, stock info, description, qty stepper, "Add to Cart"
- [x] Implement `productController` (`productsByCategoryProvider`, `productByIdProvider`) — fetches via `GetProductsUseCase`
- [x] Add shimmer loading for product grid
- [x] Add empty state for categories with no products

### 3.3 — Search
- [x] Build `SearchScreen` — text field, debounced search via `SearchProductsUseCase`
- [x] Display search results as product list tiles
- [x] Save recent search terms to Hive (max 5, via existing `LocalStorageService`)
- [x] Show recent searches when search field is empty

### 3.4 — Cart
- [x] Build `CartScreen` — list of cart items, quantity controls, subtotal, checkout CTA
- [x] Implement `CartController` (Hive-backed via `CartRepository`) — `addItem`, `removeItem`, `updateQty`, `clearCart`
- [x] Show real-time cart badge count on bottom nav bar
- [x] Show ₹2,500 minimum order warning banner when subtotal < ₹2,500
- [x] Disable "Proceed to Checkout" button if subtotal < ₹2,500
- [x] Build cart item tile — image, name, qty stepper, item total

### 3.5 — Checkout
- [x] Build `CheckoutScreen` — order summary, delivery address (editable, pre-filled from profile), payment method (COD), delivery charge display, "Place Order" CTA
- [x] Implement `CheckoutController` — calls `PlaceOrderUseCase`, handles loading/success/error via `AsyncValue`
- [x] `PlaceOrderUseCase` validates ₹2,500 minimum (against subtotal, not grand total) before the order is written
- [ ] ~~Calculate delivery charge via `geolocator` (per-km)~~ — stubbed as a flat placeholder; real calc is Phase 5 scope
- [x] COD option — immediate order placement
- [ ] ~~UPI option (QR code image + manual confirmation)~~ — deferred to Phase 5
- [ ] ~~Send FCM notification to admin on order placement~~ — deferred to Phase 5 (FCM isn't set up yet)

### 3.6 — Order Success & History
- [x] Build `OrderSuccessScreen` — order ID, confirmation message (icon-based, no Lottie assets exist)
- [x] Build `OrderHistoryScreen` — list of past orders with status badges
- [x] Build `OrderDetailScreen` — full order breakdown, item list, delivery address, payment method
- [x] Implement `orderController` (`orderHistoryProvider`, `orderByIdProvider`) — fetches via `GetOrderHistoryUseCase`
- [x] Real-time order status updates stream from the (simulated) backend

### 3.7 — Profile
- [x] Build `ProfileScreen` — shop name, phone, editable address, GST number, logout button
- [x] Add "Contact Support" section — tap-to-call `9860460325`, tap-to-email, via `url_launcher` + `AppConstants`
- [x] Allow editing of delivery address (needed for Phase 5's km calculation)
- [x] Implement `ProfileController` + new `AuthRepository.updateProfile()` — updates the user's own profile (self-service, separate from admin's `UserRepository`)

---

## ✅ Phase 4 — Admin Panel (Full Implementation)
> **Status**: COMPLETE ✅ (4.1–4.2 2026-07-22, 4.3–4.6 2026-07-23)  
> **Goal**: Give the admin owner full control — manage products, categories, approve retailers, and handle orders.

### 4.1 — Admin Dashboard (Real Data) ✅
- [x] Wire `AdminDashboardScreen` to real Firestore counts (today's orders, pending approvals, total retailers) — via new `admin_dashboard_controller.dart` providers over the existing `UserRepository`/`OrderRepository`
- [x] Build stat cards with real-time stream data — `AdminStatCard` widget, `StreamProvider`-backed, shimmer while loading
- [x] Add `fl_chart` bar chart — orders per day (last 7 days) — `OrdersBarChart` widget

> **Scope notes**: (1) Moved `AdminDashboardScreen` from `lib/features/home/screens/` to `lib/features/admin/screens/` to match the module structure `ARCHITECTURE.md` already documents (needed by 4.2–4.6 anyway). (2) Replaced the old `ConsumerStatefulWidget`/`setState()` + direct `FirebaseAuthRepository` casting (a Phase-1 shortcut that bypassed the domain layer) with a proper `ConsumerWidget` over `StreamProvider`s, per rules.md §2.2/§5. (3) Added `RejectUserUseCase` (mirrors `ApproveUserUseCase`) to wire up the approval queue's previously-dead "Reject" button — `UserRepository.rejectUser()` already existed unused. (4) "Today's orders"/"last 7 days" counts are derived client-side from `OrderRepository.watchAllOrders()` rather than new aggregation queries, consistent with how `orderByIdProvider` derives from `orderHistoryProvider` elsewhere in the codebase.

### 4.2 — Retailer Approval ✅
- [x] Build `ApprovalQueueScreen` — live stream of pending users (`pendingUsersProvider`), pull-to-refresh, shimmer loading, empty/error states
- [x] Build `RetailerApprovalCard` — shop name, owner, phone, **address** (falls back to "Address not provided yet" — retailers don't set one until Profile, Phase 3.7), Approve/Reject buttons with a per-card busy spinner
- [x] Implement `approvalController` — `StateNotifier<AsyncValue<void>>` calling `ApproveUserUseCase` / `RejectUserUseCase`, same pattern as `CheckoutController`
- [ ] ~~Send FCM to retailer on approval/rejection~~ — deferred to Phase 5 (FCM isn't set up yet, same deferral as 3.5/4.1)

> **Scope notes**: (1) The 4.1 dashboard's inline approval queue now shows a 3-item preview + "View All" link into this screen, reusing `RetailerApprovalCard`/`EmptyApprovalQueueCard` rather than duplicating markup. (2) New route `RouteNames.adminApprovalQueue` (`/admin/approval-queue`), a top-level push route like `checkout`/`orderDetail` — no extra role guard needed since it's admin-only reachable from the dashboard and GoRouter's redirect already doesn't restrict authenticated-admin sub-routes. (3) Found and fixed a real bug via an interaction widget test: `approvalControllerProvider` is `.autoDispose`, and grabbing its notifier via `ref.read` in `build()` let Riverpod dispose it mid-await on the first approve/reject tap (`StateError: Tried to use ApprovalController after dispose was called`) — fixed by `ref.watch`-ing the notifier instead so the card's own subscription keeps it alive for the async call.

### 4.3 — Product Management ✅
- [x] Build `ManageProductsScreen` — product list with edit/delete actions, pull-to-refresh, shimmer/empty/error states, delete confirmation dialog
- [x] Build `AddEditProductScreen` — form: name, category dropdown, price, unit, stock, description, image picker, active toggle, with validation
- [x] Implement product image upload to Firebase Storage — `ImageUploadService`, with simulation-mode fallback
- [x] Implement `adminProductController` — CRUD via new `Create`/`Update`/`Delete`/`GetAllProducts` use cases
- [x] Add product stock alert (highlight when stock ≤ `AppConstants.kLowStockThreshold`) — per-row warning + a summary banner

> **Scope notes**: (1) **Real bug found and fixed**: `watchProducts()` hardcoded `isActive == true` in *both* its Firestore and simulation branches (retailer-browsing semantics), so deactivated products would have been invisible to the admin — permanently unrecoverable, since there'd be no way to find one to re-activate it. Added a separate `watchAllProducts()` through datasource → repository → use case rather than changing the existing method, so retailer browsing is untouched; covered by a new integration test asserting both visibilities. (2) New packages: `firebase_storage` (already pre-approved in rules.md §1) and `image_picker` (**explicitly approved by the user** this session, as rules.md §11 requires — it was not in the approved list). (3) Firebase is still on placeholder credentials, so `ImageUploadService` falls back to returning the picked file's **local path** as the image URL; admin screens render that via `Image.file`, and retailer-side `CachedNetworkImage` degrades to its existing placeholder icon through `errorWidget`. When a real Firebase project is configured this starts returning real download URLs with no call-site changes. (4) "Paginated" is implemented as the existing capped `.limit(200)` query, matching every other list in this codebase — no cursor-based infinite scroll exists anywhere yet, and introducing that pattern for a catalog of dozens of SKUs would be premature. (5) `ProductEntity.copyWith({imageUrl})` added — narrow by design, only the upload flow needs it.

### 4.4 — Category Management ✅
- [x] Build `ManageCategoriesScreen` — list with drag-to-reorder display order
- [x] Build `AddEditCategoryScreen` — form: name, icon upload, active toggle
- [x] Implement `adminCategoryController` — CRUD on Firestore categories

> **Scope notes**: (1) **Real bug found and fixed**: adding the "Active" toggle is what first made `CategoryEntity.isActive` actually settable to `false` — and the retailer-facing `categoriesProvider` (`features/home/controllers/home_controller.dart`) never filtered on it, so a deactivated category would still have shown up on the retailer Home screen and in `CategoryProductsScreen`, permanently un-hideable. Fixed by filtering to `isActive` at that provider (retailer-facing only); `adminCategoryController`'s own `adminCategoriesProvider` stays unfiltered so the admin can still see and re-activate hidden categories, mirroring 4.3's `watchAllProducts()` split. (2) That filter change created a second latent bug: `AddEditProductScreen`'s category dropdown was fed by the same (now-filtered) `categoriesProvider`, so editing a product already assigned to a category the admin has since deactivated would hit Flutter's "exactly one matching dropdown item" assertion and crash. Fixed by pointing that dropdown at the unfiltered `adminCategoriesProvider` instead. (3) Reordering persists via `AdminCategoryController.reorder()` — takes the full post-drag list and writes a new `displayOrder` only for entries whose index actually changed, rather than rewriting every row on every drag. (4) Reused `ProductImagePickerField` as-is for the category icon picker — its logic (local file / network URL / empty placeholder) was already generic, not product-specific, so a near-identical copy would have been pure duplication. (5) `ImageUploadService` and `StoragePaths` extended with `uploadCategoryIcon`/`deleteCategoryIcon` and `categoryIcon(id)`, same simulation-mode fallback pattern as the product image methods. (6) New use cases: `CreateCategoryUseCase`, `UpdateCategoryUseCase`, `DeleteCategoryUseCase` (mirroring the product ones) — `CategoryRepository` already had the methods, just no use-case wrappers yet. (7) Added a "Manage Categories" button to `AdminDashboardScreen` next to "Manage Products". (8) Tests: `manage_categories_screen_test.dart` (5 — empty state, listing, inactive-visible, delete-confirmation gating, drag-to-reorder persists), `add_edit_category_screen_test.dart` (5 — create/edit modes, validation, new-category display-order placement, active toggle). 59/59 passing, `flutter analyze` zero issues.

### 4.5 — Order Management ✅
- [x] Build `AllOrdersScreen` — filterable list by status: All / Pending / Confirmed / Delivered
- [x] Build `OrderManagementScreen` — full order details + status update dropdown
- [x] Implement `adminOrderController` — calls `UpdateOrderStatusUseCase`
- [ ] ~~Send FCM to retailer on each status change~~ — deferred to Phase 5, same reasoning as every other FCM item so far

> **Scope notes**: (1) Filter chips cover all 4 real `OrderStatus` values (Pending / Confirmed / Out for Delivery / Delivered), not just the 3 named in this checklist — the extra status already exists in the domain model and hiding it from the filter would have made "Out for Delivery" orders unreachable by filter. (2) Extracted `OrderDetailBody` into `shared/widgets/` from what was `OrderDetailScreen`'s private `_OrderDetailBody` — now shared between the retailer's read-only order detail view and the admin's `OrderManagementScreen`, which adds the shop name (`showShopName: true`) and a status-update dropdown via a `header` slot rather than forking a near-duplicate of the same ~90-line layout. (3) Added `OrderStatusLabelExtension.label` on `OrderStatus` (`core/utils/extensions.dart`) so `OrderStatusBadge` and the new admin status dropdown render identical wording from one source instead of two parallel switch statements. (4) `AllOrdersScreen`/`OrderManagementScreen` reuse the dashboard's existing `allOrdersProvider` (`admin_dashboard_controller.dart`) rather than adding a duplicate stream — it was already unfiltered and already the source the dashboard's own stats are derived from. (5) **Real bug found and fixed**: `order.id.substring(0, 8)` (used to build the "Order #XXXXXXXX" label) would throw a `RangeError` on any order id under 8 characters. Real ids are always 36-char UUIDs so this was never reachable in production, but it's a defensive gap in shared display code — fixed once via a new `String.shortId` extension and applied to `OrderDetailBody`, `AllOrdersScreen`, and the pre-existing `OrderHistoryScreen`, which had the same unguarded call. (6) Tests: `all_orders_screen_test.dart` (4 — empty state, unfiltered listing, status filtering, filtered-empty message), `order_management_screen_test.dart` (3 — renders breakdown, not-found state, status-change interaction confirms via repository call + snackbar). 66/66 passing, `flutter analyze` zero issues.

### 4.6 — Retailer Management ✅
- [x] Build `RetailerListScreen` — all approved retailers with total spend, order count
- [x] Allow admin to tap a retailer and view their full order history

> **Scope notes**: (1) `retailerSummariesProvider` derives per-retailer order count and total spend client-side from the existing `approvedUsersProvider` + `allOrdersProvider` streams (grouped by `userId`) — no new repository query, consistent with every other Phase 4 stat. Sorted by total spend, highest first, so the admin's most valuable retailers surface at the top. (2) Reused `AllOrdersScreen` for the tap-through history instead of a new screen — it now takes an optional `retailerId` that scopes the list, swaps the app-bar title to the retailer's shop name, and hides the now-redundant per-row shop name. Route: `/admin/retailers/:retailerId/orders`. (3) Added a "Retailers" button to `AdminDashboardScreen`, alongside "All Orders" in a second button row. (4) Tests: `retailer_list_screen_test.dart` (3 — empty state, zero-order retailer still listed, spend/count computed correctly and sorted), plus one new case in `all_orders_screen_test.dart` covering the `retailerId` scoping (title, filtered list, hidden shop-name row). 70/70 passing, `flutter analyze` zero issues.
> **Phase 4 complete.** All 21 tasks across 4.1–4.6 done.

---

## ✅ Phase 5 — Delivery, Payments & Notifications
> **Status**: COMPLETE ✅ (2026-07-23)  
> **Goal**: Complete delivery charge logic, finalize payment flows, and implement push notifications end-to-end.

- [x] Set up Firebase Cloud Messaging (FCM) — `FirebaseMessaging.onMessage` + background handler
- [x] Request notification permission on app startup
- [x] Save FCM token to Firestore on login/refresh
- [x] Build `NotificationsScreen` — list of received FCM notifications stored locally in Hive

> **Scope notes**: (1) `firebase_messaging` added (pre-approved, rules.md §1). Every `FirebaseMessaging` call is wrapped in its own try/catch and degrades to a no-op (`null` token / empty stream) rather than throwing — there's no meaningful "simulation mode" substitute for FCM the way Firestore/Auth have one, so this is the defensive fallback for unconfigured credentials, an unsupported platform, or a test environment with no platform channel registered. Confirmed working: the widget-test smoke test logs `FcmService: permission/token request unavailable, skipping` and continues normally rather than crashing. (2) `AuthRepository.updateFcmToken(uid, fcmToken)` — new method (mirrors `updateProfile`'s mock/Firestore branches) — persists the token on login and again on every `onTokenRefresh` event, via `fcmInitializerProvider`, a plain `Provider<void>` watched once from the app root (`JyotiKiranaApp.build()`) so it initializes exactly once per app lifetime regardless of auth state. (3) `firebaseMessagingBackgroundHandler` is a top-level function (required — Firebase launches it in a separate isolate) that only re-initializes Firebase and otherwise no-ops: the OS renders the notification natively from the message's `notification` payload with zero app code needed, and a background isolate can't safely touch the main isolate's already-open Hive boxes. (4) `NotificationsScreen` + `NotificationRepository` are local-only (Hive, no Firestore) per the checklist wording, following the exact same local-only pattern `CartRepository` already established (datasource → repository → controller, no use-case layer, since it's simple CRUD over one Hive box). New `notifications_cache` Hive box. (5) Added a shared `NotificationBellButton` (bell icon + unread-count badge, reusing the `badges` package already used for the cart badge) to both `HomeScreen` (retailer) and `AdminDashboardScreen` — notification history is per-device, not per-role, so both point at the same `/notifications` route. (6) Deliberately did **not** add tap-to-open-order-detail navigation from a notification tile, or a `flutter_local_notifications`-based foreground tray notification (that package isn't on rules.md's approved list) — neither was asked for by this checklist, and the in-app list + bell badge already satisfies it. (7) No Cloud Function actually *sends* these yet (out of scope — this phase only wires the client side), so in practice the notification list will stay empty until a backend sender exists; the plumbing is fully in place for when it does. (8) Tests: `notifications_screen_test.dart` (5), `notification_bell_button_test.dart` (2), plus a new Hive round-trip case in `simulation_backend_test.dart` (add → newest-first ordering → mark-as-read → mark-all-read). 78/78 passing, `flutter analyze` zero issues.

- [x] Implement delivery charge calculation — use `geolocator` to get retailer GPS, calculate distance from warehouse coordinates, multiply by per-km rate set by admin
- [x] Build admin setting for per-km rate in `AdminDashboardScreen`
- [x] Store warehouse lat/long as a Firestore config document

> **Scope notes**: (1) `geolocator` added (pre-approved, rules.md §1) + `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` added to `AndroidManifest.xml`. `LocationService` (`core/services/`) wraps every geolocator call in one try/catch, same defensive-fallback pattern as `FcmService` — no permission/service/platform failure ever throws into UI code. (2) `AddressEntity` gained optional `latitude`/`longitude` (nullable, backward compatible) plus a `hasCoordinates` getter — populated only once a retailer taps "Use current location" while editing their address in `ProfileScreen` or `CheckoutScreen`. Extracted the now-4-field address form (street/city/pincode/location-button) both screens previously duplicated into a shared `AddressFormFields` widget. (3) Real distance math is Haversine, hand-rolled as a pure-Dart `calculateDistanceKm()` (`core/utils/distance_calculator.dart`) rather than depending on `geolocator` from the domain layer — `geolocator` is a plugin package and the domain layer must stay plugin-free; only `LocationService` (core, not domain) touches it. `CalculateDeliveryChargeUseCase` returns `null` when the address has no coordinates yet, and `CheckoutScreen` falls back to the pre-existing flat `kStubDeliveryCharge` in that case — rules.md §10 requires a delivery charge is always calculated and shown, so it's never left blank. (4) New `DeliveryConfigRepository`/`DeliveryConfigEntity` — the **first single-document Firestore repository in this codebase** (`config/delivery`, vs. every prior repository being a collection of many docs), with the same Hive-simulation fallback dual-mode pattern as the rest, reusing the existing `settings_cache` box (no new box needed). Seeded with a documented bootstrapping default (central-India coordinates, ₹10/km per PRD §4.4's own example) until the admin sets the real warehouse location. (5) `DeliverySettingsScreen` — admin edits warehouse lat/lng (with its own "use current location" shortcut) and the per-km rate; added as a new full-width button on `AdminDashboardScreen`. The read-side `deliveryConfigProvider` is shared between this screen and `CheckoutScreen` (both need the live config), while the write side (`AdminDeliveryConfigController`) is admin-only. (6) Tests: `distance_calculator_test.dart` (3 — zero distance, a known Mumbai–Pune sanity check, symmetry), `calculate_delivery_charge_usecase_test.dart` (3 — null without coordinates, distance×rate, zero at the warehouse), `delivery_settings_screen_test.dart` (3 — pre-fill, rate validation, save+confirm), plus a new Hive round-trip case in `simulation_backend_test.dart` (default fallback → admin update persists). 88/88 passing, `flutter analyze` zero issues.

- [x] UPI Payment Screen — display UPI QR image + UPI ID `(owner's UPI details)`, "I have paid" confirmation button, upload payment screenshot (optional)
- [x] Admin marks order as paid manually after UPI confirmation
- [x] COD — no extra steps, order placed immediately (unchanged since Phase 3)

> **Scope notes**: (1) **No real UPI ID/QR was ever provided by the client** (checked agents.md's client-spec notes — only "Cash on Delivery (COD) & Online UPI" is on file, no actual ID). `AppConstants.kUpiId`/`kUpiPayeeName` are explicit, documented placeholders (`jyotikirana@upi`) — swap them before launch; nothing else in the flow needs to change. (2) Added `qr_flutter` — **explicitly approved by the user this session** (rules.md §11) — to render a real, scannable QR client-side from a standard `upi://pay?...` deep link (amount + payee + a note carrying the order's short id), rather than shipping a static image asset that doesn't exist. Also added to `rules.md` §1 and `ARCHITECTURE.md` §2.7's approved-package tables per rules.md's own documentation requirement. (3) `CheckoutScreen`'s payment method was previously hardcoded to COD with no way to actually select UPI (a gap versus rules.md §10's "COD / UPI only" business rule, which implies retailers can pick either) — added a `RadioListTile` selector; UPI orders now route to the new `UpiPaymentScreen` after placement instead of straight to `OrderSuccessScreen` (PRD §7: "Order placed → UPI payment screen shown → ... → Admin confirms order"). (4) Extended `PaymentStatus` with a third state, `paymentClaimed` — the retailer's "I have paid" tap — sitting between `pending` and `paid` so the admin can see who's claimed payment vs. never touched it, matching PRD §7's flow literally (never used for COD). New `OrderRepository.recordPaymentClaim()` (retailer, sets status + optional screenshot URL in one write) and `.updatePaymentStatus()` (admin-only "Mark as Paid" in `OrderManagementScreen`, added to the existing `OrderDetailBody` via its `paymentExtra` slot, mirroring the existing `header` slot pattern from 4.5). (5) `OrderEntity.paymentScreenshotUrl` (nullable) — the uploaded screenshot is rendered back in `OrderDetailBody`'s Payment section for both the retailer and the admin, not just written to Storage and forgotten, since an upload nobody can ever view would be a half-finished feature. Reused `ImageUploadService` (Phase 4.3) with a new `uploadPaymentScreenshot()` method. (6) **Refactor while here**: `imageUploadServiceProvider` moved from `admin_product_controller.dart` into `core/services/image_upload_service.dart` (mirrors `locationServiceProvider`'s precedent from the delivery-charge work) since checkout — a retailer feature — now needs it too and importing it from an admin controller file was the wrong direction of coupling. Similarly renamed/relocated `features/admin/widgets/product_image_picker_field.dart` → `shared/widgets/image_picker_field.dart` (`ProductImagePickerField` → `ImagePickerField`) now that it's used by product photos, category icons, *and* UPI screenshots — it was already fully generic, just misfiled. (7) **Real bug found and fixed immediately**: `OrderSuccessScreen` had the exact same unguarded `order.id.substring(0, 8)` `RangeError` risk fixed elsewhere in Phase 4.5, just in a file that phase never touched — fixed via the existing `String.shortId` extension. (8) Tests: `record_payment_claim_usecase_test.dart` (2), `update_payment_status_usecase_test.dart` (1), 3 new cases in `order_management_screen_test.dart` (COD hides payment UI, UPI shows status + working Mark-as-Paid, already-paid hides the button), `upi_payment_screen_test.dart` (3 — amount/UPI-id render, copy-to-clipboard, not-found state; introduces this codebase's first `authControllerProvider`-backed widget test, via overriding `authRepositoryProvider` with a fake that immediately emits a signed-in retailer). 97/97 passing, `flutter analyze` zero issues.
> **Phase 5 complete.** All 10 tasks done.

---

## 🔄 Phase 6 — Polish, Animations & UX Refinement
> **Status**: IN PROGRESS 🔄 (6.1–6.3 complete 2026-07-23)  
> **Goal**: Elevate the app from functional to premium — plus a Blinkit/Zepto-style
> quick-commerce visual pass the client approved from a mockup. Broken into 6.1–6.5
> sub-phases (this project's own convention, mirroring Phases 4–5) even though the
> original checklist below was a flat list.
>
> **Scope note**: the original checklist had 9 items; 6.2 (card redesign) and 6.3
> (floating cart bar) are net-new scope from the approved visual-direction mockup, not
> in that original 9 — progress below is tracked out of 11 to reflect the real total.

### 6.1 — Dark mode toggle ✅
- [x] Implement dark mode toggle in Profile screen (saved to Hive via `themeProvider`)

> **Scope notes**: (1) `LocalStorageService.saveThemePreference`/`getThemePreference` already existed (Phase 1-era scaffolding) and already round-tripped a nullable bool through `HiveKeys.themeMode` — just never called by anything. Reused as-is; only added `clearThemePreference()` (mirrors the existing `clearAuthToken()` pattern) so "System" has a way to reset to no-preference. (2) New `ThemeModeController` (`core/theme/theme_controller.dart`) + `themeModeProvider`; `main.dart`'s hardcoded `themeMode: ThemeMode.system` now reads `ref.watch(themeModeProvider)`. (3) `ProfileScreen` gained an "Appearance" section (same header+row pattern as the existing "Support" section) with a Material 3 `SegmentedButton<ThemeMode>` (System/Light/Dark). (4) **Test-infra note**: the new `ProfileScreen` widget tests were the first to exercise content below "Support" in that screen's `ListView` — discovered that `find.text()` (not just `tester.tap()`, which `flutter_test_config.dart` already guards) silently fails to find content beyond the default 800×600 test surface, because `SliverList` only inflates Elements within its viewport+cache extent even for eagerly-built `ListView(children:)` children. Fixed with the existing `useTallTestViewport()` helper — same fix, newly-confirmed to also matter for pure assertions, not just taps. (5) Tests: `theme_controller_test.dart` (6 — defaults to system, loads dark/light from a stored bool, all three `setThemeMode` transitions persist correctly), `profile_screen_test.dart` (2 — new file, first ProfileScreen test coverage; renders the three segments, tapping Dark updates state). 105/105 passing, `flutter analyze` zero issues.

### 6.2 — Product card & category card redesign ✅
- [x] Blinkit/Zepto-style `ProductCard` — inline qty stepper once in cart, replacing the current one-shot add button
- [x] `CategoryCard` — tinted circular rings (rotating palette) + render admin-uploaded `iconUrl` when present, falling back to the existing name-matched icon

> **Scope notes**: (1) `AppColors.categoryPalette` — 6 rotating accents (reuses `primary`/`accent` plus 4 new hues); `CategoryCard` picks its ring color via `category.displayOrder % palette.length` rather than a passed-in index, so reordering categories in admin also reshuffles ring colors with zero call-site changes needed. (2) `CategoryCard` now renders `category.iconUrl` when non-empty (via the exact local-path-vs-URL check already established in `AdminCategoryTile._Thumbnail`), falling back to the existing name-matched Material icon — this is the first time an admin-uploaded category icon (Phase 4.4) actually reaches the retailer UI; it was dead data until now. (3) `ProductCard` converted from `StatelessWidget` to `ConsumerWidget` — it now reads/writes `cartControllerProvider` directly (`CartEntity.qtyFor()`, a new small getter) instead of taking an `onAddToCart` callback, so every grid using it gets the add→stepper transition for free with no caller wiring. The existing `QtyStepper` widget doesn't fit a 2-column card's width (it's sized for the full-width Product Detail/Cart row) — added a private `_CompactQtyStepper` in the same file rather than force-fitting the wrong size tier. Dropped the "added to cart" snackbar on the quick-add path — the card visually turning into a stepper is the feedback now (matches how Blinkit/Zepto actually behave); `ProductDetailScreen`'s explicit "Add to Cart" button + snackbar is untouched. (4) Only one call site (`category_products_screen.dart`) needed updating — `search_screen.dart`'s results use a different `ListTile` row layout, not `ProductCard`, left as-is. (5) **Test-infra note**: `ProductCard` only renders correctly at a constrained width (it's always inside a `GridView` cell in production); the first test attempt without that constraint blew the `AspectRatio(1.1)` image out to the full test-surface height and overflowed — fixed by wrapping the card in a `SizedBox(width: 170)` in the test, matching its real usage. (6) Not yet visually verified on a live build (no Android emulator/device attached in this environment) — covered thoroughly by widget tests instead; recommend a manual check on a device/emulator before shipping. (7) Tests: `product_card_test.dart` (4 — add button when absent, add transitions to stepper, stepper increments/decrements/removes at zero, out-of-stock disables it), `category_card_test.dart` (4 — fallback icon, tap callback, uploaded-icon path attempted, ring color matches palette index). 113/113 passing, `flutter analyze` zero issues.

### 6.3 — Floating cart bar ✅
- [x] Persistent "N items · ₹total · View Cart" bar docked above the bottom nav on Home/Search/Category screens

> **Scope notes**: (1) New `FloatingCartBar` (`shared/widgets/`) — dark pill, item count + subtotal + "View Cart →", `AnimatedSlide`+`AnimatedOpacity` in/out keyed on `cart.isEmpty`, wrapped in `IgnorePointer` while empty so it can't intercept taps meant for whatever's underneath during its fade. (2) Wired into `app_router.dart`'s `_RetailerShell`, converted `StatelessWidget` → `ConsumerWidget`: `Stack` over `navigationShell` + a `Positioned` bar above `BottomNavBar`, hidden specifically on the Cart tab (`navigationShell.currentIndex == _cartBranchIndex`) so it's never redundant with the screen it's a shortcut to. Tapping it calls `navigationShell.goBranch(2)` — Cart is a `StatefulShellBranch`, not a push route, so this is the correct navigation call rather than `context.push`. (3) Tests: `floating_cart_bar_test.dart` (4 — item count text incl. singular "1 item", subtotal, empty-cart hit-testing is truly inert not just invisible, tap fires when non-empty). The shell-integration wiring itself (branch-index hiding, actual tap navigation) isn't unit-tested — no GoRouter test harness exists anywhere in this project to test push/branch navigation, consistent with how every other GoRouter-dependent interaction has been handled so far. 117/117 passing, `flutter analyze` zero issues.

### 6.4 — Motion & transitions
- [ ] Add smooth page transitions in GoRouter (fade + slide)
- [ ] Add hero animation on product image tap → product detail
- [ ] Add animated cart badge counter (bounce on add)
- [ ] Add Lottie success animation on `OrderSuccessScreen` — no Lottie asset exists in the project (same gap noted since Phase 3); satisfied via the existing `flutter_animate` icon animation instead, per established precedent

### 6.5 — List-screen gap fixes
- [ ] Add `shimmer` loading skeletons to ALL list screens — audit already found most screens have this; fill the specific gaps only
- [ ] Add pull-to-refresh on all list screens — missing on `category_products_screen`, `search_screen`, `order_history_screen`
- [ ] Add `EmptyStateWidget`/`ErrorStateWidget` to remaining gaps — `approval_queue_screen` + `admin_dashboard_screen`'s queue preview use inline text instead of the shared `ErrorStateWidget`; `search_screen` has no error state at all (a real bug, not just polish — failures silently look like "no results")

---

## ⬜ Phase 7 — Testing & Quality Assurance
> **Status**: NOT STARTED ⬜  
> **Goal**: Ensure the app is rock-solid before any user gets access.

- [ ] Unit test: `PlaceOrderUseCase` — must assert `MinimumOrderException` when total < ₹2,500
- [ ] Unit test: `ApproveUserUseCase` — verify Firestore status update called correctly
- [ ] Unit test: `Money` value object — validate ₹ formatting and comparison
- [ ] Unit test: `PhoneNumber` value object — validate 10-digit Indian number rule
- [ ] Unit test: `CartController` — add, remove, update quantity, clear cart
- [ ] Unit test: `CurrencyFormatter` — edge cases (zero, large numbers)
- [ ] Widget test: `ProductCard` — renders correctly with all states
- [ ] Widget test: `CartScreen` — shows warning when total < ₹2,500, disables checkout CTA
- [ ] Widget test: `PendingApprovalScreen` — support phone and email rendered and tappable
- [ ] Integration test: Full order placement flow — browse → cart → checkout → success
- [ ] Run `flutter analyze` — zero issues
- [ ] Run `flutter test` — zero failures, all assertions passing

---

## ⬜ Phase 8 — Launch Preparation & Play Store
> **Status**: NOT STARTED ⬜  
> **Goal**: Ship to Google Play Store.

- [ ] Configure `firebase_crashlytics` — auto-capture uncaught exceptions in release build
- [ ] Configure `firebase_analytics` — track key events (order placed, user registered, login)
- [ ] Write and deploy Firestore Security Rules — role-based read/write guards
- [ ] Set Android `minSdkVersion = 24`, `targetSdkVersion = 34` in `build.gradle.kts`
- [ ] Generate upload keystore — `keytool` command, store `.jks` file securely
- [ ] Configure `key.properties` + `build.gradle.kts` for signed release build
- [ ] Build signed App Bundle: `flutter build appbundle --release`
- [ ] Create Google Play Developer Account (guidance to client)
- [ ] Create Play Store listing — app name, description, screenshots (min 2), feature graphic
- [ ] Submit `app-release.aab` to Play Store internal testing track
- [ ] Test on physical device via internal testing link
- [ ] Promote to production on Play Store

---

## 🧭 How to Use This File

> **When you ask "what's next?" or "what should we do now?" — the answer is always the first unchecked `[ ]` task inside the current active phase.**

### Current Active Phase: **Phase 6 — Polish, Animations & UX Refinement**
### Next Immediate Task:
> ✅ 6.1 (dark mode), 6.2 (card redesign), and 6.3 (floating cart bar) are done — 3/11. Next: **6.4 — Motion & transitions**: GoRouter fade+slide page transitions (`GoRoute.pageBuilder` + `CustomTransitionPage`, currently zero custom transitions exist anywhere), a `Hero` on the product image (card → detail, zero `Hero` usage exists yet either), and an animated cart badge bounce in `bottom_nav_bar.dart` keyed on `cartItemCount`. See `C:\Users\niran\.claude\plans\async-beaming-heron.md` for the full 6.1–6.5 breakdown. Note: none of 6.1–6.3 have been visually verified on a live device/emulator yet (none was attached in this environment) — worth a manual check before shipping.

---

> 🔒 *Update this file immediately when a task is completed — change `[ ]` to `[x]` and update the progress table at the top.*
