# 📦 Product Requirements Document (PRD)

## Jyoti Traders — Wholesale Retailer Mobile App

> **Version**: 1.0.0  
> **Last Updated**: 2026-07-15  
> **Owner**: Jyoti Traders (Proprietor)  
> **Contact**: 📞 +91 98604 60325 | ✉️ vishvatejkatkar007@gmail.com  
> **Platform**: Android (Flutter)  
> **Target Audience Scale**: ~30 verified retailer/wholesale users

---

## 1. 🎯 Purpose & Vision

**Jyoti Traders** is a dedicated B2B mobile ordering application built for a local wholesale Kirana (grocery/FMCG) distributor. The app streamlines the ordering process between the owner and their trusted network of ~30 local retailers, replacing manual phone-call or WhatsApp-based ordering with a structured, trackable digital system.

The app is **not** a public marketplace. It is a **closed, invite-like system** where every new user must be manually verified and approved by the admin (owner) before they can place orders.

---

## 2. 👥 Target Users

| Role                       | Count | Description                                                                                                   |
| -------------------------- | ----- | ------------------------------------------------------------------------------------------------------------- |
| **Admin (Owner)**          | 1     | The proprietor of Jyoti Traders. Manages products, approves retailers, views and fulfills orders.              |
| **Normal User (Retailer)** | ~30   | Local shop owners, kirana store retailers who buy wholesale goods. Must be approved by Admin before ordering. |

### 2.1 User Persona: Retailer (Normal User)

- **Name**: Local Kirana shop owner (e.g., "Ramesh Bhai, Shop Owner")
- **Age Range**: 30–60 years
- **Tech Literacy**: Low to moderate; primarily uses WhatsApp & basic Android apps
- **Goal**: Quickly browse available stock, place a bulk order (min ₹2,500), and track delivery
- **Pain Point**: Currently placing orders via phone calls or WhatsApp messages, leading to confusion and errors
- **Language**: Marathi / Hindi preferred (consider localization in later versions)

### 2.2 User Persona: Admin (Owner)

- **Goal**: View incoming orders in real-time, manage product catalog, approve new retailers, and assign deliveries
- **Pain Point**: Manual order-taking, no consolidated view of pending orders or stock

---

## 3. 🏛️ Business Rules & Constraints

These are **hard requirements** enforced in the app at all times:

| Rule                     | Detail                                                                                                                       |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------- |
| **Minimum Order Amount** | ₹2,500 per order. Orders below this must be blocked at checkout with a clear message.                                        |
| **Manual Approval**      | New user registrations are placed in a "Pending" state. The admin must manually approve before the user can browse or order. |
| **Closed User Base**     | No open public sign-up. All accounts are vetted by the admin.                                                                |
| **Delivery Charges**     | Calculated per kilometer based on the retailer's registered delivery address distance from the warehouse.                    |
| **Payment Methods**      | Cash on Delivery (COD) and Online UPI payment.                                                                               |
| **Own Delivery**         | Deliveries are handled by the client's own delivery personnel. No third-party logistics.                                     |
| **Order Cancellation**   | A retailer may self-cancel their own order only while it's still `Pending` and only within 10 minutes of placing it. Once the admin confirms it, or the window passes, cancellation is no longer available. |

---

## 4. ✨ Feature List

### 4.1 Authentication & Onboarding

- **User Sign-Up**: Retailer registers with:
  - Full Name
  - Shop Name
  - Phone Number (used as primary ID)
  - Business Address (for delivery distance calculation)
  - GST Number (optional)
  - Password
- **OTP / Email Verification** (optional phase 2)
- **Pending Approval Screen**: After sign-up, user sees a lock screen with:
  - Message: _"Your account is under review."_
  - Admin contact: 📞 9860460325 | ✉️ vishvatejkatkar007@gmail.com
- **Admin Login**: Separate admin credentials with a secured login path
- **Role-Based Routing**: On login, the app automatically routes:
  - `Admin` → Admin Dashboard
  - `Approved Retailer` → Home (Marketplace)
  - `Pending Retailer` → Pending Approval Screen

---

### 4.2 Admin Panel Features

