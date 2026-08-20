# 🏗️ ARCHITECTURE.md
## Jyoti Traders — Enterprise Flutter Application Architecture

> **Author Perspective**: Designed as a 17-year senior Android/Flutter engineer  
> **Version**: 1.0.0 | **Last Updated**: 2026-07-15  
> **Pattern**: Clean Architecture + Feature-First Modularization  
> **Platform**: Android (Flutter/Dart)

---

## 1. 🧱 Architectural Philosophy

This application is built on **Clean Architecture** principles, popularized by Robert C. Martin ("Uncle Bob"), adapted specifically for Flutter using the **Feature-First** folder organization. The core idea is strict **separation of concerns** across three layers:

```
┌─────────────────────────────────────────────┐
│           PRESENTATION LAYER                │  ← Screens, Widgets, Controllers
│     (Flutter Widgets + Riverpod Notifiers)  │
├─────────────────────────────────────────────┤
│             DOMAIN LAYER                    │  ← Business Logic, Use Cases, Entities
│          (Pure Dart — No Flutter)           │
├─────────────────────────────────────────────┤
│              DATA LAYER                     │  ← Repositories, Data Sources, Models
│      (Firebase, Hive, Dio, Mappers)         │
└─────────────────────────────────────────────┘
```

**Rules enforced at all times:**
- The **Domain** layer has zero dependencies on Flutter, Firebase, or any external package.
- The **Presentation** layer never directly touches the Data layer.
- All communication flows through abstract **Repository interfaces** defined in Domain.
- Every provider uses `autoDispose` to prevent memory leaks.

---

## 2. 🔷 Tech Stack

### 2.1 Core Framework

| Technology | Version | Purpose |
|---|---|---|
| **Flutter** | ≥ 3.22.x (Stable) | Cross-platform UI framework |
| **Dart** | ≥ 3.4.x | Language — null-safe, strongly typed |
| **Android min SDK** | API 24 (Android 7.0) | Covers 95%+ of Indian market devices |
| **Android target SDK** | API 34 (Android 14) | Latest Play Store compliance |

### 2.2 State Management & Navigation

| Package | Purpose |
|---|---|
| `flutter_riverpod` | Primary state management — providers, notifiers, autoDispose |
| `riverpod_annotation` | Code-gen for cleaner provider declarations |
| `go_router` | Declarative, URL-based routing with redirect guards |

### 2.3 Backend & Cloud

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase app initialization |
| `firebase_auth` | Phone/email-based user authentication |
| `cloud_firestore` | NoSQL real-time database for products, orders, users |
| `firebase_storage` | Product image hosting |
| `firebase_messaging` | Push notifications (FCM) |
| `firebase_crashlytics` | Crash reporting and stability monitoring |
| `firebase_analytics` | Usage analytics and funnel tracking |

### 2.4 Networking

| Package | Purpose |
|---|---|
| `dio` | HTTP client with interceptors for auth token injection and retry |
| `pretty_dio_logger` | Dev-mode request/response logging |

### 2.5 Local Persistence

| Package | Purpose |
|---|---|
| `hive_flutter` | Lightweight key-value store for session cache, settings |
| `flutter_secure_storage` | Encrypted storage for auth tokens and sensitive credentials |

### 2.6 UI & UX

| Package | Purpose |
|---|---|
| `cached_network_image` | Image loading with disk cache and shimmer placeholder |
| `shimmer` | Loading skeleton animation for lists and cards |
| `lottie` | High-quality JSON animations (empty states, success screens) |
| `fl_chart` | Admin dashboard bar/line charts for order analytics |
| `flutter_svg` | Scalable vector icons and illustrations |
| `google_fonts` | Typography — `Poppins` (headings) + `Inter` (body) |

### 2.7 Utilities

| Package | Purpose |
|---|---|
| `intl` | Currency (₹) formatting, date/time localization |
| `freezed` | Immutable data classes and union types for state |
| `json_annotation` + `json_serializable` | Type-safe JSON serialization/deserialization |
| `equatable` | Value equality for domain entities |
| `uuid` | Generating unique order/product IDs client-side |
| `url_launcher` | Launch phone dialer & email client for support contact |
| `permission_handler` | Runtime permissions (notifications, location) |
| `geolocator` | Retailer GPS location for delivery km calculation |
| `qr_flutter` | Renders the UPI payment QR code client-side from the UPI ID (Phase 5) |
| `share_plus` | OS share sheet — order confirmation text, admin CSV order export |

### 2.8 Dev & Quality

