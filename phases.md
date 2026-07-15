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
| Phase 2 | Domain Layer & Data Models | ⬜ Not Started | 0/12 |
| Phase 3 | Core Commerce — Retailer Side | ⬜ Not Started | 0/14 |
| Phase 4 | Admin Panel — Full Implementation | ⬜ Not Started | 0/12 |
| Phase 5 | Delivery, Payments & Notifications | ⬜ Not Started | 0/10 |
| Phase 6 | Polish, Animations & UX Refinement | ⬜ Not Started | 0/9 |
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

## ⬜ Phase 2 — Domain Layer & Data Models
> **Status**: NOT STARTED ⬜  
> **Goal**: Build the entire Domain layer (Entities, UseCases, Repository interfaces) and Data layer (Models, DataSources, Repository implementations). This is the backbone — no UI yet, just pure business logic.

### 2.1 — Value Objects & Entities
- [ ] Create `domain/value_objects/money.dart` — wraps amount, validates ≥ 0, formats ₹
- [ ] Create `domain/value_objects/phone_number.dart` — validates 10-digit Indian number
- [ ] Create `domain/entities/user_entity.dart` — `uid, fullName, shopName, phone, role, status, address, fcmToken, createdAt`
- [ ] Create `domain/entities/product_entity.dart` — `id, name, categoryId, imageUrl, price, unit, stock, isActive`
- [ ] Create `domain/entities/category_entity.dart` — `id, name, iconUrl, displayOrder, isActive`
- [ ] Create `domain/entities/order_entity.dart` — `id, userId, items, subtotal, deliveryCharge, grandTotal, paymentMethod, orderStatus, createdAt`
- [ ] Create `domain/entities/cart_entity.dart` — `items: List<CartItem>, subtotal`

### 2.2 — Repository Interfaces (Abstract)
- [ ] Create `domain/repositories/auth_repository.dart` — abstract interface
- [ ] Create `domain/repositories/product_repository.dart` — abstract interface
- [ ] Create `domain/repositories/order_repository.dart` — abstract interface
- [ ] Create `domain/repositories/user_repository.dart` — abstract interface

### 2.3 — Use Cases
- [ ] Create `domain/usecases/auth/login_usecase.dart`
- [ ] Create `domain/usecases/auth/register_usecase.dart`
- [ ] Create `domain/usecases/auth/logout_usecase.dart`
- [ ] Create `domain/usecases/product/get_products_usecase.dart`
- [ ] Create `domain/usecases/product/search_products_usecase.dart`
- [ ] Create `domain/usecases/order/place_order_usecase.dart` — **MUST validate ₹2,500 minimum — throws `MinimumOrderException` if violated**
- [ ] Create `domain/usecases/order/get_order_history_usecase.dart`
- [ ] Create `domain/usecases/order/update_order_status_usecase.dart` (admin)
- [ ] Create `domain/usecases/user/approve_user_usecase.dart` (admin)
- [ ] Create `domain/usecases/user/get_pending_users_usecase.dart` (admin)

### 2.4 — Data Models (DTOs)
- [ ] Create `data/models/user_model.dart` — with `fromFirestore()` + `toFirestore()` using `.withConverter`
- [ ] Create `data/models/product_model.dart` — with `fromFirestore()` + `toFirestore()`
- [ ] Create `data/models/category_model.dart` — with `fromFirestore()` + `toFirestore()`
- [ ] Create `data/models/order_model.dart` — with `fromFirestore()` + `toFirestore()`
- [ ] Create `data/models/cart_item_model.dart` — with Hive `TypeAdapter`

### 2.5 — Data Sources & Repository Implementations
- [ ] Create `data/datasources/remote/product_remote_datasource.dart` — Firestore CRUD
- [ ] Create `data/datasources/remote/order_remote_datasource.dart` — Firestore CRUD
- [ ] Create `data/datasources/remote/user_remote_datasource.dart` — Firestore user management
- [ ] Create `data/datasources/local/cart_local_datasource.dart` — Hive cart persistence
- [ ] Create `data/datasources/local/product_local_datasource.dart` — Hive catalog cache
- [ ] Create `data/repositories/product_repository.dart` — implements domain interface
- [ ] Create `data/repositories/order_repository.dart` — implements domain interface
- [ ] Create `data/repositories/user_repository.dart` — implements domain interface

