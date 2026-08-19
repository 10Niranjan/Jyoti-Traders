# 🗺️ PHASES.md
## Jyoti Traders — Master Project Roadmap & Task Tracker

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
| Phase 6 | Polish, Animations & UX Refinement | ✅ Complete | 11/11 |
| Phase 7 | Testing & Quality Assurance | ✅ Complete | 12/12 |
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

> **Scope notes**: (1) `firebase_messaging` added (pre-approved, rules.md §1). Every `FirebaseMessaging` call is wrapped in its own try/catch and degrades to a no-op (`null` token / empty stream) rather than throwing — there's no meaningful "simulation mode" substitute for FCM the way Firestore/Auth have one, so this is the defensive fallback for unconfigured credentials, an unsupported platform, or a test environment with no platform channel registered. Confirmed working: the widget-test smoke test logs `FcmService: permission/token request unavailable, skipping` and continues normally rather than crashing. (2) `AuthRepository.updateFcmToken(uid, fcmToken)` — new method (mirrors `updateProfile`'s mock/Firestore branches) — persists the token on login and again on every `onTokenRefresh` event, via `fcmInitializerProvider`, a plain `Provider<void>` watched once from the app root (`JyotiTradersApp.build()`) so it initializes exactly once per app lifetime regardless of auth state. (3) `firebaseMessagingBackgroundHandler` is a top-level function (required — Firebase launches it in a separate isolate) that only re-initializes Firebase and otherwise no-ops: the OS renders the notification natively from the message's `notification` payload with zero app code needed, and a background isolate can't safely touch the main isolate's already-open Hive boxes. (4) `NotificationsScreen` + `NotificationRepository` are local-only (Hive, no Firestore) per the checklist wording, following the exact same local-only pattern `CartRepository` already established (datasource → repository → controller, no use-case layer, since it's simple CRUD over one Hive box). New `notifications_cache` Hive box. (5) Added a shared `NotificationBellButton` (bell icon + unread-count badge, reusing the `badges` package already used for the cart badge) to both `HomeScreen` (retailer) and `AdminDashboardScreen` — notification history is per-device, not per-role, so both point at the same `/notifications` route. (6) Deliberately did **not** add tap-to-open-order-detail navigation from a notification tile, or a `flutter_local_notifications`-based foreground tray notification (that package isn't on rules.md's approved list) — neither was asked for by this checklist, and the in-app list + bell badge already satisfies it. (7) No Cloud Function actually *sends* these yet (out of scope — this phase only wires the client side), so in practice the notification list will stay empty until a backend sender exists; the plumbing is fully in place for when it does. (8) Tests: `notifications_screen_test.dart` (5), `notification_bell_button_test.dart` (2), plus a new Hive round-trip case in `simulation_backend_test.dart` (add → newest-first ordering → mark-as-read → mark-all-read). 78/78 passing, `flutter analyze` zero issues.

- [x] Implement delivery charge calculation — use `geolocator` to get retailer GPS, calculate distance from warehouse coordinates, multiply by per-km rate set by admin
- [x] Build admin setting for per-km rate in `AdminDashboardScreen`
- [x] Store warehouse lat/long as a Firestore config document

> **Scope notes**: (1) `geolocator` added (pre-approved, rules.md §1) + `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` added to `AndroidManifest.xml`. `LocationService` (`core/services/`) wraps every geolocator call in one try/catch, same defensive-fallback pattern as `FcmService` — no permission/service/platform failure ever throws into UI code. (2) `AddressEntity` gained optional `latitude`/`longitude` (nullable, backward compatible) plus a `hasCoordinates` getter — populated only once a retailer taps "Use current location" while editing their address in `ProfileScreen` or `CheckoutScreen`. Extracted the now-4-field address form (street/city/pincode/location-button) both screens previously duplicated into a shared `AddressFormFields` widget. (3) Real distance math is Haversine, hand-rolled as a pure-Dart `calculateDistanceKm()` (`core/utils/distance_calculator.dart`) rather than depending on `geolocator` from the domain layer — `geolocator` is a plugin package and the domain layer must stay plugin-free; only `LocationService` (core, not domain) touches it. `CalculateDeliveryChargeUseCase` returns `null` when the address has no coordinates yet, and `CheckoutScreen` falls back to the pre-existing flat `kStubDeliveryCharge` in that case — rules.md §10 requires a delivery charge is always calculated and shown, so it's never left blank. (4) New `DeliveryConfigRepository`/`DeliveryConfigEntity` — the **first single-document Firestore repository in this codebase** (`config/delivery`, vs. every prior repository being a collection of many docs), with the same Hive-simulation fallback dual-mode pattern as the rest, reusing the existing `settings_cache` box (no new box needed). Seeded with a documented bootstrapping default (central-India coordinates, ₹10/km per PRD §4.4's own example) until the admin sets the real warehouse location. (5) `DeliverySettingsScreen` — admin edits warehouse lat/lng (with its own "use current location" shortcut) and the per-km rate; added as a new full-width button on `AdminDashboardScreen`. The read-side `deliveryConfigProvider` is shared between this screen and `CheckoutScreen` (both need the live config), while the write side (`AdminDeliveryConfigController`) is admin-only. (6) Tests: `distance_calculator_test.dart` (3 — zero distance, a known Mumbai–Pune sanity check, symmetry), `calculate_delivery_charge_usecase_test.dart` (3 — null without coordinates, distance×rate, zero at the warehouse), `delivery_settings_screen_test.dart` (3 — pre-fill, rate validation, save+confirm), plus a new Hive round-trip case in `simulation_backend_test.dart` (default fallback → admin update persists). 88/88 passing, `flutter analyze` zero issues.