| Package | Purpose |
|---|---|
| `flutter_lints` | Dart linting rules enforced project-wide |
| `build_runner` | Code generation for Riverpod, Freezed, JSON |
| `mocktail` | Mocking for unit and widget tests |
| `flutter_test` | Widget and integration testing |

---

## 3. 📁 Folder & File Structure

```
jyoti_traders/
│
├── android/                          # Android native project
│   └── app/
│       ├── build.gradle.kts
│       └── google-services.json      # Firebase config (gitignored in prod)
│
├── assets/
│   ├── images/                       # Static images (logo, banners, placeholders)
│   ├── icons/                        # SVG icons
│   ├── animations/                   # Lottie JSON files
│   └── fonts/                        # (If bundled locally)
│
├── lib/
│   ├── main.dart                     # App entry point — Firebase init, Hive init, runApp
│   ├── firebase_options.dart         # Auto-generated Firebase config
│   │
│   ├── core/                         # App-wide, feature-agnostic foundations
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # Min order ₹2500, app name, support contacts
│   │   │   ├── firestore_paths.dart  # All Firestore collection/document path strings
│   │   │   └── hive_keys.dart        # All Hive box and key name constants
│   │   │
│   │   ├── network/
│   │   │   ├── api_client.dart       # Dio instance with interceptors (auth, retry, logging)
│   │   │   ├── api_exceptions.dart   # Typed exception classes (NetworkException, ServerException)
│   │   │   └── network_info.dart     # Connectivity checker
│   │   │
│   │   ├── navigation/
│   │   │   ├── app_router.dart       # GoRouter config — all routes defined here
│   │   │   ├── route_names.dart      # Route name constants (no magic strings)
│   │   │   └── route_guards.dart     # Auth redirect logic based on user state
│   │   │
│   │   ├── theme/
│   │   │   ├── app_colors.dart       # Full color palette (brand, semantic, neutral)
│   │   │   ├── app_theme.dart        # MaterialTheme light/dark config
│   │   │   ├── app_text_styles.dart  # Typography scale (display, headline, body, label)
│   │   │   └── app_spacing.dart      # Spacing constants (4, 8, 12, 16, 24, 32...)
│   │   │
│   │   └── utils/
│   │       ├── currency_formatter.dart   # ₹ formatting utility
│   │       ├── date_formatter.dart       # Date display utility
│   │       ├── validators.dart           # Form field validators (phone, GST, etc.)
│   │       ├── logger.dart               # Centralized debug logger wrapper
│   │       └── extensions.dart           # Dart extension methods (String, DateTime, etc.)
│   │
│   ├── data/                             # Data layer — external-facing
│   │   ├── models/                       # JSON-serializable models (DTOs)
│   │   │   ├── user_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── category_model.dart
│   │   │   ├── order_model.dart
│   │   │   ├── cart_item_model.dart
│   │   │   └── delivery_zone_model.dart
│   │   │
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   ├── auth_remote_datasource.dart       # Firebase Auth calls
│   │   │   │   ├── product_remote_datasource.dart    # Firestore product CRUD
│   │   │   │   ├── order_remote_datasource.dart      # Firestore order CRUD
│   │   │   │   └── user_remote_datasource.dart       # Firestore user management
│   │   │   │
│   │   │   └── local/
│   │   │       ├── auth_local_datasource.dart        # Hive — session token cache
│   │   │       ├── cart_local_datasource.dart        # Hive — cart persistence
│   │   │       └── product_local_datasource.dart     # Hive — product catalog cache
│   │   │
│   │   └── repositories/
│   │       ├── auth_repository.dart                  # Implements domain/auth_repository.dart
│   │       ├── product_repository.dart
│   │       ├── order_repository.dart
│   │       └── user_repository.dart
│   │
│   ├── domain/                           # Domain layer — pure Dart, no Flutter/Firebase
│   │   ├── entities/                     # Business objects — immutable, no serialization
│   │   │   ├── user_entity.dart
│   │   │   ├── product_entity.dart
│   │   │   ├── category_entity.dart
│   │   │   ├── order_entity.dart
│   │   │   └── cart_entity.dart
│   │   │
│   │   ├── repositories/                 # Abstract interfaces only
│   │   │   ├── auth_repository.dart
│   │   │   ├── product_repository.dart
│   │   │   ├── order_repository.dart
│   │   │   └── user_repository.dart
│   │   │
│   │   ├── usecases/                     # Single-responsibility business operations
│   │   │   ├── auth/
│   │   │   │   ├── login_usecase.dart
│   │   │   │   ├── register_usecase.dart
│   │   │   │   └── logout_usecase.dart
│   │   │   ├── order/
│   │   │   │   ├── place_order_usecase.dart          # Includes ₹2500 validation
│   │   │   │   ├── get_order_history_usecase.dart
│   │   │   │   └── update_order_status_usecase.dart
│   │   │   ├── product/
│   │   │   │   ├── get_products_usecase.dart
│   │   │   │   └── search_products_usecase.dart
│   │   │   └── user/
│   │   │       ├── approve_user_usecase.dart
│   │   │       └── get_pending_users_usecase.dart
│   │   │
│   │   └── value_objects/
│   │       ├── money.dart                # Encapsulates ₹ amount with validation
│   │       └── phone_number.dart         # Validated phone number type
│   │
│   ├── features/                         # Feature-first UI modules
│   │   │
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── auth_screen.dart               # Login / Sign-up tab switcher
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── pending_approval_screen.dart   # Post-signup lock screen
│   │   │   └── controllers/
│   │   │       └── auth_controller.dart           # Riverpod AsyncNotifier
│   │   │
│   │   ├── home/
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart               # Category grid + banners
│   │   │   └── controllers/
│   │   │       └── home_controller.dart
│   │   │
│   │   ├── products/
│   │   │   ├── screens/
│   │   │   │   ├── category_products_screen.dart  # Product list filtered by category
│   │   │   │   ├── product_detail_screen.dart     # Full product info + Add to Cart
│   │   │   │   └── search_screen.dart
│   │   │   └── controllers/
│   │   │       └── product_controller.dart
│   │   │
│   │   ├── cart/
│   │   │   ├── screens/
│   │   │   │   └── cart_screen.dart               # Cart list + total + checkout CTA
│   │   │   └── controllers/
│   │   │       └── cart_controller.dart           # Hive-backed cart state
│   │   │
│   │   ├── checkout/
│   │   │   ├── screens/
│   │   │   │   ├── checkout_screen.dart           # Address, payment, delivery charge
│   │   │   │   └── order_success_screen.dart
│   │   │   └── controllers/
│   │   │       └── checkout_controller.dart       # Validates ₹2500, calculates delivery
│   │   │
│   │   ├── orders/
│   │   │   ├── screens/
│   │   │   │   ├── order_history_screen.dart      # Retailer — past orders list
│   │   │   │   └── order_detail_screen.dart       # Full order breakdown + status
│   │   │   └── controllers/
│   │   │       └── order_controller.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── screens/
│   │   │   │   └── profile_screen.dart            # Shop info, address, support buttons
│   │   │   └── controllers/
│   │   │       └── profile_controller.dart
│   │   │
│   │   ├── notifications/
│   │   │   ├── screens/
│   │   │   │   └── notifications_screen.dart
│   │   │   └── controllers/
│   │   │       └── notification_controller.dart
│   │   │
│   │   └── admin/                                 # Admin-only feature module
│   │       ├── screens/
│   │       │   ├── admin_dashboard_screen.dart    # Stats overview
│   │       │   ├── approval_queue_screen.dart     # Pending retailer approvals
│   │       │   ├── manage_products_screen.dart    # Product CRUD
│   │       │   ├── manage_categories_screen.dart  # Category CRUD
│   │       │   ├── all_orders_screen.dart         # All retailer orders list
│   │       │   ├── order_management_screen.dart   # Update order status
│   │       │   └── retailer_list_screen.dart      # All approved retailers
│   │       └── controllers/
│   │           ├── admin_dashboard_controller.dart
│   │           ├── approval_controller.dart
│   │           ├── admin_product_controller.dart
│   │           └── admin_order_controller.dart
│   │
│   └── shared/                           # Reusable UI components across all features
│       ├── widgets/
│       │   ├── app_button.dart           # Primary, secondary, outlined button variants
│       │   ├── app_text_field.dart       # Themed input with validation
│       │   ├── product_card.dart         # Product grid/list tile
│       │   ├── category_chip.dart        # Category filter pill
│       │   ├── order_status_badge.dart   # Colored status badge
│       │   ├── shimmer_loader.dart       # Generic shimmer placeholder
│       │   ├── empty_state_widget.dart   # Lottie + message for empty screens
│       │   ├── error_state_widget.dart   # Error UI with retry action
│       │   └── bottom_nav_bar.dart       # Retailer bottom navigation
│       └── providers/
│           ├── auth_state_provider.dart  # Global auth state (the single source of truth)
│           ├── theme_provider.dart       # Light/dark mode preference (Hive-backed)
│           └── connectivity_provider.dart
│
├── test/
│   ├── unit/
│   │   ├── usecases/                     # Test each use case in isolation
│   │   ├── repositories/                 # Test repo logic with mocked datasources
│   │   └── value_objects/                # Test Money, PhoneNumber validation
│   ├── widget/
│   │   ├── auth/
│   │   ├── cart/
│   │   └── shared/
│   └── integration/
│       └── order_flow_test.dart          # Full order placement end-to-end test
│
├── pubspec.yaml
├── analysis_options.yaml
├── PRD.md
├── ARCHITECTURE.md
└── agents.md
```