### 2.6 — Core Constants & Utilities
- [ ] Create `core/constants/app_constants.dart` — `kMinOrderAmount = 2500.0`, `kSupportPhone`, `kSupportEmail`, `kAppName`
- [ ] Create `core/constants/firestore_paths.dart` — all collection/document path strings
- [ ] Create `core/constants/hive_keys.dart` — all Hive box and key name constants
- [ ] Create `core/constants/route_names.dart` — all GoRouter route name constants
- [ ] Create `core/utils/currency_formatter.dart` — `formatRupees(double amount)` → `₹2,500`
- [ ] Create `core/utils/date_formatter.dart` — `formatOrderDate(DateTime)` → `15 Jul 2026`
- [ ] Create `core/utils/validators.dart` — phone, GST, name, address validators
- [ ] Create `core/utils/extensions.dart` — String, DateTime, List extension methods

---

## ⬜ Phase 3 — Core Commerce (Retailer Side)
> **Status**: NOT STARTED ⬜  
> **Goal**: Build the complete retailer-facing shopping experience — browse, search, cart, checkout, and order history.

### 3.1 — Home Screen (Real Data)
- [ ] Wire `HomeScreen` to `homeController` — fetch real categories from Firestore
- [ ] Build `CategoryCard` widget — icon, name, tap → navigate to category products
- [ ] Build horizontal promotional banner (static images from `assets/images/`)
- [ ] Add shimmer loading state while categories are fetching
- [ ] Add empty state if no categories are available

### 3.2 — Product Browsing
- [ ] Build `CategoryProductsScreen` — filtered product grid by `categoryId`
- [ ] Build `ProductCard` widget — image, name, price (₹), unit, "Add to Cart" button
- [ ] Build `ProductDetailScreen` — full image, name, price, unit, stock info, description, "Add to Cart"
- [ ] Implement `productController` — fetches products from Firestore via `GetProductsUseCase`
- [ ] Add shimmer loading for product grid
- [ ] Add empty state for categories with no products

### 3.3 — Search
- [ ] Build `SearchScreen` — text field, real-time search via `SearchProductsUseCase`
- [ ] Display search results as product list tiles
- [ ] Save recent search terms to Hive (max 5)
- [ ] Show recent searches when search field is empty

### 3.4 — Cart
- [ ] Build `CartScreen` — list of cart items, quantity controls, subtotal, checkout CTA
- [ ] Implement `cartController` (Hive-backed) — `addItem`, `removeItem`, `updateQty`, `clearCart`
- [ ] Show real-time cart badge count on bottom nav bar
- [ ] Show ₹2,500 minimum order warning banner when subtotal < ₹2,500
- [ ] Disable "Proceed to Checkout" button if subtotal < ₹2,500
- [ ] Build `CartItemTile` widget — image, name, qty stepper, item total

### 3.5 — Checkout
- [ ] Build `CheckoutScreen` — order summary, delivery address, payment method selector, delivery charge display, "Place Order" CTA
- [ ] Implement `checkoutController` — calls `PlaceOrderUseCase`, handles loading/success/error
- [ ] Validate ₹2,500 minimum one final time in `PlaceOrderUseCase` before Firestore write
- [ ] Calculate and display delivery charge (per-km logic using `geolocator`)
- [ ] COD option — immediate order placement
- [ ] UPI option — display owner's UPI QR code image + UPI ID for manual payment
- [ ] Send FCM notification to admin on successful order placement

### 3.6 — Order Success & History
- [ ] Build `OrderSuccessScreen` — order ID, summary, Lottie success animation
- [ ] Build `OrderHistoryScreen` — list of past orders with status badges
- [ ] Build `OrderDetailScreen` — full order breakdown, status timeline, item list
- [ ] Implement `orderController` — fetches order history via `GetOrderHistoryUseCase`
- [ ] Stream real-time order status updates from Firestore

### 3.7 — Profile
- [ ] Build `ProfileScreen` — shop name, phone, address, logout button
- [ ] Add "Contact Support" section — tap-to-call `+91 98604 60325`, tap-to-email button
- [ ] Allow editing of delivery address (important for km calculation)
- [ ] Implement `profileController` — update user profile in Firestore

---

## ⬜ Phase 4 — Admin Panel (Full Implementation)
> **Status**: NOT STARTED ⬜  
> **Goal**: Give the admin owner full control — manage products, categories, approve retailers, and handle orders.