- [x] UPI Payment Screen — display UPI QR image + UPI ID `(owner's UPI details)`, "I have paid" confirmation button, upload payment screenshot (optional)
- [x] Admin marks order as paid manually after UPI confirmation
- [x] COD — no extra steps, order placed immediately (unchanged since Phase 3)

> **Scope notes**: (1) **No real UPI ID/QR was ever provided by the client** (checked agents.md's client-spec notes — only "Cash on Delivery (COD) & Online UPI" is on file, no actual ID). `AppConstants.kUpiId`/`kUpiPayeeName` are explicit, documented placeholders (`jyotitraders@upi`) — swap them before launch; nothing else in the flow needs to change. (2) Added `qr_flutter` — **explicitly approved by the user this session** (rules.md §11) — to render a real, scannable QR client-side from a standard `upi://pay?...` deep link (amount + payee + a note carrying the order's short id), rather than shipping a static image asset that doesn't exist. Also added to `rules.md` §1 and `ARCHITECTURE.md` §2.7's approved-package tables per rules.md's own documentation requirement. (3) `CheckoutScreen`'s payment method was previously hardcoded to COD with no way to actually select UPI (a gap versus rules.md §10's "COD / UPI only" business rule, which implies retailers can pick either) — added a `RadioListTile` selector; UPI orders now route to the new `UpiPaymentScreen` after placement instead of straight to `OrderSuccessScreen` (PRD §7: "Order placed → UPI payment screen shown → ... → Admin confirms order"). (4) Extended `PaymentStatus` with a third state, `paymentClaimed` — the retailer's "I have paid" tap — sitting between `pending` and `paid` so the admin can see who's claimed payment vs. never touched it, matching PRD §7's flow literally (never used for COD). New `OrderRepository.recordPaymentClaim()` (retailer, sets status + optional screenshot URL in one write) and `.updatePaymentStatus()` (admin-only "Mark as Paid" in `OrderManagementScreen`, added to the existing `OrderDetailBody` via its `paymentExtra` slot, mirroring the existing `header` slot pattern from 4.5). (5) `OrderEntity.paymentScreenshotUrl` (nullable) — the uploaded screenshot is rendered back in `OrderDetailBody`'s Payment section for both the retailer and the admin, not just written to Storage and forgotten, since an upload nobody can ever view would be a half-finished feature. Reused `ImageUploadService` (Phase 4.3) with a new `uploadPaymentScreenshot()` method. (6) **Refactor while here**: `imageUploadServiceProvider` moved from `admin_product_controller.dart` into `core/services/image_upload_service.dart` (mirrors `locationServiceProvider`'s precedent from the delivery-charge work) since checkout — a retailer feature — now needs it too and importing it from an admin controller file was the wrong direction of coupling. Similarly renamed/relocated `features/admin/widgets/product_image_picker_field.dart` → `shared/widgets/image_picker_field.dart` (`ProductImagePickerField` → `ImagePickerField`) now that it's used by product photos, category icons, *and* UPI screenshots — it was already fully generic, just misfiled. (7) **Real bug found and fixed immediately**: `OrderSuccessScreen` had the exact same unguarded `order.id.substring(0, 8)` `RangeError` risk fixed elsewhere in Phase 4.5, just in a file that phase never touched — fixed via the existing `String.shortId` extension. (8) Tests: `record_payment_claim_usecase_test.dart` (2), `update_payment_status_usecase_test.dart` (1), 3 new cases in `order_management_screen_test.dart` (COD hides payment UI, UPI shows status + working Mark-as-Paid, already-paid hides the button), `upi_payment_screen_test.dart` (3 — amount/UPI-id render, copy-to-clipboard, not-found state; introduces this codebase's first `authControllerProvider`-backed widget test, via overriding `authRepositoryProvider` with a fake that immediately emits a signed-in retailer). 97/97 passing, `flutter analyze` zero issues.
> **Phase 5 complete.** All 10 tasks done.

---