---

## 4. 🔄 Application Flow

### 4.1 App Startup Flow

```
main()
  │
  ├─► Initialize Firebase (firebase_core)
  ├─► Initialize Hive boxes (users, cart, settings)
  ├─► Initialize FlutterSecureStorage
  │
  └─► runApp(ProviderScope(child: JyotiTradersApp()))
            │
            └─► GoRouter reads authStateProvider (StreamProvider)
                      │
                      ├─► Stream emits: null         → /auth
                      ├─► Stream emits: pending user → /pending-approval
                      ├─► Stream emits: admin user   → /admin/dashboard
                      └─► Stream emits: approved user→ /home
```

### 4.2 Retailer Order Placement Flow

```
Home Screen
  └─► Browse Categories → Category Product List
        └─► Tap Product → Product Detail Screen
              └─► "Add to Cart" → Cart Controller (Hive-backed)
                    └─► Cart Screen
                          │
                          ├─[Cart total < ₹2500]─► Show warning snackbar, block checkout
                          │
                          └─[Cart total ≥ ₹2500]─► Checkout Screen
                                │
                                ├─► Display delivery address (from profile)
                                ├─► Calculate delivery charge (per km)
                                ├─► Select Payment: COD / UPI
                                │
                                └─► "Place Order" → PlaceOrderUseCase
                                      │
                                      ├─► Write Order doc to Firestore
                                      ├─► Clear local cart (Hive)
                                      ├─► Send FCM notification to Admin
                                      └─► Navigate to OrderSuccessScreen
```