### 4.1 — Admin Dashboard (Real Data)
- [ ] Wire `AdminDashboardScreen` to real Firestore counts (today's orders, pending approvals, total retailers)
- [ ] Build stat cards with real-time stream data
- [ ] Add `fl_chart` bar chart — orders per day (last 7 days)

### 4.2 — Retailer Approval
- [ ] Build `ApprovalQueueScreen` — live stream of pending users
- [ ] Build `RetailerApprovalCard` — shop name, phone, address, Approve/Reject buttons
- [ ] Implement `approvalController` — calls `ApproveUserUseCase` / `RejectUserUseCase`
- [ ] Send FCM to retailer on approval/rejection

### 4.3 — Product Management
- [ ] Build `ManageProductsScreen` — paginated product list with edit/delete actions
- [ ] Build `AddEditProductScreen` — form: name, category, price, unit, stock, image upload, active toggle
- [ ] Implement product image upload to Firebase Storage
- [ ] Implement `adminProductController` — CRUD operations on Firestore products
- [ ] Add product stock alert (highlight when stock ≤ 5)

### 4.4 — Category Management
- [ ] Build `ManageCategoriesScreen` — list with drag-to-reorder display order
- [ ] Build `AddEditCategoryScreen` — form: name, icon upload, active toggle
- [ ] Implement `adminCategoryController` — CRUD on Firestore categories

### 4.5 — Order Management
- [ ] Build `AllOrdersScreen` — filterable list by status: All / Pending / Confirmed / Delivered
- [ ] Build `OrderManagementScreen` — full order details + status update dropdown
- [ ] Implement `adminOrderController` — calls `UpdateOrderStatusUseCase`
- [ ] Send FCM to retailer on each status change

### 4.6 — Retailer Management
- [ ] Build `RetailerListScreen` — all approved retailers with total spend, order count
- [ ] Allow admin to tap a retailer and view their full order history

---

## ⬜ Phase 5 — Delivery, Payments & Notifications
> **Status**: NOT STARTED ⬜  
> **Goal**: Complete delivery charge logic, finalize payment flows, and implement push notifications end-to-end.

- [ ] Set up Firebase Cloud Messaging (FCM) — `FirebaseMessaging.onMessage` + background handler
- [ ] Request notification permission on app startup
- [ ] Save FCM token to Firestore on login/refresh
- [ ] Build `NotificationsScreen` — list of received FCM notifications stored locally in Hive
- [ ] Implement delivery charge calculation — use `geolocator` to get retailer GPS, calculate distance from warehouse coordinates, multiply by per-km rate set by admin
- [ ] Build admin setting for per-km rate in `AdminDashboardScreen`
- [ ] Store warehouse lat/long as a Firestore config document
- [ ] UPI Payment Screen — display UPI QR image + UPI ID `(owner's UPI details)`, "I have paid" confirmation button, upload payment screenshot (optional)
- [ ] Admin marks order as paid manually after UPI confirmation
- [ ] COD — no extra steps, order placed immediately

---

## ⬜ Phase 6 — Polish, Animations & UX Refinement
> **Status**: NOT STARTED ⬜  
> **Goal**: Elevate the app from functional to premium. Every screen must feel smooth and polished.

- [ ] Add `shimmer` loading skeletons to ALL list screens (products, orders, categories, approvals)
- [ ] Add `EmptyStateWidget` (Lottie animation + message) to all empty list screens
- [ ] Add `ErrorStateWidget` (Lottie animation + retry button) to all error states
- [ ] Add smooth page transitions in GoRouter (fade + slide)
- [ ] Add hero animation on product image tap → product detail
- [ ] Add animated cart badge counter (bounce on add)
- [ ] Add Lottie success animation on `OrderSuccessScreen`
- [ ] Add pull-to-refresh on all list screens
- [ ] Implement dark mode toggle in Profile screen (saved to Hive via `themeProvider`)

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

### Current Active Phase: **Phase 2 — Domain Layer & Data Models**
### Next Immediate Task:
> ✅ Start with **`domain/value_objects/money.dart`** — the foundational value object for all ₹ amounts in the system.

---

> 🔒 *Update this file immediately when a task is completed — change `[ ]` to `[x]` and update the progress table at the top.*