## ✅ Phase 6 — Polish, Animations & UX Refinement
> **Status**: COMPLETE ✅ (6.1–6.3: 2026-07-23; 6.4–6.5: 2026-07-26)  
> **Goal**: Elevate the app from functional to premium — plus a Blinkit/Zepto-style
> quick-commerce visual pass the client approved from a mockup. Broken into 6.1–6.5
> sub-phases (this project's own convention, mirroring Phases 4–5) even though the
> original checklist below was a flat list.
>
> **Scope note**: the original checklist had 9 items; 6.2 (card redesign) and 6.3
> (floating cart bar) are net-new scope from the approved visual-direction mockup, not
> in that original 9 — progress below is tracked out of 11 to reflect the real total.
>
> **Brand palette revised 2026-07-24**: the visual-direction mockup offered 4 palette
> options (Wholesale Blue / Fresh Green / Zepto Violet / Sunset Coral). On first review
> the client picked Wholesale Blue (the original brand color, kept as-is) — 6.1–6.3 above
> were built on top of it. On a second look, the client changed their mind and picked
> **Zepto Violet** instead. Applied by updating `AppColors.primary`/`primaryLight`/
> `primaryDark` (`#7C3AED`/`#A78BFA`/`#5B21B6`) and `accent`/`accentLight` (`#0D9488`
> Teal/`#2DD4BF`) — since every screen already sources color exclusively through
> `AppColors.*` tokens (rules.md §9, no raw hex outside `app_colors.dart`), this is a
> single-file change that automatically re-colors 6.1–6.3's UI too, no per-screen
> rework needed. `AppColors.categoryPalette` (category ring colors) was decoupled from
> `primary`/`accent` in the same edit — it previously reused those two as its first two
> entries, which would have produced literal duplicate colors once they became
> Violet/Teal, since the mockup's 6-color category ring set already includes both hues
> independently. `flutter analyze` zero issues, all 117 tests still pass unmodified.

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

### 6.4 — Motion & transitions ✅
- [x] Add smooth page transitions in GoRouter (fade + slide)
- [x] Add hero animation on product image tap → product detail
- [x] Add animated cart badge counter (bounce on add)
- [x] Add Lottie success animation on `OrderSuccessScreen` — no Lottie asset exists in the project (same gap noted since Phase 3); satisfied via the existing `flutter_animate` icon animation instead, per established precedent

> **Scope notes**: (1) New `_fadeSlidePage(child, state) → CustomTransitionPage<void>` helper near the top of `app_router.dart` — a single shared fade+slide transition (300ms fade via `easeOut`, slide up from `Offset(0, 0.04)` via `easeOutCubic`). Applied to the 7 retailer-facing push routes (`productCategory`, `productDetail`, `checkout`, `upiPayment`, `orderSuccess`, `orderDetail`, `notifications`), converting each from `builder:` to `pageBuilder:`. Admin routes and the shell's own tab switches were deliberately left untouched — out of scope. (2) **Hero image, with a real async-timing fix**: `Hero(tag: 'product-image-${product.id}')` wraps the image in both `ProductCard` and `ProductDetailScreen`. `ProductDetailScreen` needed a structural change beyond just adding the tag — `productByIdProvider` is a `FutureProvider`, and the screen originally only rendered the image inside the `data` branch of `productAsync.when()`. Since GoRouter's Hero flight scan runs on the very first frame after a push, a Hero that only exists once the future resolves would never be present in time and the flight would silently never fire. Fixed by hoisting the `Hero`-wrapped image above the `.when()` switch, keyed on the route's `productId` (known synchronously) with a placeholder box shown during loading/error/not-found — so the same Hero is mounted from frame one regardless of async timing, and the flight reliably triggers every time. (3) Cart badge bounce: the `badges.Badge` in `bottom_nav_bar.dart` is now `.animate(key: ValueKey(cartItemCount))` with a two-step scale (1→1.3→1, 120ms/150ms) — keying on the count itself means `Animate`'s internal state restarts (and the bounce replays) only when the count actually changes, not on unrelated rebuilds. (4) **Real pre-existing bug found and fixed during device verification** (unrelated to this checklist, but found while visually testing the Hero/transition work on a physical Android device): `category_products_screen.dart`'s `GridView` used `childAspectRatio: 0.68`, which was too tight for any product with a 2-line name (e.g. the seeded "Basmati Rice Premium 25kg") — a real `RenderFlex` overflow (visible yellow/black debug banner in debug builds; silent clipping in release). Fixed by loosening to `0.62`, giving enough vertical headroom for a full 2-line name plus price/stepper row. This predates 6.4 (introduced in 6.2's card redesign) and was never caught because no widget test constrains `ProductCard` inside the real grid's aspect ratio — only a fixed `SizedBox(width: 170)` (see 6.2's own test-infra note). (5) **Visually verified on a physical device** (Xiaomi/Redmi, Android 13, connected via `adb`) for the first time this project — every prior Phase 6 sub-phase (6.1–6.3) had only been checked via widget tests, with a physical/emulator check explicitly flagged as outstanding. Confirmed via screenshots: fade+slide transition on Home→Category, Category→Product Detail, Cart→Checkout, and Home→Notifications; Hero-wrapped image renders correctly with no crash on both ends; cart badge count and floating cart bar update correctly through add/qty-change; the grid overflow fix renders cleanly across multiple categories. (6) Tests: no new automated tests — page-transition curves, `Hero` flights, and keyed-restart animations aren't meaningfully unit-testable in this codebase's existing test harness (no GoRouter push/pop test harness exists, consistent with every prior GoRouter-dependent interaction). Verified instead by `flutter analyze` (zero issues) + `flutter test` (117/117 passing, unchanged) + the on-device pass above. Also fixed one incidental `curly_braces_in_flow_control_structures` lint in `app_router.dart`'s `SplashScreen` that `dart format`'s reformatting of the touched file exposed (pre-existing single-line `if (...) return;` that word-wrapped once the surrounding animation chain was reformatted).

### 6.5 — List-screen gap fixes ✅
- [x] Add `shimmer` loading skeletons to ALL list screens — re-audited against current code (not just the earlier plan file); every list/grid screen already had shimmer coverage, no gaps found
- [x] Add pull-to-refresh on all list screens — was missing on `category_products_screen`, `search_screen`, `order_history_screen`
- [x] Add `EmptyStateWidget`/`ErrorStateWidget` to remaining gaps — `approval_queue_screen` + `admin_dashboard_screen`'s queue preview now use the shared `ErrorStateWidget`; `search_screen` now has a real error state (was a real bug, not just polish — failures silently looked like "no results")