| Feature                     | Description                                                                                                     |
| --------------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Dashboard Overview**      | Total orders today, pending orders, total retailers, low-stock alerts                                           |
| **Retailer Approval Queue** | List of pending sign-ups with shop details; one-tap Approve / Reject                                            |
| **Product Management**      | Add / Edit / Delete products with name, image, price (wholesale), unit (kg/piece/box), stock quantity, category. Per-kg products take a 4-band rate card instead of a flat price (§4.5) |
| **Category Management**     | Create and manage 6–10 product categories (e.g., Spices, Oils, Pulses, Snacks, Beverages, Cleaning)             |
| **Order Management**        | View all incoming orders, filterable by status. Update status: `Pending → Confirmed → Out for Delivery → Delivered`, or `Cancelled` (retailer-initiated). Export the current filtered list to CSV. |
| **Delivery Assignment**     | Assign orders to delivery personnel and mark dispatch                                                           |
| **Retailer List**           | View all approved retailers with their order history and total spend                                            |

---

### 4.3 Retailer (Normal User) Features

| Feature                | Description                                                                                            |
| ---------------------- | ------------------------------------------------------------------------------------------------------ |
| **Home Screen**        | Category-wise product grid with promotional banners                                                    |
| **Product Browsing**   | Browse by category, search by name, filter by price/availability                                       |
| **Product Detail**     | Product image, name, wholesale price, available stock, unit info. Per-kg products show the quantity rate card and a weight picker (§4.5) |
| **Cart**               | Add/remove items, see real-time cart total, minimum order warning if below ₹2,500                      |
| **Checkout**           | Review order summary, select payment method (COD / UPI), confirm delivery address, see delivery charge |
| **Order Confirmation** | Order ID, summary, and estimated delivery info shown post-checkout. Share the confirmation as text via the OS share sheet |
| **Order History**      | List of past orders, filterable by status. Order Detail shows a visual tracking stepper (Placed → Confirmed → Out for Delivery → Delivered, or a distinct Cancelled state) instead of just a badge. Self-cancel within the window (§3). "Buy Again" re-adds every item from a past order at current prices/stock |
| **Reorder**            | Home screen surfaces a "Buy Again" rail of individually frequently-bought products (one-tap add), plus a heads-up banner if any of those regulars are low/out of stock |
| **Profile**            | View and edit shop info, registered address, contact details                                           |
| **Support**            | Direct call/email button to contact admin                                                              |

---

### 4.4 Delivery Charge Calculation ✅ Implemented (Phase 5)

- Admin sets a **per-km rate** (e.g., ₹10/km) and the warehouse's coordinates via `DeliverySettingsScreen`
- At checkout, the app calculates straight-line (Haversine) distance from the retailer's GPS-captured address to the warehouse — no Google Maps API dependency, avoiding an API key/billing requirement
- Delivery charge is shown transparently before order confirmation; falls back to a flat placeholder if the retailer hasn't captured their GPS location yet

---

### 4.5 Quantity-Based (Slab) Pricing ✅ Implemented

Products sold **per kg** are priced on a quantity ladder — the more weight bought in one line, the cheaper the kilo. Per-piece / per-box / per-litre products are unaffected and keep flat unit pricing.

| Quantity bought | Rate      |
| --------------- | --------- |
| Below 240 g     | ₹44 / kg  |
| 240 g – 999 g   | ₹40 / kg  |
| 1 kg – 2.4 kg   | ₹39 / kg  |
| Above 2.4 kg    | ₹38 / kg  |

Rules:

- The **whole weight is billed at the single rate its band earns** — 3 kg costs 3 × ₹38, *not* the first 240 g at ₹44 with the remainder cheaper. This is not tax-bracket style marginal pricing.
- The three gram boundaries (240 g / 999 g / 2.4 kg) are **fixed shop-wide**. The four rates are set **per product** by the Admin on Add/Edit Product — rice, sugar and dal don't share a rate card. The table above is the default prefill.
- Retailers pick weight via quick-pick chips (100 g / 250 g / 500 g / 1 kg / 2.5 kg / 5 kg) plus a ± stepper. The product page shows the full rate card with the active band highlighted, so the next discount is visible before buying.
- Stock for a kg product is counted in **kilograms**.
- Line totals round to whole paise. Amounts display paise only when non-zero (a 100 g line at ₹44/kg is ₹4.40, not ₹4).
- A placed order **freezes** its line totals — editing a product's rates later never re-prices a historical invoice.
- Products saved before this feature carry no rate card and keep flat per-kilo pricing, so no data migration was required.

> **Rate values are client-set business rules.** The ₹39 rate for the 1 kg – 2.4 kg band is a default pending final client confirmation.

---

## 5. 🗂️ Product Categories (Initial)

The following 15 stock groups are the client's actual inventory taxonomy (replaces the earlier 8-category placeholder list, 2026-07-30):