### 4.3 Admin Approval Flow

```
New Retailer Signs Up
  └─► Firestore: users/{uid} → status: "pending"
        └─► Retailer sees PendingApprovalScreen

Admin Dashboard
  └─► ApprovalQueueScreen streams pending users (real-time Firestore listener)
        └─► Admin taps "Approve"
              └─► ApproveUserUseCase
                    ├─► Update Firestore: users/{uid} → status: "approved"
                    └─► Send FCM to retailer: "Account approved!"
                          └─► Retailer app GoRouter redirect fires → /home
```

### 4.4 Admin Order Management Flow

```
Retailer places order
  └─► Firestore: orders/{orderId} created (status: "pending")
        └─► Admin FCM notification received

Admin → AllOrdersScreen
  └─► Tap Order → OrderManagementScreen
        └─► Update Status: pending → confirmed → out_for_delivery → delivered
              └─► Firestore write + FCM to Retailer at each status change

Retailer → OrderDetailScreen (self-service, within 10 min of a still-`pending` order)
  └─► Cancel Order → orderStatus: cancelled
```

---

## 5. 🗄️ Firestore Data Schema

### Collection: `users`
```
users/{uid}
  ├── uid: String
  ├── fullName: String
  ├── shopName: String
  ├── phone: String
  ├── email: String?
  ├── role: String              // "admin" | "user"
  ├── status: String            // "pending" | "approved" | "rejected"
  ├── address: Map
  │     ├── street: String
  │     ├── city: String
  │     └── pincode: String
  ├── gstNumber: String?
  ├── fcmToken: String
  └── createdAt: Timestamp
```

### Collection: `categories`
```
categories/{categoryId}
  ├── id: String
  ├── name: String
  ├── iconUrl: String
  ├── displayOrder: int
  └── isActive: bool
```

### Collection: `products`
```
products/{productId}
  ├── id: String
  ├── name: String
  ├── categoryId: String
  ├── imageUrl: String
  ├── price: double             // Wholesale price in ₹
  ├── unit: String              // "kg" | "piece" | "box" | "litre"
  ├── stock: int
  ├── description: String?
  ├── isActive: bool
  └── updatedAt: Timestamp
```

### Collection: `orders`
```
orders/{orderId}
  ├── id: String
  ├── userId: String
  ├── shopName: String
  ├── items: List<Map>
  │     └── { productId, name, qty, unitPrice, totalPrice }
  ├── subtotal: double
  ├── deliveryCharge: double
  ├── grandTotal: double
  ├── paymentMethod: String    // "cod" | "upi"
  ├── paymentStatus: String    // "pending" | "paid"
  ├── orderStatus: String      // "pending" | "confirmed" | "out_for_delivery" | "delivered" | "cancelled"
  ├── deliveryAddress: Map
  ├── notes: String?
  └── createdAt: Timestamp
```