> **Scope notes**: (1) **Real bug fixed**: `SearchState` had no error field at all — `SearchController._search()`'s `catch` block just set `results: []`, so a genuine repository failure was visually indistinguishable from "nothing matched." Added `SearchState.hasError` (set on catch, cleared on every new attempt) and a `SearchController.retry()` method (returns the in-flight `Future<void>` rather than `void`, so `RefreshIndicator` and the error state's retry button both reflect real completion, not just the sync half of an `async` wrapper). `search_screen.dart`'s `_SearchResults` now checks `hasError` before falling through to the "no results" empty state. (2) **Pull-to-refresh** added to `category_products_screen.dart` (`ref.invalidate(productsByCategoryProvider(...))`), `order_history_screen.dart` (`ref.invalidate(orderHistoryProvider)`), and `search_screen.dart` (`notifier.retry`) via `RefreshIndicator`. Following the exact pattern already established by `manage_products_screen.dart`/`approval_queue_screen.dart`: the error and empty-data branches are wrapped in a plain `ListView(children: [...])` (not left as a bare centered widget) specifically so the pull gesture still has a scrollable surface to attach to even when there's no grid/list of real items to scroll. (3) **ErrorStateWidget swap**: `approval_queue_screen.dart` and `admin_dashboard_screen.dart`'s inline `Text('Couldn\'t load approval queue: $e', ...)` error branches replaced with the shared `ErrorStateWidget(message:, onRetry:)` component already used everywhere else in the app — pure presentation change, no behavior change, `onRetry` still calls the same `ref.invalidate(pendingUsersProvider)`. (4) `notifications_screen.dart` was deliberately **not** given pull-to-refresh — its `notificationsProvider` is a live `StreamProvider` over local Hive data with no remote fetch to re-trigger, so a refresh gesture would be a UX no-op; it already has shimmer/error/empty via the shared widgets. (5) Tests: 3 new cases in `search_controller_test.dart` (a repository failure sets `hasError` instead of faking "no results"; `retry()` re-runs the last query and clears the error on success; `retry()` is a no-op with no active query) — 120/120 passing, `flutter analyze` zero issues. (6) **Visually verified on the same physical device** used for 6.4: re-confirmed the category grid still renders cleanly, searched for a real product and pulled-to-refresh on category/search/order-history with no crashes, and confirmed the approval queue's/dashboard's empty and (now-shared) error widgets render correctly for an admin login. The `hasError`/inline-error-text branches themselves can't be organically triggered in Hive-simulation mode (no real network to fail) — correctness there rests on `flutter analyze` + the new unit tests + the identical `ErrorStateWidget` already proven working live elsewhere in the app (order history, product detail, notifications).
> **Phase 6 complete.** All 11 tasks across 6.1–6.5 done.

---

## ✅ Phase 7 — Testing & Quality Assurance
> **Status**: COMPLETE ✅ (2026-07-31)  
> **Goal**: Ensure the app is rock-solid before any user gets access.

- [x] Unit test: `PlaceOrderUseCase` — must assert `MinimumOrderException` when total < ₹2,500 — already existed (`test/unit/usecases/place_order_usecase_test.dart`, from Phase 3's own bug-fix habit)
- [x] Unit test: `ApproveUserUseCase` — verify Firestore status update called correctly — already existed (`test/unit/usecases/approve_user_usecase_test.dart`)
- [x] Unit test: `Money` value object — validate ₹ formatting and comparison — already existed (`test/unit/value_objects/money_test.dart`)
- [x] Unit test: `PhoneNumber` value object — validate 10-digit Indian number rule — already existed (`test/unit/value_objects/phone_number_test.dart`)
- [x] Unit test: `CartController` — add, remove, update quantity, clear cart, stream-driven state (`test/unit/controllers/cart_controller_test.dart`)
- [x] Unit test: `CurrencyFormatter` — zero, Indian digit grouping on large numbers, paise rounding for slab-priced part-kilos (`test/unit/utils/currency_formatter_test.dart`)
- [x] Widget test: `ProductCard` — renders correctly with all states — already existed (`test/widget/product_card_test.dart`)
- [x] Widget test: `CartScreen` — empty state, ₹2,500-minimum warning/checkout-gating, delete, qty stepper (`test/widget/cart_screen_test.dart`)
- [x] Widget test: `PendingApprovalScreen` — support phone/email rendered and tappable, sign-out action (`test/widget/pending_approval_screen_test.dart`)
- [x] Integration test: Full order placement flow — browse → cart → checkout → success, plus the below-minimum rejection path — driven through the real repositories/controllers against the Hive simulation backend, not mocks (`test/integration/order_placement_flow_test.dart`)
- [x] Run `flutter analyze` — zero issues
- [x] Run `flutter test` — zero failures, 163/163 passing

> **Scope note**: An audit against the actual `test/` tree (not just this checklist) found 6 of the 12 items already covered as a side effect of earlier phases' "found a bug, added a regression test" habit — only `CartController`, `CurrencyFormatter`, `CartScreen`, `PendingApprovalScreen`, and the integration test were genuinely missing. All five added this session, matching this codebase's existing conventions (`mocktail` for repository mocks, `FakeCartRepository`/`test_viewport.dart` helpers reused rather than re-created, the Hive-temp-dir pattern from `simulation_backend_test.dart` for the integration test).
> **Phase 7 complete.** All 12 tasks done.

---

## 🔶 Phase 8 — Launch Preparation & Play Store
> **Status**: IN PROGRESS 🔶 (started 2026-08-19)  
> **Goal**: Ship to Google Play Store.

- [x] Configure `firebase_crashlytics` — auto-capture uncaught exceptions in release build

> **Scope note**: `firebase_crashlytics` was already pre-approved in rules.md/ARCHITECTURE.md but never wired up. Hooked `FlutterError.onError` → `FirebaseCrashlytics.instance.recordFlutterFatalError` and `PlatformDispatcher.instance.onError` → `recordError(fatal: true)` in `main.dart`, right after the existing Firebase/FCM init block. `setCrashlyticsCollectionEnabled(kReleaseMode)` gates collection to release builds only, so local dev/debug errors and the test suite's expected simulation-mode fallbacks don't get reported. Follows the same defensive try/catch pattern as every other Firebase call in `main.dart` — setup failure degrades to a debug print, never a crash. `flutter analyze` zero issues, `flutter test` 225/225 passing (unchanged, this branch's prior Change Password/Settings work already added tests up to 225).
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

## ✅ Phase 9 — Navigation Redesign
> **Status**: COMPLETE ✅ (2026-08-19)
> **Goal**: Close the usability gap with Zepto/Blinkit — retailer side mostly needs richer Home/Orders content (already Zepto-shaped structurally); admin side needs an actual persistent shell instead of one dashboard hub pushing to 11 screens. Full plan (nav diagrams, screen-by-screen breakdown, old→new mapping table) was published as an Artifact and approved before starting.

### 9.1 — Admin shell scaffold ✅
- [x] New `_AdminShell` + `AdminBottomNavBar`, reusing the retailer app's proven `StatefulShellRoute.indexedStack` pattern
- [x] 5 tabs: Dashboard, Orders, Catalog, Retailers, Profile

> **Scope note**: (1) Reused the *exact same* three existing route paths (`/admin`, `/admin/orders`, `/admin/retailers`, `/admin/profile`) as the new shell's branch roots — `route_names.dart`'s own "routes are contractual" comment made this the deciding factor over inventing new paths. Grepped every call site pushing to these paths first: all three (`adminOrders`, `adminRetailers`, `adminProfile`) were only ever pushed from `AdminDashboardScreen`'s own buttons — `context.push()` targeting a path that's now a `StatefulShellRoute` branch root, called from *inside* that same shell, doesn't switch tabs correctly (GoRouter pushes onto the current branch's stack instead), so those 3 call sites were changed to `context.go()`, which does perform a correct branch switch. Every other admin route (`adminProducts`, `adminCategories`, `adminDeliverySettings`, `adminApprovalQueue`, and the parameterized detail routes) was left completely untouched — no path collision, no behavior change. (2) **Catalog** (`/admin/catalog`, new path) and **Retailers** currently host single existing screens (`ManageProductsScreen`, `RetailerListScreen`) as honest placeholders — a real working screen, not a stub — until 9.4/9.5 turn them into Products|Categories and Approved|Pending segmented hosts. (3) Extracted the "Exit app?" `PopScope` confirmation (previously only on `_RetailerShell`) into a shared `_confirmExitApp()` helper so `_AdminShell` gets the same back-button behavior without duplicating the dialog. (4) `AdminDashboardScreen` itself is untouched otherwise — its 6 nav buttons still work (now via `go` for 3 of them) but are now partially redundant with the bottom nav; trimming them is 9.2's job, not 9.1's. (5) No GoRouter test harness exists in this project (documented gap since Phase 6.4) — verified via `flutter analyze` (zero issues) and `flutter test` (250/250 passing, unchanged — the smoke test renders the full router without crashing). Live on-device click-through deferred — phone was disconnected when this landed; verify before starting 9.2.

### 9.2 — Trim the Dashboard tab ✅
- [x] Remove nav buttons now fully covered by a bottom-nav tab
- [x] Keep the ones that would otherwise strand a feature with no way to reach it

> **Scope note**: (1) Re-audited each of the 6 buttons individually rather than removing all of them as originally sketched in the roadmap — only 3 were actually safe: **Manage Products** (Catalog tab already shows this exact screen), **All Orders**, **Retailers** (both now covered 1:1 by their tabs), plus the AppBar's Profile icon (redundant with the Profile tab). **Manage Categories**, **Delivery Settings**, and the Approval Queue's "View All" were *kept* — none of them has a tab home yet (that's 9.4, 9.6, 9.5 respectively), so removing them now would have stranded three real features with zero way to reach them, not just tidied up a redundancy. (2) The two surviving buttons (Categories, Delivery Settings) were compacted from two rows of two down to one row of two now that Products/Orders/Retailers are gone. (3) Stat cards, the orders chart, and the approval-queue preview are all untouched — they're dashboard content, not navigation. (4) Tests: no changes needed — `admin_dashboard_screen_test.dart` only ever asserted on stat/chart/queue content, never the removed buttons. 250/250 passing, `flutter analyze` zero issues.

### 9.3 — Orders tab verification ✅
- [x] Confirm `AllOrdersScreen` needs no changes to work as the Orders tab root

> **Scope note**: Pure verification, no code changes needed — `AllOrdersScreen` was already written without any back-arrow assumption (no `leading:`, no `Navigator.pop`/`context.pop` anywhere in the file), so Flutter's automatic AppBar back button already correctly disappears now that it's a tab root with nothing to pop, exactly like `OrderHistoryScreen` already does on the retailer side. Re-grepped `RouteNames.adminOrders` project-wide to confirm zero remaining `push`/`go` call sites outside the router itself (9.2 removed the last one). The parameterized `adminRetailerOrders` route (`/admin/retailers/:retailerId/orders`) is untouched and still correctly pushed with a back arrow — it's a drill-down, not a tab. CSV export and status filter chips both re-verified working via the existing test suite. 250/250 passing, `flutter analyze` zero issues.

### 9.4 — Catalog tab (Products/Categories segmented) ✅
- [x] New `CatalogScreen` — a `TabBar`/`TabBarView` host, mirroring `AdminProfileScreen`'s existing internal-tabs pattern
- [x] Products and Categories folded in as segments, each keeping its existing FAB and full behavior

> **Scope note**: (1) The risk here was breaking two screens with solid existing test coverage while merging them — avoided by **not** touching `ManageProductsScreen`/`ManageCategoriesScreen`'s rendered behavior at all. Instead, extracted each screen's list body (the `RefreshIndicator`+`.when()` content) into a new standalone widget — `ProductsListView`, `CategoriesListView` — with no `Scaffold`/`AppBar`/FAB of its own. `ManageProductsScreen`/`ManageCategoriesScreen` became thin wrappers (`Scaffold` + `AppBar` + FAB + the extracted body) that render an *identical* widget tree to before, so every existing test in `manage_products_screen_test.dart`/`manage_categories_screen_test.dart` passed unmodified — zero test rewrites needed. (2) Each screen's `FloatingActionButton.extended` ("Add Product"/"Add Category") was similarly extracted into a public `AddProductFab`/`AddCategoryFab` widget (had to be public, not `_private` — a private class can't be imported into `catalog_screen.dart`; caught this at compile time before it ever ran). (3) New `CatalogScreen` owns one `Scaffold` with `AppBar(bottom: TabBar(...))` + `TabBarView([ProductsListView(), CategoriesListView()])`, exactly mirroring `AdminProfileScreen`'s existing `TabController`/`SingleTickerProviderStateMixin` pattern — no new UI mechanism introduced. Its `floatingActionButton` swaps between `AddProductFab`/`AddCategoryFab` by listening to the `TabController` and calling `setState`. (4) `AdminDashboardScreen`'s "Manage Categories" button — kept in 9.2 specifically because Categories had no tab home yet — is now genuinely redundant and was removed, leaving only "Delivery Settings" as the dashboard's sole surviving quick action (until 9.6). (5) The flat `/admin/products` and `/admin/categories` routes are left in the router, now unreferenced by any in-app navigation but still fully working as direct links — deliberately not deleted, since removing routes is a separate decision from this phase's scope and the dead routes are harmless. (6) Tests: new `catalog_screen_test.dart` (3 — Products segment is the default with its FAB, switching tabs shows Categories content and swaps the FAB, empty states render correctly on both segments). 253/253 passing, `flutter analyze` zero issues.

### 9.5 — Retailers tab (Approved/Pending segmented) ✅
- [x] New `RetailersScreen` — same `TabBar`/`TabBarView` pattern as Catalog (9.4)
- [x] Approve/reject moved inline into the Pending segment, with a live count badge on the tab itself

> **Scope note**: (1) Same extraction discipline as 9.4 — `RetailerListScreen`'s body became `ApprovedRetailersListView`, `ApprovalQueueScreen`'s body became `PendingRetailersListView`, both with no `Scaffold`/`AppBar` of their own, and every existing test kept asserting on the same rendered content. (2) **One real difference from 9.4, caught by reasoning through it rather than assuming symmetry**: Catalog's two source screens (`ManageProductsScreen`/`ManageCategoriesScreen`) each had their *own* pre-existing, independent route (`/admin/products`, `/admin/categories`) separate from the new `/admin/catalog` tab path — so both could stay alive as working standalone screens after the merge. Retailers is structurally different: `/admin/retailers` was *already* `RetailerListScreen`'s only route (assigned to the tab back in 9.1), so after extracting its body there was nothing left for the wrapper screen to do — no separate path was ever going to keep it reachable. Rather than inventing a new route just to justify keeping an unreachable class around, `RetailerListScreen` was deleted outright and the file renamed to `approved_retailers_list_view.dart` to match what it actually contains now; its test was migrated (not rewritten from scratch — same fakes, same assertions, `MaterialApp(home: X)` → `MaterialApp(home: Scaffold(body: X))` since it's no longer a full screen). `ApprovalQueueScreen`, by contrast, *does* still have its own distinct `/admin/approval-queue` route (used by the dashboard's existing "View All" preview), so it was kept exactly like Catalog's siblings — a thin, working, unreferenced-but-reachable-by-direct-link wrapper, refresh button and all. (3) The dashboard's "Retailer Approval Queue" preview section + "View All" button were deliberately left untouched — it's glanceable content, not pure navigation, so it doesn't fit the "delete once redundant" treatment 9.2's nav buttons got. (4) The Pending tab's label shows a live `(N)` count (via the same `pendingApprovalsCountProvider` the dashboard's stat card already uses) when the queue isn't empty, and just "Pending" when it is — so the number of retailers waiting is visible without switching tabs. (5) Tests: new `retailers_screen_test.dart` (3 — Approved is the default segment, switching to Pending shows the count badge and the approve/reject cards, the badge disappears at zero) plus the migrated `approved_retailers_list_view_test.dart` (3, unchanged assertions). 256/256 passing, `flutter analyze` zero issues.

### 9.6 — Delivery Settings folded into Profile ✅
- [x] `DeliverySettingsScreen`'s form embedded into the admin Profile tab instead of living behind a separate push

> **Scope note**: (1) Different shape from 9.4/9.5 on purpose — Delivery Settings only ever had *one* home screen (no sibling to segment against), so a `TabBar` merge didn't fit. Extracted the form into `DeliveryConfigFormView` (same `Scaffold`/`AppBar`-stripping discipline as before — it already handled its own scrolling/keyboard-avoidance via `SingleChildScrollView`, so nothing about the form itself needed to change) and embedded it in a `showModalBottomSheet` from `AdminProfileScreen`'s existing "Delivery Settings" list tile — reusing the *exact* sheet pattern (`isScrollControlled: true`, rounded-top shape) that tile's neighbor, "Edit Profile", already uses via `EditBasicInfoSheet`. No new interaction pattern introduced. (2) This is a `ConsumerStatefulWidget`, not a stateless list body like 9.4/9.5's extractions — it owns `TextEditingController`s with real lifecycle (`dispose()`), so the extraction preserved the full `State` class, not just a `build()` method. (3) Removing the tile's `context.push(RouteNames.adminDeliverySettings)` call left both the `go_router` and `route_names.dart` imports unused in `admin_profile_screen.dart` — caught and removed by `flutter analyze`, not missed. (4) `DeliverySettingsScreen` (thin wrapper) and its `/admin/delivery-settings` route are kept, same as Catalog's siblings — a working, unreferenced-but-reachable direct link. (5) Tests: `delivery_settings_screen_test.dart` passed unmodified (3, zero rewrites — same pattern as 9.4/9.5). Two new cases added to `admin_profile_screen_test.dart`: tapping "Delivery Settings" opens the sheet pre-filled from the live config, and saving from the sheet actually persists through `DeliveryConfigRepository`. 258/258 passing, `flutter analyze` zero issues.

> **9.1–9.6 complete — the admin shell restructure is done.** Dashboard, Orders, Catalog, Retailers, and Profile are all real, persistent tabs; every screen that used to live behind a dashboard button now has an actual home. What's left in Phase 9 is retailer-side content (9.7–9.8) and the final regression pass (9.9).

### 9.7 — Retailer Home content (Buy Again rail + low-stock banner) ✅
- [x] Buy Again rail — frequently-bought products, one-tap add, on Home
- [x] Low-stock banner surfacing the same alert Notifications already carries

> **Scope note**: (1) The roadmap originally called for *two* rails — "Buy Again" and "Frequently Bought" — but both would have pulled from the exact same underlying signal (`frequentlyBoughtProductIdsProvider`, ≥2 past orders). Shipping two near-identical horizontal rails would've been redundant UI for no added value, so this became **one** rail, named "Buy Again" (matches the reference apps' own naming). (2) Zero new product-tile widget — `ProductCard` was already built (Phase 6.2's own doc note) to work at any width as long as it's given one, so the rail just wraps each card in `SizedBox(width: 150)` inside a horizontal `ListView.separated`, the same trick its own widget test already used. (3) New `allActiveProductsProvider` (made public; was already computed privately inside `stock_alert_controller.dart` for the low-stock check) + new `frequentlyBoughtProductsProvider` — same frequent-id/product-stream join as the existing `lowStockFrequentProductsProvider`, just without the stock filter. All three now live together since they share the same two dependencies. (4) The low-stock banner reuses `lowStockFrequentProductsProvider` directly — no new computation, just a second surface for data that already drives the Notifications-screen alert (Post-Launch Feature Additions), shown a layer higher so it doesn't require opening Notifications to notice. Tapping it opens Notifications. (5) Both sections render `SizedBox.shrink()` (zero footprint) when empty, so a new retailer with no order history sees exactly the old Home layout — nothing added, nothing missing. (6) **Real bug caught by the test suite, not eyeballing**: the rail's fixed height (guessed at 245px) overflowed `ProductCard`'s internal `Column` by 1.5px at the rail's 150px width — invisible in a quick visual check, but `flutter test` failed loudly on it. Bumped to 260px. (7) This is the first test file for `HomeScreen` — also surfaced (and worked around) a real gotcha: `ProductCard` reads `cartControllerProvider`, which needs `cartRepositoryProvider` overridden with the project's existing `FakeCartRepository` or it throws a raw `HiveError` trying to open a real box that doesn't exist in the test environment. Tests: `home_screen_test.dart` (5 — rail shows for a repeat product, hides for a one-time order, low-stock banner shows/hides correctly, category grid still renders beneath everything). 263/263 passing, `flutter analyze` zero issues.

### 9.8 — Retailer Orders content (filter chips + tracking stepper) ✅
- [x] Status filter chips on `OrderHistoryScreen`, mirroring the admin's `AllOrdersScreen`
- [x] Visual tracking stepper on `OrderDetailBody`, replacing the flat badge as the primary status read

> **Scope note**: (1) `AllOrdersScreen`'s filter chip was a private `_FilterChip` class — now used identically in two screens, so it was promoted to a shared `StatusFilterChip` (`shared/widgets/`) rather than duplicated verbatim into `order_history_screen.dart`. `AllOrdersScreen` was updated to use the shared version too, so both filter rows are now provably identical, not just visually similar. (2) `OrderHistoryScreen` converted from `ConsumerWidget` to `ConsumerStatefulWidget` to hold `_filter` state — same shape as `AllOrdersScreen`'s own conversion, same `_filteredOrders`-style logic inline. (3) New `OrderTrackingStepper` (`shared/widgets/`) — a vertical timeline (Placed → Confirmed → Out for Delivery → Delivered), added into the *shared* `OrderDetailBody` (not just the retailer screen) since it's the same "where is this order" information the admin's status dropdown already edits — matches how `OrderStatusBadge` was already shown to both roles without issue. A cancelled order renders as a single distinct "Order Cancelled" row instead of the linear stepper, since cancellation is a branch, not a stalled step on the way to delivered. (4) **Real regression caught by the existing test suite, not new tests**: adding the stepper pushed `OrderDetailBody`'s Payment section further down, past what fits in the default 800×600 test surface — `order_management_screen_test.dart` started failing to find "Payment claimed…"/"Paid" text that was still on-screen in a real device, just outside what a `SliverList` inflates in a default-sized test. This exact gotcha is already documented in this codebase's own `test_viewport.dart` from Phase 6.1 — fixed by adding the same `useTallTestViewport()` call already used elsewhere, not by touching the stepper. (5) Tests: `order_tracking_stepper_test.dart` (3 — full 4-step stepper for a normal status, single cancelled row for a cancelled order, no overflow across every `OrderStatus`), `order_history_screen_test.dart` (4, first coverage for this screen — empty state, lists by default, filtering hides/shows correctly, status-specific empty message). 270/270 passing, `flutter analyze` zero issues.

### 9.9 — Final regression pass ✅
- [x] `flutter analyze` / `flutter test` re-verified clean across the whole Phase 9 diff
- [x] `README.md` updated

> **Scope note**: (1) `flutter analyze` and `flutter test` had already been re-run clean after every individual sub-phase (9.1–9.8), so this pass was a final confirmation across the accumulated diff rather than the first check — 270/270 passing, zero analyzer issues. (2) `dart format` was run against every file this phase actually touched (already done per sub-phase) plus, as a final check, the small set of files that were *already* modified in the working tree before this session started (from the earlier app rename) — 7 files needed reformatting, all now clean. Deliberately did **not** run `dart format` across the full `lib/`+`test/` tree: that flagged 142 completely untouched files (a pre-existing formatter-version drift, unrelated to this project's own history), and reformatting them would have buried this phase's real diff in unrelated noise — out of scope for a regression pass on Phase 9's own changes. (3) Reformatting `pending_approval_screen.dart` exposed one pre-existing `curly_braces_in_flow_control_structures` lint (a single-line `if (...) return;` that word-wrapped once reformatted) — the exact same class of issue Phase 6.4's own scope note already documented happening once before. Fixed the same way: wrapped in braces. (4) `README.md`'s Status section now lists Phase 9 as complete. Final tally for this session's Phase 9 work: 11 new files, 2 deleted (an orphaned screen + its test, superseded by extraction), ~25 files touched, 270/270 tests passing (up from 250 at Phase 9's start), `flutter analyze` zero issues throughout.

> **Phase 9 complete — 9/9.** Admin has a real persistent shell (Dashboard/Orders/Catalog/Retailers/Profile, 9.1–9.6); retailer Home surfaces reorder/low-stock content and Orders reads its status visually instead of as a single word (9.7–9.8).

---

## ✅ Post-Launch Feature Additions
> Not part of the original PRD/phases checklist — requested ad hoc alongside Phase 8. Logged here so future sessions have the same context as a numbered phase.

### Reorder, cancellation, exports & alerts (2026-08-19)
- [x] "Buy Again" — reorder every item from a past order in one tap
- [x] Retailer self-service order cancellation within a 10-minute window
- [x] Low-stock / out-of-stock local notification for a retailer's frequently-bought products
- [x] CSV export of orders for the admin
- [x] Order confirmation share (WhatsApp/SMS/email via the OS share sheet)

> **Scope notes**: (1) **Buy Again** — `OrderDetailScreen` (now `ConsumerStatefulWidget`) gained a bottom action row. Re-adds each line via `ProductRepository.getProductById` and the *live* product's price/stock/rateSlabs, never the order's frozen price — a reorder is a new cart line, not a copy of an old invoice. Missing/inactive/out-of-stock products are skipped and counted; qty is capped at the product's current `maxQty`. Snackbar reports "N added / M no longer available" with a View Cart shortcut. (2) **Cancellation** — new `OrderStatus.cancelled` (exhaustiveness-checked into `extensions.dart`'s label switch and `OrderStatusBadge`'s color switch by the compiler). `OrderEntity.isCancellable` gates on `orderStatus == pending` and a `DateTime.now()`-based window (`AppConstants.kOrderCancellationWindowMinutes = 10`), same impure-getter style as the existing `DateTimeAgoExtension.timeAgo`. New `RetailerOrderController.cancelOrder` reuses the existing `UpdateOrderStatusUseCase` — no new repository method needed, since `updateOrderStatus` was already generic. Confirmation dialog before cancelling. (3) **Low-stock alerts** — no Cloud Function sender exists in this project (Phase 5's own scope note), so this is a local/in-app notification, not a real OS push: new `stockAlertInitializerProvider` (`features/notifications/controllers/stock_alert_controller.dart`), watched once from `main.dart` alongside `fcmInitializerProvider`. Computes the retailer's own "frequently bought" product ids (≥2 past orders, `AppConstants.kFrequentOrderThreshold`) from `orderHistoryProvider`, intersects with live stock ≤ `kLowStockThreshold`, and writes into the existing local `NotificationRepository` (Phase 5's Hive-only notification history — surfaces in the existing `NotificationsScreen`/bell badge with zero changes there). `ponytail:` the "already notified" dedupe is an in-memory `Set`, reset every app session — move it into Hive if that proves noisy. (4) **CSV export** — hand-rolled `encodeCsv()` (`core/utils/csv_encoder.dart`, RFC 4180 quoting) rather than adding a `csv` package for what's a few lines. Export button on `AllOrdersScreen`'s app bar exports whatever the current retailer-scope + status filter shows, via `Share.shareXFiles([XFile.fromData(...)])` — no `path_provider`/file write needed, `XFile.fromData` builds the attachment in memory. (5) **Order share** — `buildOrderShareText()` (`core/utils/order_share_formatter.dart`) builds a receipt-style plain-text summary; share icon in `OrderDetailScreen`'s app bar calls `Share.share()`. (6) `share_plus` was already an unused dependency (like `firebase_crashlytics` before it) — now wired up and documented in `ARCHITECTURE.md`/`rules.md`'s package tables. Every platform-plugin call (`Share.share`/`shareXFiles`) is wrapped in the same defensive try/catch as `FcmService`/`LocationService`/`ImageUploadService`. (7) Tests: `csv_encoder_test.dart` (5), `order_share_formatter_test.dart` (1), `order_entity_test.dart` (3, new `test/unit/entities/` folder), `stock_alert_controller_test.dart` (6, `ProviderContainer`-based), `order_detail_screen_test.dart` (8, new file — first coverage for this screen), plus new cases in `all_orders_screen_test.dart` (2) and `extensions_test.dart` (1, `cancelled` label). 250/250 passing, `flutter analyze` zero issues.

---

## 🧭 How to Use This File

> **When you ask "what's next?" or "what should we do now?" — the answer is always the first unchecked `[ ]` task inside the current active phase.**

### Current Active Phase: **Phase 8 — Launch Preparation & Play Store**
### Next Immediate Task:
> ✅ **Phase 7 (Testing & Quality Assurance) is fully complete — 12/12** (2026-07-31). `flutter analyze` zero issues, `flutter test` 163/163 passing.
>
> 🔶 **Phase 8 in progress** — 1/12 done (2026-08-19). Next unchecked task: configure `firebase_analytics` to track key events (order placed, user registered, login).
>
> ✅ **Phase 9 (Navigation Redesign) is fully complete — 9/9** (2026-08-19). `flutter analyze` zero issues, `flutter test` 270/270 passing.

---

> 🔒 *Update this file immediately when a task is completed — change `[ ]` to `[x]` and update the progress table at the top.*