1. 🌿 Ayurvedic Medicine
2. 🛒 Other Grocery
3. 💡 Electricals
4. 🧴 Cosmetics & Soaps
5. 🚿 Shampoos
6. 🍵 Tea
7. 🍚 Rice
8. 🫙 Oil & Oil Seeds
9. 🫘 Lentils & Whole Pulses
10. 🍃 Paan Patti Sahitya
11. 🎆 Firecrackers
12. 🌾 Cereal Grains & Foodstuff
13. 🔧 Suut & Hardware
14. Suhana
15. Suavda

> Categories can be managed and updated by the Admin at any time via the Admin Panel. Categories 14–15 are the client's own terms, carried through as given — meaning unconfirmed (possibly a stocked brand line for #14, given "Suhana" is a known masala/spice-mix brand).

---

## 6. 🖥️ Screens & Navigation Flow

```
App Launch
  └─── Splash Screen
         ├── Not Logged In → Auth Screen (Login / Sign Up)
         │     ├── Sign Up → Pending Approval Screen
         │     └── Login
         │           ├── Admin → Admin Dashboard
         │           ├── Approved User → Home Screen
         │           └── Pending User → Pending Approval Screen
         └── Logged In (cached session)
               ├── Admin → Admin Dashboard
               └── Approved User → Home Screen

Home Screen (bottom-nav tab)
  ├── Buy Again rail + low-stock banner (frequently-bought products)
  ├── Category Grid → Category Product List → Product Detail → Add to Cart
  ├── Search (bottom-nav tab)
  ├── Cart → Checkout → Order Confirmation (bottom-nav tab)
  ├── Order History (bottom-nav tab) → status filter chips → Order Detail (tracking stepper, Buy Again, Cancel)
  └── Profile & Support (bottom-nav tab)

Admin — persistent bottom-nav tabs (Phase 9), not a dashboard hub
  ├── Dashboard — stats, chart, quick actions, approval-queue preview
  ├── Orders — status filter chips, CSV export
  ├── Catalog — Products | Categories (segmented)
  ├── Retailers — Approved | Pending (segmented; approve/reject inline)
  └── Profile — identity, Settings (incl. Delivery Settings sheet), Change Password
```

---

## 7. 💳 Payment Flow ✅ Implemented (Phase 5)

| Method                     | Flow                                                                                                                                        |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **COD (Cash on Delivery)** | Order placed → Admin confirms → Delivery → Cash collected on site                                                                           |
| **UPI**                    | Order placed → UPI payment screen shown (UPI ID / QR Code of owner) → Payment screenshot upload (optional) → "I have paid" → Admin confirms order |

> **Note**: Full UPI payment gateway integration (Razorpay/PhonePe) can be added in Phase 2. Initial version may use a manual UPI QR code approach.
>
> **Implementation note**: the QR is generated client-side (`qr_flutter`) from a standard `upi://pay?...` deep link — no gateway integration, no API key. `AppConstants.kUpiId`/`kUpiPayeeName` are **placeholders** (`jyotitraders@upi`) — the client has not yet provided the owner's real UPI ID. Swap those two constants when real details arrive; nothing else needs to change.

---

## 8. 🔔 Notifications

| Trigger              | Recipient | Message                                         |
| -------------------- | --------- | ----------------------------------------------- |
| New retailer sign-up | Admin     | "New retailer [Name] is awaiting approval."     |
| Account approved     | Retailer  | "Your account is approved! Start ordering now." |
| New order placed     | Admin     | "New order #[ID] received from [Shop Name]."    |
| Order status update  | Retailer  | "Your order #[ID] is now [Status]."             |

> Implemented via **Firebase Cloud Messaging (FCM)**.

---

## 9. 🛠️ Technical Stack

| Layer                  | Technology                                        |
| ---------------------- | ------------------------------------------------- |
| **Frontend**           | Flutter (Dart) — Android first                    |
| **State Management**   | Riverpod (with auto-dispose)                      |
| **Navigation**         | GoRouter                                          |
| **Backend / Auth**     | Firebase Authentication + Firestore               |
| **Local Storage**      | Hive (for session caching, search history)        |
| **Networking**         | Dio HTTP Client (with interceptors)               |
| **Push Notifications** | Firebase Cloud Messaging (FCM)                    |
| **Image Handling**     | CachedNetworkImage + Firebase Storage             |
| **Architecture**       | Clean Architecture (Presentation → Domain → Data) |

---

## 10. 🔒 Security & Access Control