---

## 6. 🔐 Security Rules Strategy

```
// Firestore Security Rules (summary)

users:
  - read: owner (uid == userId) OR admin
  - write: admin only (for status updates)
  - create: authenticated user (own document only)

products / categories:
  - read: approved users + admin
  - write: admin only

orders:
  - read: owner (userId == uid) OR admin
  - create: approved users only
  - update: admin only (for status changes)
```

---

## 7. 📡 State Management Architecture

Every feature follows this exact Riverpod pattern:

```
Screen (Widget)
  │  watches
  ▼
FeatureController extends AsyncNotifier<FeatureState>
  │  calls
  ▼
UseCase (Domain Layer)
  │  calls via abstract interface
  ▼
Repository Implementation (Data Layer)
  │  calls
  ├─► Remote DataSource (Firestore / Firebase Auth)
  └─► Local DataSource  (Hive cache)
```

**Global State Providers:**

| Provider | Type | Description |
|---|---|---|
| `authStateProvider` | `StreamProvider<User?>` | Firebase auth stream — single source of routing truth |
| `currentUserProvider` | `FutureProvider<UserEntity>` | Fetches full Firestore user profile |
| `cartProvider` | `StateNotifierProvider<CartNotifier, CartState>` | Local cart (Hive-backed) |
| `themeProvider` | `StateProvider<ThemeMode>` | App theme — persisted in Hive |

---

## 8. 🎨 Design System

### Typography
| Style | Font | Weight | Size |
|---|---|---|---|
| Display | Poppins | Bold (700) | 28sp |
| Headline | Poppins | SemiBold (600) | 22sp |
| Title | Poppins | Medium (500) | 18sp |
| Body | Inter | Regular (400) | 14sp |
| Label | Inter | Medium (500) | 12sp |
| Caption | Inter | Regular (400) | 11sp |

### Color Palette

| Token | Light | Dark | Usage |
|---|---|---|---|
| `primary` | `#1B5E20` | `#4CAF50` | Brand green (Kirana identity) |
| `onPrimary` | `#FFFFFF` | `#000000` | Text on primary |
| `secondary` | `#FF6F00` | `#FFB300` | CTA accent (Add to Cart, Order) |
| `surface` | `#FFFFFF` | `#1C1C1E` | Card/screen backgrounds |
| `error` | `#D32F2F` | `#EF5350` | Validation errors |
| `success` | `#2E7D32` | `#66BB6A` | Order confirmed states |

### Spacing Scale
```
xs:  4dp   sm:  8dp   md: 16dp
lg: 24dp   xl: 32dp   2xl: 48dp
```

---

## 9. ⚡ Performance Strategy

| Concern | Strategy |
|---|---|
| **List Rendering** | `ListView.builder` with `itemExtent` for all product/order lists |
| **Image Loading** | `CachedNetworkImage` with shimmer placeholder — no layout shift |
| **Widget Rebuilds** | `select()` on providers to rebuild only affected sub-trees |
| **Const Widgets** | All static widgets declared `const` — validated by linter rule |
| **Firestore Reads** | Stream listeners with `.limit()` and cursor-based pagination |
| **Offline Cache** | Hive stores last-fetched product catalog for offline browsing |
| **Image Storage** | Firebase Storage with resized image variants (thumbnail/full) |
| **Build Splits** | Release APK uses `--split-per-abi` for smaller download size |

---

## 10. 🧪 Testing Strategy

| Level | Coverage Target | Tools |
|---|---|---|
| **Unit Tests** | All UseCases, Value Objects, Formatters | `flutter_test`, `mocktail` |
| **Widget Tests** | All shared widgets, critical screen states | `flutter_test`, `WidgetTester` |
| **Integration Tests** | Order placement flow, Auth flow | `integration_test` package |
| **CI Guard** | `flutter analyze` + `flutter test` must pass on every commit | Local pre-commit hook |

---

## 11. 🚀 Build & Release

### Debug Build
```bash
flutter run --debug
```

### Release APK (split per ABI — smaller size)
```bash
flutter build apk --release --split-per-abi
```
Output: `build/app/outputs/flutter-apk/`
- `app-arm64-v8a-release.apk`   ← Primary (most modern phones)
- `app-armeabi-v7a-release.apk` ← Older budget devices

### App Bundle (Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Environment Config
```
lib/core/constants/app_constants.dart
  └── Use --dart-define for env-specific values:
      flutter run --dart-define=ENV=production
```

---

> 📌 *This document must be updated whenever a new feature, data schema change, or architectural decision is made. Architecture is a living contract — not a one-time deliverable.*