- All routes are guarded by `authNotifierProvider` state
- Admin routes are inaccessible to Normal Users (enforced both in UI routing and Firestore rules)
- Firestore Security Rules: Users can only read their own profile; only Admin can write to `products`, `categories`, `users` approval status
- Pending users have **read-only** access to the approval screen — no product data is fetched

---

## 11. 📱 Non-Functional Requirements

| Requirement             | Target                                                    |
| ----------------------- | --------------------------------------------------------- |
| **App Size**            | < 30 MB APK                                               |
| **Performance**         | Smooth 60fps scrolling on mid-range Android devices       |
| **Offline Support**     | Cached product catalog for browsing (no ordering offline) |
| **Min Android Version** | Android 7.0 (API Level 24)                                |
| **Image Loading**       | Cached with shimmer placeholder, no layout shift          |
| **Startup Time**        | < 2 seconds cold start on mid-range device                |

---

## 12. 🗓️ Phased Rollout Plan

### ✅ Phase 1 — Foundation (Done)

- Project scaffolding, Clean Architecture, Riverpod, GoRouter
- Theme system (Light/Dark), design tokens
- Dio API client, Hive local storage
- Firebase Auth + Firestore integration
- Auth screens, role-based routing, pending approval flow
- Admin Dashboard shell + Approval Queue

### 🔄 Phase 2 — Core Commerce (In Progress)

- [x] Home Screen with category grid (Retailer)
- [x] Product Detail Screen, search, cart
- [x] Checkout (with ₹2,500 minimum validation) — COD only for now; delivery charge is a flat placeholder pending Phase 3's per-km calculation
- [x] Order placement and Order History
- [x] Admin Dashboard — real-time stats (pending approvals, total retailers, today's orders) + orders-per-day bar chart, replacing the Phase-1 placeholder stats
- [x] Admin Retailer Approval — dedicated approval queue screen with live approve/reject, replacing the Phase-1 placeholder
- [x] Product Management (Admin) — full CRUD with image upload, active/inactive toggle, and low-stock alerts
- [x] Category Management (Admin) — full CRUD with icon upload, active/inactive toggle, and drag-to-reorder
- [x] Order Management (Admin) — filterable order list + status update dropdown (Pending → Confirmed → Out for Delivery → Delivered)
- [x] Retailer Management (Admin) — retailer list with total spend/order count, tap-through to full order history — **Phase 4 (Admin Panel) now fully complete**
- [x] Push Notifications (FCM) — permission request, token save on login/refresh, foreground message handling, background handler, and a local (Hive) `NotificationsScreen` with an unread-count bell badge on both the retailer and admin home screens. Actual server-side sending (a Cloud Function) is still out of scope — this is the client-side plumbing only.
- [x] Delivery Charge Calculation (§4.4) — real per-km pricing via `geolocator` GPS capture + Haversine distance from an admin-configured warehouse location + an admin-settable per-km rate (`DeliverySettingsScreen`), replacing the flat placeholder. Falls back to the placeholder gracefully for any retailer who hasn't captured their location yet.
- [x] UPI Payment Flow (§7) — QR/UPI-ID payment screen, "I have paid" claim with optional screenshot upload, admin manual payment confirmation (`OrderManagementScreen`'s "Mark as Paid"). **Phase 5 (Delivery, Payments & Notifications) now fully complete.**

### 📅 Phase 3 — Delivery & Payments

- UPI QR code payment flow

### 📅 Phase 4 — Polish & Launch

- [x] UI animations and micro-interactions polish — ✅ Implemented (`phases.md` Phase 6, 2026-07-23–26): dark mode, Blinkit/Zepto-style product/category cards, floating cart bar, GoRouter page transitions, product-image Hero animation, animated cart badge, and shimmer/pull-to-refresh/error-state coverage across every list screen
- Multilingual support (Marathi/Hindi)
- Performance optimization & crash analytics (Firebase Crashlytics)
- Google Play Store submission

---

## 13. ✅ Success Metrics

| Metric                              | Target                         |
| ----------------------------------- | ------------------------------ |
| Active retailers onboarded          | 25–30 within first month       |
| Orders placed digitally (vs. phone) | > 80% adoption within 2 months |
| Order errors (wrong items/qty)      | < 5% of total orders           |
| Admin time spent on order-taking    | Reduced by > 70%               |
| App crash rate                      | < 1% of sessions               |

---

> 📝 _This PRD is a living document. It will be updated as new decisions are made, features are scoped in/out, or client requirements change._
