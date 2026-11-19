# 🧪 Jyoti Traders — Full Manual Test Plan (A to Z)

> **Build under test:** current `feature/change-password-settings-tab` working tree · **Written:** 2026-10-15
> **Covers:** Retailer app + Admin panel · Light mode + Dark mode · English / हिन्दी / मराठी · Android
> **Tracker:** `Jyoti_Traders_Test_Cases.xlsx` (same test cases, with Pass/Fail dropdowns and an auto-summary)

---

## 0. How to use this document

1. Do the **setup** in §2 once, keep §3 (test accounts & data) open while testing.
2. Run every test case **twice** — once in **Light mode (☀)** and once in **Dark mode (🌙)**. Recommended order:
   - **Pass 1:** all cases in Light mode (functional bugs show up here).
   - **Pass 2:** switch to Dark mode (§2.4) and re-run — this time look mainly at *how it looks*, using the checklist in §4.
   - **Pass 3:** the Theme Sweep in §6 (every screen, both themes) and the Language section (§5.28).
3. Write the result in the ☀ / 🌙 column:

| Mark | Meaning |
|---|---|
| ✅ | Pass — behaves exactly as "Expected result" |
| ❌ | Fail — log a bug (§8) and write the bug ID in the cell, e.g. `❌ BUG-07` |
| ⏸ | Blocked — could not run (say why in the bug log) |
| ➖ | Not applicable |

4. **Priority (Pri):** **P1** = blocks business (login, money, ordering, approvals) — must pass before launch · **P2** = major feature · **P3** = minor / cosmetic.
5. "Exploratory" in a test case means the right behaviour isn't defined yet — **record what actually happens** and raise it with the client if it looks wrong.

---

## 1. Scope

**In scope**
- Every retailer screen: onboarding, login/sign-up, pending approval, Home, categories, product detail, quantity picker & weight-slab pricing, search, wishlist, cart, coupons, checkout, delivery charge, UPI, orders, notifications, profile, settings.
- Every admin screen: dashboard, approvals, orders, catalog (products/categories/bulk import), banners, broadcast, delivery settings, retailers, profile/business details.
- Light / Dark / System theme, 3 languages, text size, landscape, small screens, Android 15 edge-to-edge, offline behaviour, data persistence, role security.

**Out of scope (for now)**
- **Live Firebase** — `firebase_options.dart` still has placeholder credentials, so the app runs in **simulation mode** (all data lives in the phone's local Hive storage). Real push notifications, real password-reset emails, Firestore security rules and cloud image upload **cannot be tested yet**. Re-run sections **AUTH, PEND, NOTI, SET, APPR** once the real Firebase project is connected.
- iOS, Play Store listing.

> ⚠️ **Simulation mode means one phone = one database.** Admin and retailer data are only shared if you log in as both **on the same phone** (log out of one, log in as the other). Cross-role tests below assume that.

---

## 2. Test environment & setup

### 2.1 Devices

| # | Device | Why |
|---|---|---|
| D1 | Redmi `M2101K6I`, Android 13 (physical) | Main device — the client's real phone class |
| D2 | Small emulator (e.g. Pixel 4a / 5.8") | Overflow on small screens |
| D3 | Android 15 emulator | Edge-to-edge status/navigation bars |

### 2.2 Install the build

```bash
flutter build apk --release
flutter install -d <device-id>        # or: adb install -r build/app/outputs/flutter-apk/app-release.apk
```
- Xiaomi/Redmi: when the phone asks **"Install via USB?"**, tap **Allow**.
- **Tip:** layout overflow shows as yellow/black stripes **only in debug builds**. For the UI/Text-size cases, also run once with `flutter run` (debug) — in release, overflowing text is silently cut off instead.

### 2.3 Fresh start (do this before Pass 1)
Android **Settings → Apps → Jyoti Traders → Storage → Clear data**. This re-seeds the demo catalog/orders and shows onboarding again.
Also: **Internet ON** (product photos load from the web), **Location ON**, allow permissions when asked.

### 2.4 How to switch theme, language, text size

| What | Retailer | Admin |
|---|---|---|
| Theme | **Profile** tab → **Settings** tab → **Appearance** → Light / Dark / System | **Profile** tab → **Settings** tab → **Appearance** |
| Language | same → **Language** | same → **Language** |
| Text size | same → **Text size** | same → **Text size** |
| "System" theme | Android **Settings → Display → Dark theme** on/off | same |

### 2.5 Time-based tests
Some rules depend on the clock: order cancel window (10 min), "unconfirmed 30+ min" alert, same-day delivery cutoff (3 PM). Either wait, or change the phone time (**Settings → System → Date & time → turn off automatic**). **Turn automatic time back on afterwards.**

### 2.6 Setting a fake location (emulator)
Emulator **⋯ → Location** → enter latitude/longitude → **Set location**. On a real phone, test with your actual location and calculate the expected distance with Google Maps (straight line).

---

## 3. Test accounts & test data

### 3.1 Accounts (simulation mode)

| Role | Email | Password | Opens on |
|---|---|---|---|
| Admin | `admin@jyoti.com` | `admin123` | Admin Dashboard |
| Retailer (approved) | `retailer@jyoti.com` | `retailer123` | Home — "Ram Kirana Store", Owner: Retailer Ram |
| Retailer (pending) | `nirmala.store@example.com` | `Nirmala@123` | Pending approval screen |
| New retailer | sign up yourself, e.g. `test1@shop.com` / `Test@1234` | — | Pending approval screen |

The login screen also has **Admin Demo** / **Retailer Demo** buttons that fill the first two accounts in.

### 3.2 Key demo products (seeded)

| Product | Category | Price | Unit | Stock | Use it for |
|---|---|---|---|---|---|
| Basmati Rice Premium 25kg | Rice | ₹2,250 | box | 40 | Top product, minimum-order tests |
| Wheat Atta 10kg | Cereal Grains & Foodstuff | ₹480 | box | 60 | Top product |
| Fortune Soya Health Oil 15L Tin | Oil & Oil Seeds | ₹1,680 | piece | 25 | Top product |
| Pure Ghee 1L | Oil & Oil Seeds | ₹620 | piece | 30 | Top product |
| Instant Coffee 200g | Other Grocery | ₹340 | piece | 26 | Exact ₹2,500 cart |
| **Toor Dal 10kg** | Lentils & Whole Pulses | ₹1,150 | box | **4** | **Low-stock** tests |
| **Turmeric Powder 1kg** | Other Grocery | ₹210 | **kg** | 50 kg | **Weight-slab pricing** |
| Sugar 25kg | Other Grocery | ₹1,320 | box | 30 | — |

15 categories are seeded: Ayurvedic Medicine, Other Grocery, Electricals, Cosmetics & Soaps, Shampoos, Tea, Rice, Oil & Oil Seeds, Lentils & Whole Pulses, Paan Patti Sahitya, Firecrackers, Cereal Grains & Foodstuff, Suut & Hardware, Suhana, Suavda.

### 3.3 Weight-slab pricing — expected prices for **Turmeric Powder**

Rates: **₹231/kg** below 240 g · **₹210/kg** 240 g–999 g · **₹204.75/kg** 1 kg–2.4 kg · **₹199.50/kg** above 2.4 kg. The rate card, product cards, cart lines and order lines must show these **exact** figures — never rounded (₹204.75, not ₹205).
The **whole** weight is billed at the one rate its band earns (not tax-bracket style).

| Weight | Band | Expected price |
|---|---|---|
| 100 g | below 240 g | ₹23.10 |
| 239 g | below 240 g | ₹55.21 |
| 240 g | 240 g – 999 g | ₹50.40 *(cheaper than 239 g — correct)* |
| 500 g | 240 g – 999 g | ₹105 |
| 999 g | 240 g – 999 g | ₹209.79 |
| 1 kg | 1 kg – 2.4 kg | ₹204.75 |
| 2.4 kg | 1 kg – 2.4 kg | ₹491.40 |
| 2.5 kg | above 2.4 kg | ₹498.75 |
| 5 kg | above 2.4 kg | ₹997.50 |

A **new** kg product in the admin form is prefilled with ₹44 / ₹40 / ₹39 / ₹38 per kg.

### 3.4 Business rules to verify

| Rule | Value |
|---|---|
| Minimum order | **₹2,500**, checked on the goods **subtotal** (delivery charge doesn't count) |
| Coupon `WELCOME10` | 10% off, max ₹250, needs subtotal ≥ ₹2,500 |
| Coupon `FLAT5` | 5% off, max ₹500, needs subtotal ≥ ₹5,000 |
| Delivery charge | straight-line km from warehouse × ₹/km. Default warehouse 21.1458, 79.0882 (Nagpur), **₹10/km**. No location → flat **₹100 (estimated)** |
| Delivery ETA | ≤ 15 km and before 3 PM → "Arrives today" · ≤ 40 km → "Arrives by tomorrow" · > 40 km → "Arrives in 2–3 days" · no location → "Arrives in 1–2 days" |
| Retailer self-cancel | only while order is **Pending** and within **10 minutes** of placing |
| Low stock | stock **≤ 5** |
| "Frequently bought" | product appears in **≥ 2** of the retailer's orders |
| Stale order alert | still Pending after **30 min** |
| Minimum weight | **100 g** for kg products |
| Stock | Reduced the moment an order is **placed**; put back if the order is **cancelled** (by retailer or admin). Kg stock keeps decimals (50 − 2.5 = 47.5). An order asking for more than is left is refused at Place Order |
| Recent searches kept | last **5** |

### 3.5 Test locations (distance from default warehouse)

| Place | Lat, Lng | ≈ km | Expected charge (₹10/km) | Expected ETA |
|---|---|---|---|---|
| Near warehouse | 21.1700, 79.1000 | ≈ 3 | ≈ ₹30 | Today (before 3 PM) |
| Kalmeshwar | 21.2333, 78.9167 | ≈ 20 | ≈ ₹203 | Tomorrow |
| Wardha | 20.7453, 78.6022 | ≈ 67 | ≈ ₹670 | 2–3 days |

Charges are not rounded to whole rupees, so paise may show (e.g. ₹202.95) — that is expected. Accept ±₹5 from the table.

---

## 4. Light / Dark visual checklist (use on every screen in Pass 2)

| # | Check |
|---|---|
| V1 | All text readable — no white-on-white, black-on-black, grey-on-grey |
| V2 | Cards, sheets, dialogs and popups have visible edges against the background |
| V3 | All icons visible — app bar, bottom nav (selected **and** unselected), list icons |
| V4 | Text fields: label, hint, typed text, cursor, border, error text visible — idle, focused, error, disabled |
| V5 | Buttons: filled (white text on saffron), outlined, text buttons; disabled state clearly looks disabled |
| V6 | Badges & chips readable: order status, Inactive, Default, low-stock, unread count, Out of stock |
| V7 | Phone status bar & navigation bar icons visible (dark icons on light, light icons on dark) — especially Login, Onboarding, Pending, Order Success |
| V8 | Snackbars, toasts, dialogs, bottom sheets, popups follow the theme (no white box in dark mode) |
| V9 | Product photos, placeholders and loading shimmer visible; no image on a clashing background |
| V10 | Charts: bars/lines/slices, axis labels, legends and tooltips readable |
| V11 | No hard-coded light panels left in dark mode (and no dark panels in light mode) |
| V12 | Switching theme updates the open screen instantly, and the choice survives an app restart |

---

## 5. Test cases

### 5.1 Install, launch & onboarding (INST)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| INST-01 | Fresh install launches | 1) Clear data / fresh install 2) Open app | Splash animation, then Onboarding. No crash, no blank screen | P1 | | |
| INST-02 | Onboarding slides | Swipe through all slides | 3 slides: "Browse the Full Catalog", "Bulk Orders, Better Prices", "Pay Your Way"; page dots update; Next moves forward | P2 | | |
| INST-03 | Skip onboarding | Tap **Skip** on slide 1 | Login screen opens | P2 | | |
| INST-04 | Get Started | Go to last slide → **Get Started** | Login screen opens | P2 | | |
| INST-05 | Onboarding shows once | Kill app and reopen | Goes straight to Login — no onboarding | P2 | | |
| INST-06 | Back on onboarding | Press phone Back on slide 2 | No crash, no blank screen | P3 | | |
| INST-07 | Session kept after restart | Log in as retailer → kill app → reopen | Opens directly on Home, still logged in | P1 | | |
| INST-08 | Session kept (admin) | Log in as admin → kill app → reopen | Opens directly on Admin Dashboard | P1 | | |
| INST-09 | App name & icon | Look at the launcher | Label "Jyoti Traders", correct icon, not stretched | P3 | | |
| INST-10 | Update keeps data | Install a newer APK over the old one (no uninstall) | Still logged in, cart/orders kept, no crash | P2 | | |
| INST-11 | Splash/onboarding landscape | Rotate phone on onboarding | No overflow, content readable | P3 | | |

### 5.2 Login & sign-up (AUTH)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| AUTH-01 | Login screen layout | Open Login | Logo/title, "Wholesale & Retail Market Hub", Email, Password, **Sign In**, "Don't have an account? Sign Up", "Simulation Demo Quick Login" with Admin Demo / Retailer Demo | P2 | | |
| AUTH-02 | Admin demo login | Tap **Admin Demo** → **Sign In** | Fields fill with admin@jyoti.com / admin123; Admin Dashboard opens | P1 | | |
| AUTH-03 | Retailer demo login | Tap **Retailer Demo** → **Sign In** | Home opens showing "Ram Kirana Store" and "Owner: Retailer Ram" | P1 | | |
| AUTH-04 | Pending account login | Log in as nirmala.store@example.com / Nirmala@123 | Pending approval screen opens | P1 | | |
| AUTH-05 | Empty fields | Tap Sign In with both fields empty | "Email is required" and "Enter password" shown; nothing submitted | P2 | | |
| AUTH-06 | Bad email format | Email `abc@` → Sign In | "Enter a valid email address" | P2 | | |
| AUTH-07 | Unknown email | `nobody@test.com` / `Test@1234` | Error message "No account found for this email address."; stays on Login | P1 | | |
| AUTH-08 | Wrong password on demo account | `admin@jyoti.com` / `wrong123` | Error shown; **not** logged in | P1 | | |
| AUTH-09 | Show/hide password | Tap the eye icon twice | Password shows then hides; long-press shows "Show password"/"Hide password" | P3 | | |
| AUTH-10 | No double submit | Tap Sign In many times quickly | Spinner shown; one login only; no duplicate screens | P2 | | |
| AUTH-11 | Switch to Sign Up | Tap **Sign Up** | Subtitle "Create Your Retailer Account"; fields Full Name, Phone Number, Business / Shop Name, Email, Password with helper texts; demo buttons hidden | P2 | | |
| AUTH-12 | Sign-up starts blank | Open Sign Up | All fields empty — no admin email/password prefilled | P2 | | |
| AUTH-13 | Name blocks digits | Type `Ram123` in Full Name | Digits cannot be typed | P2 | | |
| AUTH-14 | Name validation | Try `R`; `Ram  Kumar` (2 spaces); `रमेश काटकर` | "Name must be at least 2 characters"; "Name can only contain letters and spaces"; Hindi name accepted | P2 | | |
| AUTH-15 | Phone validation | Try `12345`; `5876543210`; `9876543210` | First two → "Enter a valid 10-digit Indian mobile number"; last accepted | P2 | | |
| AUTH-16 | Shop name validation | Try `Sai Kripa Traders & Co.`; `Shop@#`; `साई कृपा ट्रेडर्स` | 1st and 3rd accepted; `Shop@#` → "Only letters, numbers, spaces, & - . are allowed" | P2 | | |
| AUTH-17 | Password rules | Try `Ab1!` · `abcdefg1!` · `ABCDEFG1!` · `Abcdefgh!` · `Abcdefg1` · ` Abcdef1!` (leading space) · `Test@1234` | "at least 8 characters" · "uppercase" · "lowercase" · "number" · "special character" · "cannot start or end with a space" · accepted | P1 | | |
| AUTH-18 | Successful sign-up | Fill all fields validly → **Create Account** | Account created → Pending approval screen | P1 | | |
| AUTH-19 | Duplicate email | Log out, sign up again with the same email | "An account already exists with this email address."; no second account | P1 | | |
| AUTH-20 | Log in to new account | Log out, log in with the new account | Pending approval screen (until admin approves) | P1 | | |
| AUTH-21 | New account password check | Log in to the new account with a **wrong** password | Must be rejected *(see Known Issue KI-01)* | P1 | | |
| AUTH-22 | Sign-up is always retailer | Sign up a new account | It appears in Admin → Retailers → Pending; there is no way to self-register as admin | P1 | | |
| AUTH-23 | Keyboard handling | Fill sign-up form with keyboard open | Focused field stays visible; can scroll to Create Account | P3 | | |
| AUTH-24 | Login landscape | Rotate on Login and Sign Up | No overflow; form scrolls | P3 | | |

### 5.3 Pending approval (PEND)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| PEND-01 | Screen layout | Log in as pending account | "Account Verification Pending", message, **Check Status Again**, "Call Owner: +91 98604 60325", "Email: vishvatejkatkar007@gmail.com", **Browse Catalog While You Wait**, **Sign Out & Try Another Account** | P1 | | |
| PEND-02 | Call owner | Tap Call Owner | Phone dialer opens with 9860460325 | P2 | | |
| PEND-03 | Email support | Tap Email | Mail app opens to vishvatejkatkar007@gmail.com | P2 | | |
| PEND-04 | Check status (still pending) | Tap Check Status Again | "Checking verification status..." then stays on pending screen | P2 | | |
| PEND-05 | Approved → full access | Sign up new account → log out → admin approves it → log in as new account | Opens Home with full access (can add to cart, see Orders/Profile) | P1 | | |
| PEND-06 | Browse while waiting | Tap Browse Catalog While You Wait | Home opens with banner "Preview mode — you can order once your account is approved."; categories & products visible | P1 | | |
| PEND-07 | Pending cannot order | In preview: tap ADD; try Orders / Profile tabs; try floating cart bar | Every ordering route sends back to the Pending screen; no order can be placed | P1 | | |
| PEND-08 | Pending can search & view | In preview: Search "rice"; open a product | Search results and product detail open | P2 | | |
| PEND-09 | Sign out | Tap Sign Out & Try Another Account | Returns to Login | P1 | | |
| PEND-10 | Rejected account | Sign up → admin **rejects** → log in as that account | Red "Application Not Approved" screen with a block icon and the rejection message; contact title "Questions? Contact the Owner"; **no** "Browse Catalog" button; Call/Email/Sign out still work | P1 | | |
| PEND-11 | Landscape | Rotate on Pending screen | Scrolls, no overflow | P3 | | |

### 5.4 Navigation & app shell (NAV)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| NAV-01 | Retailer bottom nav | Log in as retailer | 4 tabs: Home, Search, Orders, Profile; selected tab highlighted | P1 | | |
| NAV-02 | Tab state kept | Scroll down Home → Search tab → back to Home | Home is still scrolled where you left it | P3 | | |
| NAV-03 | Exit confirmation | On any tab root press phone Back | "Exit app?" dialog; Cancel keeps app; confirm closes app | P1 | | |
| NAV-04 | Back through pushed screens | Home → category → product → Back → Back | Returns product → category → Home; no exit dialog until Home | P1 | | |
| NAV-05 | Floating cart bar appears | Add any product | Dark pill at bottom: item count, total, **View Cart** button; disappears when cart is emptied | P1 | | |
| NAV-06 | Cart bar doesn't hide content | With items in cart, scroll to bottom of Home, Orders, Profile, category grid | Last item fully visible above the bar | P2 | | |
| NAV-07 | View Cart & back | Category screen → View Cart → Back | Cart opens with back arrow; Back returns to the same category screen | P1 | | |
| NAV-08 | Cart count bounces | Add / remove items | Count on bar updates with a small bounce | P3 | | |
| NAV-09 | Transitions | Open product from grid | Smooth fade/slide; product photo "flies" from card to detail | P3 | | |
| NAV-10 | Admin bottom nav | Log in as admin | 5 tabs: Dashboard, Orders, Catalog, Retailers, Profile | P1 | | |
| NAV-11 | Admin exit confirmation | Back on an admin tab root | "Exit app?" dialog | P2 | | |
| NAV-12 | Logout from Home | Tap logout icon in Home app bar | "Log out?" confirmation; Cancel stays; Log Out goes to Login | P1 | | |
| NAV-13 | Back after logout | After logout press Back | Does not return into the app | P1 | | |

### 5.5 Retailer Home (HOME)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| HOME-01 | Header | Open Home | Shop name, "Owner: …", notification bell (with unread badge), wishlist icon, logout icon | P2 | | |
| HOME-02 | Banner carousel | Look at top banners | Admin offers first (if any), then built-in: minimum order ₹2,500, own fleet delivery, help number; auto-slides | P2 | | |
| HOME-03 | Categories grid | Scroll to Browse Categories | All 15 active categories with photo/icon and coloured ring; names readable | P2 | | |
| HOME-04 | Open category | Tap "Rice" | Category screen with Basmati Rice | P1 | | |
| HOME-05 | Top Products | Find Top Products | Basmati Rice, Wheat Atta, Fortune Oil, Pure Ghee | P2 | | |
| HOME-06 | Buy Again rail | As retailer@jyoti.com (has repeat orders) | "Buy Again" rail with often-bought products; first time a tip "Tap any item here to quickly reorder it"; after dismissing it never returns (even after restart) | P2 | | |
| HOME-07 | Low-stock banner | Retailer who often buys Toor Dal (stock 4) | Banner "1 of your regulars is low or out of stock." | P2 | | |
| HOME-08 | Live order strip | Place an order, return to Home | Strip "Order #xxxxxxxx is waiting for confirmation" + **Track** → opens order detail; strip text changes with status; hidden when no active order | P2 | | |
| HOME-09 | Search on Home | Type "rice" in Home search | Results appear in place of Home sections; ✕ clears and Home returns | P1 | | |
| HOME-10 | Back while searching | Type in Home search → press Back | Search clears — no "Exit app?" dialog | P2 | | |
| HOME-11 | Search icon inside field | Look at Home search bar | Magnifier icon sits inside the rounded field | P3 | | |
| HOME-12 | Wishlist hint | First run | Small red dot on wishlist icon; gone after tapping it once | P3 | | |
| HOME-13 | Images | Scroll Home | Shimmer while loading, then photos; no broken images | P3 | | |
| HOME-14 | Pull to refresh | Pull down on Home | Refresh spinner; content reloads; no duplicates | P3 | | |

### 5.6 Category products (CAT)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| CAT-01 | Category screen | Open "Other Grocery" | Title = category name; 2-column grid of its products | P1 | | |
| CAT-02 | Product card | Look at a card | Photo, name (≤2 lines), price & unit (or "from ₹x/kg" for kg items), **ADD** button with outline | P2 | | |
| CAT-03 | Category rail | Tap another category in the top rail | Grid switches in place, no new screen | P2 | | |
| CAT-04 | Long names | Card for "Assorted Biscuits Box (24 pack)" | No overflow; text not cut mid-word badly | P2 | | |
| CAT-05 | Out of stock card | Admin sets a product's stock to 0 → open its category | "Out of stock" badge over dimmed photo; no ADD | P2 | | |
| CAT-06 | Inactive product hidden | Admin turns a product's Active off | Product not shown to retailer anywhere (category, search, Home) | P1 | | |
| CAT-07 | Empty category | Admin creates a category with no products → open it | "No products in this category yet" | P3 | | |
| CAT-08 | Cart bar on category screen | Add an item | Floating cart bar shows at bottom, doesn't cover the last row | P1 | | |
| CAT-09 | Open product | Tap a card | Product detail opens | P1 | | |
| CAT-10 | Pull to refresh | Pull down | Grid reloads | P3 | | |

### 5.7 Quantity sheet from the ADD button (QTY)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| QTY-01 | Sheet opens (unit product) | Tap ADD on Wheat Atta | Sheet: presets 1, 2, 5, 10, 25; typed quantity field (digits only); "₹480 per box"; button "Add 1 box to Cart" | P1 | | |
| QTY-02 | Sheet opens (kg product) | Tap ADD on Turmeric | Presets 250 g, 500 g, 1 kg, 2.5 kg, 5 kg, 10 kg; field typed in **kg** (e.g. 2.5); rate & band shown; button "Add 1 kg to Cart" | P1 | | |
| QTY-03 | Confirm adds | Pick 2.5 kg → confirm | Card turns into a small − / + stepper showing 2.5 kg; item flies to cart bar; bar total +₹498.75 | P1 | | |
| QTY-04 | Card stepper steps | Use + / − on a kg card | Steps 100 g below 1 kg, 500 g up to 5 kg, 1 kg above; − to zero removes the item | P1 | | |
| QTY-05 | Re-open sets, not adds | Cart has 2 kg → tap card → pick 2 kg | Button says "Update to 2 kg"; cart stays **2 kg** (not 4 kg) | P1 | | |
| QTY-06 | Stock limit | Toor Dal (stock 4): open sheet, type 10 | Presets above 4 hidden; button shows the max that will actually be added (4) | P1 | | |
| QTY-07 | Minimum weight | Turmeric: type 0.05 | "Minimum 100 g"; add button disabled | P1 | | |
| QTY-08 | Cancel sheet | Open sheet → swipe down / tap outside | Nothing added | P2 | | |
| QTY-09 | Haptics | Tap stepper / ADD on a real phone | Light vibration feedback | P3 | | |

### 5.8 Product detail & weight pricing (PDP)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| PDP-01 | Layout (unit product) | Open Basmati Rice | Photo, name, ₹2,250 per box, "Sold per box", "40 box in stock", Description, quantity picker, "You may also like", bottom **Add** button "Add 1 box · ₹2,250" | P1 | | |
| PDP-02 | Zoom photo | Tap the photo | Full-screen viewer; pinch to zoom; close returns | P3 | | |
| PDP-03 | Wishlist heart | Tap heart twice | "Added to wishlist" then "Removed from wishlist"; icon fills/empties | P2 | | |
| PDP-04 | Unit quantity picker | Tap preset 5; type 12; tap − / + | Price on Add button updates (5 → ₹11,250); − halves, + doubles; digits only | P1 | | |
| PDP-05 | Stock cap | Toor Dal: try more than 4 | Cannot go above 4 (+ disabled, typed value clamped) | P1 | | |
| PDP-06 | Add confirmation | Tap Add | Small toast "… added to cart" with **VIEW CART**; toast does not follow you to the next screen | P2 | | |
| PDP-07 | Rate table (kg) | Open Turmeric | "Rate by quantity (₹ per kg)" table with 4 bands; the band for the chosen weight is highlighted | P1 | | |
| PDP-08 | Slab prices | Enter each weight from §3.3 | Price shown = table in §3.3 exactly (paise included) | P1 | | |
| PDP-09 | Band moves with weight | Change 900 g → 1 kg | Highlight moves to "1 kg – 2.4 kg"; ₹/kg drops | P1 | | |
| PDP-10 | Minimum weight | Type 0.05 | "Minimum 100 g"; Add disabled | P1 | | |
| PDP-11 | Out of stock | Product with stock 0 | Button "Out of Stock", disabled | P1 | | |
| PDP-12 | Add when already in cart | Toor Dal (stock 4): add 3 → reopen product page; then add 1 more | Add goes on top of the cart line; picker now only reaches 1 (what's left); once all 4 are in the cart the button reads "All available stock is already in your cart" and is disabled | P1 | | |
| PDP-13 | You may also like | Tap a suggested product | That product's detail opens | P3 | | |
| PDP-14 | Product removed | Admin deletes/deactivates a product the retailer is viewing → reopen | "This product is no longer available." | P3 | | |

### 5.9 Search (SRCH)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| SRCH-01 | Search tab | Tap Search tab | Back arrow, field focused with keyboard; "Search for products" empty state | P2 | | |
| SRCH-02 | Find product | Type `rice` | Basmati Rice shown (after a short pause) | P1 | | |
| SRCH-03 | Case & partial | Type `RICE`, then `bas` | Both find Basmati Rice | P2 | | |
| SRCH-04 | No results | Type `xyz` | 'No products found for "xyz"' | P2 | | |
| SRCH-05 | Recent searches | Search 6 different words, clear field | "Recent Searches" shows last 5; tap one re-runs it; **Clear** empties the list | P3 | | |
| SRCH-06 | Sort | Search `dal` → sort Price Low→High, High→Low, Relevance | Order changes correctly | P2 | | |
| SRCH-07 | In stock only | Set a product stock 0 (admin) → search it → toggle "In stock only" | Out-of-stock product hidden when on | P2 | | |
| SRCH-08 | Category chips | Search `powder` → tap category chips | Results limited to that category; "All" resets | P2 | | |
| SRCH-09 | Add from results | Tap ADD on a result | Quantity sheet opens; adds correctly | P1 | | |
| SRCH-10 | Shared with Home | Type on Home search → open Search tab | Same text & results | P3 | | |
| SRCH-11 | Back arrow | Tap back arrow on Search | Keyboard closes, goes to Home | P3 | | |
| SRCH-12 | Pull to refresh | Pull results down | Reloads | P3 | | |

### 5.10 Wishlist (WISH)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| WISH-01 | Empty wishlist | Open wishlist with nothing saved | "Nothing saved yet" + hint | P3 | | |
| WISH-02 | Save & view | Heart 2 products → open Wishlist (Home icon or Profile → Wishlist) | Both shown | P2 | | |
| WISH-03 | Remove | Un-heart one | It disappears from Wishlist | P2 | | |
| WISH-04 | Persists | Restart app | Wishlist still there | P2 | | |
| WISH-05 | Per account | Log in as another retailer | Their own (empty) wishlist — not the first user's | P2 | | |
| WISH-06 | Open product | Tap a wishlist item | Product detail opens | P3 | | |

### 5.11 Cart (CART)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| CART-01 | Empty cart | Open cart with no items | "Your cart is empty", **Browse Products** → Home | P2 | | |
| CART-02 | Line items | Add Atta ×2 and Turmeric 2.5 kg | Photo, name, qty; Turmeric line "2.5 kg @ ₹199.50/kg"; correct line totals | P1 | | |
| CART-03 | Change quantity | Use stepper on a line | Line total, subtotal, total update immediately | P1 | | |
| CART-04 | Below minimum | Cart = Basmati ×1 (₹2,250) | "Add ₹250 more to reach the ₹2,500 minimum order.", progress bar, "Suggested to reach ₹2,500" rail; **Proceed to Checkout disabled** | P1 | | |
| CART-05 | Exactly minimum | Cart = Fortune Oil + Wheat Atta + Instant Coffee (₹2,500) | Warning gone; Proceed enabled | P1 | | |
| CART-06 | Suggestion rail | Tap ADD in the "Suggested" rail | Item added; nudge updates/disappears when ≥ ₹2,500 | P2 | | |
| CART-07 | Swipe to delete + Undo | Swipe a line left | "… removed" with **Undo**; Undo puts it back with same qty | P1 | | |
| CART-08 | Delete icon | Tap bin icon on a line | Line removed | P2 | | |
| CART-09 | Clear all | Tap **Clear all** → Cancel; then **Clear all** → Clear all | "Clear cart?" dialog. Cancel keeps every item; confirming empties the cart and removes any coupon | P1 | | |
| CART-10 | WELCOME10 | Subtotal ≥ ₹2,500 → type `WELCOME10` → Apply | '"WELCOME10" applied'; Discount −₹250; Total reduced by ₹250 | P1 | | |
| CART-11 | Coupon below its minimum | Subtotal ₹2,250 → apply WELCOME10 | "Add ₹250 more to use this coupon"; no discount | P2 | | |
| CART-12 | Invalid coupon | Apply `ABC123` | "Invalid coupon code" | P2 | | |
| CART-13 | Lower-case code | Apply `welcome10` | Accepted | P3 | | |
| CART-14 | FLAT5 | Subtotal ₹5,600 → apply `FLAT5`; then raise subtotal to ₹12,000 | ₹280 off; at ₹12,000 discount is capped at ₹500 | P1 | | |
| CART-15 | Remove coupon | Tap **Remove** | Discount line gone; total restored | P2 | | |
| CART-16 | Coupon drops with cart | Apply WELCOME10 at ₹2,730, then remove items below ₹2,500 | Discount line disappears automatically | P2 | | |
| CART-17 | Coupon is session-only | Apply coupon → restart app | Coupon no longer applied (by design) | P3 | | |
| CART-18 | Delivery estimate | Look at totals | "Delivery Charge (estimated)" — same amount Checkout shows | P1 | | |
| CART-19 | Cart persists | Add items → restart app | Same items & quantities | P1 | | |
| CART-20 | Cart per account | Retailer A adds items → log out → log in as retailer B → log back as A | B's cart empty; A's cart back | P1 | | |
| CART-21 | Item count for kg | Cart = Turmeric 1 kg only | Bar/badge says "1 item" (not 1000) | P2 | | |
| CART-22 | Stock changed after adding | Add Toor Dal ×4 → admin sets stock 2 → checkout → Place Order | Order **not** placed; red message "Only 2 box of Toor Dal 10kg is left. Please reduce it in your cart."; cart unchanged. If the product was deleted/deactivated: "… is no longer available. Please remove it from your cart." | P1 | | |
| CART-23 | Proceed | Tap Proceed to Checkout (≥ ₹2,500) | Checkout opens | P1 | | |

### 5.12 Checkout (CHK)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| CHK-01 | Layout | Open Checkout | Delivery Address (Street / Shop Address, City, Pincode, "Use current location"), Payment Method (COD selected by default, UPI), Order Summary (Subtotal (n items), Delivery Charge, Discount if any, Grand Total), ETA, **Place Order** | P1 | | |
| CHK-02 | Address validation | Clear street & city; pincode `4110`; then `411001` | Required errors for street/city; "Enter a valid 6-digit pincode"; 411001 accepted | P1 | | |
| CHK-03 | Address prefill | Retailer with a saved/default address | Fields prefilled | P2 | | |
| CHK-04 | Use current location | Tap Use current location → Allow | "Detecting your location…" then "Detected: <address>"; delivery charge changes from ₹100 (estimated) to distance × ₹10 (see §3.5) | P1 | | |
| CHK-05 | Permission denied | Deny location permission → tap again | "Couldn't get your location. Check location permission and try again."; charge stays ₹100 estimated; no crash | P1 | | |
| CHK-06 | Location off | Turn phone location off → tap Use current location | Same friendly error, no crash | P2 | | |
| CHK-07 | ETA — no location | No location set | "Arrives in 1–2 days" | P2 | | |
| CHK-08 | ETA — near | Location ≈3 km, time before 3 PM / after 3 PM | "Arrives today" / "Arrives by tomorrow" | P2 | | |
| CHK-09 | ETA — medium & far | Location Kalmeshwar; then Wardha | "Arrives by tomorrow" (≈₹203); "Arrives in 2–3 days" (≈₹670) | P2 | | |
| CHK-10 | Grand total maths | Any cart with coupon + location | Grand Total = Subtotal − Discount + Delivery (to the paisa) | P1 | | |
| CHK-11 | Choose UPI | Tap UPI card | UPI selected (highlight); COD unselected | P1 | | |
| CHK-12 | Place COD order | COD → Place Order | Order Success screen | P1 | | |
| CHK-13 | Place UPI order | UPI → Place Order | UPI Payment screen | P1 | | |
| CHK-14 | No double order | Tap Place Order rapidly 3× | Exactly **one** order in My Orders | P1 | | |
| CHK-15 | Cart cleared after order | After success, open cart | Cart empty; coupon cleared | P1 | | |
| CHK-16 | Save address | Toggle "Save this address for later" without a label → Place Order; then add label "Shop" | "Add a label to save this address"; with label, address appears under "Saved addresses" next time | P2 | | |
| CHK-17 | Pick saved address | Tap a saved address chip | Fields fill with that address | P2 | | |
| CHK-18 | Back keeps cart | Back from Checkout | Cart unchanged | P2 | | |
| CHK-19 | Keyboard | Type pincode with keyboard open | Field visible; Place Order reachable by scrolling | P3 | | |

### 5.13 UPI payment (UPI)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| UPI-01 | Screen | Place a UPI order | "UPI Payment", "Pay ₹<grand total>", QR code, UPI ID `jyotitraders@upi`, copy icon, optional screenshot, **I Have Paid**, note "The admin will confirm your payment shortly after." | P1 | | |
| UPI-02 | Copy ID | Tap copy | "UPI ID copied."; paste elsewhere shows `jyotitraders@upi` | P2 | | |
| UPI-03 | QR is valid | Scan QR with GPay/PhonePe — **do NOT pay** (placeholder ID) | Payee "Jyoti Traders Wholesale", amount prefilled = grand total | P2 | | |
| UPI-04 | Screenshot | Tap screenshot → pick an image; then try again and cancel the picker | Preview shown; cancelling the picker causes no error | P2 | | |
| UPI-05 | I Have Paid | Tap I Have Paid | Order Success screen; order's payment shows "Payment claimed" | P1 | | |
| UPI-06 | Without screenshot | I Have Paid with no image | Works | P2 | | |
| UPI-07 | Leave without paying | On UPI screen press Back | Exploratory: order exists with payment Pending — record whether the retailer can come back to pay | P2 | | |
| UPI-08 | QR in dark mode | Dark mode | QR has a white background and still scans | P2 | | |

### 5.14 Orders — success, history, detail (ORD)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| ORD-01 | Success screen | Place an order | Animated tick, "Order Placed!", "Order #XXXXXXXX" (8 chars), message, **View Order**, **Continue Shopping** | P1 | | |
| ORD-02 | Success buttons | Tap each | View Order → order detail; Continue Shopping → Home | P2 | | |
| ORD-03 | Back on success | Press Back on success screen | Does not go back to Checkout with a full cart / no duplicate order | P1 | | |
| ORD-04 | Success landscape | Rotate | No overflow | P3 | | |
| ORD-05 | History list | Orders tab | "My Orders", newest first; each: Order #, "n items · date", status badge, amount | P1 | | |
| ORD-06 | Status filters | Tap All / Pending / Confirmed / Out for Delivery / Delivered / Cancelled | List filters; empty → "No delivered orders" etc. | P2 | | |
| ORD-07 | Empty history | New account | "No orders yet" | P3 | | |
| ORD-08 | Detail | Open an order | Tracking stepper (Placed → Confirmed → Out for Delivery → Delivered) animates to current step; items (kg lines "Turmeric … · 2.5 kg @ ₹199.50/kg"); DELIVERY ADDRESS; PAYMENT; totals | P1 | | |
| ORD-09 | Old prices frozen | Admin changes Basmati price → reopen an old order | Old order totals unchanged | P1 | | |
| ORD-10 | Cancel within 10 min | Fresh Pending order → Cancel → "Cancel this order?" → Yes, Cancel | "Order cancelled."; status Cancelled; stepper shows Cancelled | P1 | | |
| ORD-11 | Cancel dialog — No | Cancel → No | Order unchanged | P2 | | |
| ORD-12 | Cancel not allowed | Order older than 10 min, or already Confirmed by admin | No Cancel button | P1 | | |
| ORD-13 | Buy Again | Delivered order → Buy Again | "3 items added to cart" with VIEW CART; current prices used; qty capped at stock | P1 | | |
| ORD-14 | Buy Again partial | Delete/deactivate one product of that order → Buy Again | "… — 1 no longer available." | P2 | | |
| ORD-15 | Share order | Tap share icon | Share sheet with a readable text summary | P3 | | |
| ORD-16 | Invoice PDF | Tap "Share invoice (PDF)" | PDF opens/shares: seller, buyer, items, totals; Hindi/Marathi names render (no boxes); not offered for cancelled orders | P2 | | |
| ORD-17 | Status updates | Admin moves order to Out for Delivery → retailer reopens | Badge, stepper and Home strip show "out for delivery" | P1 | | |
| ORD-18 | Stock goes down on order | Note Toor Dal stock (4) → order 2 → admin Catalog | "Stock: 2"; ordering all 4 makes it "Out of stock" for retailers | P1 | | |
| ORD-19 | Kg stock goes down in kilos | Turmeric stock 50 → order 2.5 kg → admin Catalog | "Stock: 47.5" | P1 | | |
| ORD-20 | Cancel returns stock | Order Toor Dal ×2 (stock 4 → 2) → cancel within 10 min | Stock back to 4 | P1 | | |
| ORD-21 | Admin cancel / un-cancel | Admin sets an order to Cancelled, then back to Confirmed | Stock goes back up on Cancelled, down again on Confirmed | P2 | | |

### 5.15 Notifications (NOTI)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| NOTI-01 | Bell badge | Home with unread notifications | Badge shows unread count | P2 | | |
| NOTI-02 | Screen | Tap bell | Header ("n new" / "All caught up"), **Mark all read**, filter All / Unread (n), groups Today / Yesterday / Earlier this week / Earlier, coloured icon per type | P2 | | |
| NOTI-03 | Open order notification | Tap an order notification | Opens that order's detail; notification marked read | P2 | | |
| NOTI-04 | Mark all read | Tap Mark all read | All read; bell badge clears | P2 | | |
| NOTI-05 | Unread empty | Unread filter with none unread | "You're all caught up" | P3 | | |
| NOTI-06 | Broadcast arrives | Admin sends broadcast → retailer logs in | Broadcast appears as a notification | P2 | | |
| NOTI-07 | Promotions off | Settings → Notifications → Promotions off → admin broadcasts | Broadcast **not** added | P2 | | |
| NOTI-08 | Low stock alerts | Low Stock Alerts on, regular product goes ≤ 5 | Stock alert notification; off → none | P3 | | |
| NOTI-09 | Admin bell | Admin dashboard bell | Notifications screen opens | P3 | | |

### 5.16 Retailer profile (PROF)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| PROF-01 | Header | Profile tab | Avatar with camera badge, name, shop, stat pills: Orders / Business (₹ spent) / Since (month year) | P2 | | |
| PROF-02 | Change photo | Tap camera badge → pick photo; again → cancel | Avatar updates; cancel causes no error | P2 | | |
| PROF-03 | Completeness card | New account | "x% complete" + missing tasks (photo, delivery location, GST, payout); tap a task opens its editor; % rises after completing | P2 | | |
| PROF-04 | Quick actions | Tap Orders / Wishlist / Addresses / Support | Orders tab; Wishlist; saved addresses; support options | P2 | | |
| PROF-05 | Insights | Account with orders | "Your business": spent this month, orders this month, % vs same days last month, Most bought, Favourite category | P3 | | |
| PROF-06 | Edit address | Address row → edit → Save | "Saved"; pincode rule same as checkout; shows at checkout | P1 | | |
| PROF-07 | Discard guard | Edit a field → close sheet | "Discard changes?" → Keep editing keeps text; Discard closes without saving | P2 | | |
| PROF-08 | Business details | GST `27ABCDE1234F1Z5`; then `12345`; then blank; set hours / Open 24×7 | Valid saves; `12345` → "Enter a valid 15-character GST number"; blank allowed; hours saved | P2 | | |
| PROF-09 | Payout details | Account `123456789012` + IFSC `SBIN0001234`; then IFSC `SBIN1234`, account `123` | First saves; "Enter a valid 11-character IFSC code"; "Enter a valid 9-18 digit account number" | P2 | | |
| PROF-10 | Saved addresses | Addresses → set default (star), remove one | "Default address updated"; Remove asks confirmation → "Address removed"; labels Home/Shop/Warehouse shown | P2 | | |
| PROF-11 | Persists | Restart app | All profile edits kept | P1 | | |
| PROF-12 | Save animation | Save any section | Button morphs to green "✓ Saved!" and back | P3 | | |

### 5.17 Settings — both roles (SET)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| SET-01 | Rows | Profile → Settings tab (retailer and admin) | Appearance, Language, Text size, Notifications (retailer) / Delivery settings (admin), Change Password, Support, Clear image cache, About, Delete account (retailer only), Log Out | P1 | | |
| SET-02 | Appearance popup | Tap Appearance | Centred popup with System / Light / Dark and mini previews; **Done** | P1 | | |
| SET-03 | Switch theme live | Choose Dark, then Light | Whole app changes instantly, including bottom nav and the popup itself | P1 | | |
| SET-04 | Theme persists | Choose Dark → restart app | Still Dark | P1 | | |
| SET-05 | System theme | Choose System → toggle phone Dark theme | App follows the phone | P1 | | |
| SET-06 | Default theme | Fresh install | Light | P2 | | |
| SET-07 | Language | Choose हिन्दी, then मराठी, then English | UI language changes instantly; persists after restart | P1 | | |
| SET-08 | Text size | Try Auto / Small / Medium / Large | Live preview "Fresh stock, best prices, fast delivery." changes; applies app-wide | P2 | | |
| SET-09 | Notification prefs | Toggle Order Updates / Promotions / Low Stock Alerts → restart | Switches keep their state | P2 | | |
| SET-10 | Change password | Change Password → "We'll send a password reset link to <email>." → Send Link | Simulation mode: record message shown. With live Firebase: email arrives | P2 | | |
| SET-11 | Support | Support → Call / Chat on WhatsApp / Email | Dialer 9860460325; WhatsApp chat with +91 9860460325; mail app | P2 | | |
| SET-12 | Clear image cache | Tap it | "Image cache cleared"; images reload | P3 | | |
| SET-13 | About | Tap About | App name and "Version x.y.z (build)" | P3 | | |
| SET-14 | Privacy policy row | Look for it | Hidden for now (URL not set yet — expected) | P3 | | |
| SET-15 | Delete account — cancel | Delete account → Cancel | Nothing happens | P2 | | |
| SET-16 | Delete account | **Use a throwaway account.** Delete account → read message → password → Delete permanently | Back to Login; logging in again fails; past orders still visible to admin | P1 | | |
| SET-17 | Log out | Log Out → "Log out?" → Log Out | Login screen | P1 | | |
| SET-18 | Popup smoothness | Open/close popups repeatedly | No lag; tap outside closes | P3 | | |

### 5.18 Admin dashboard (ADSH)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| ADSH-01 | Stat cards | Open Dashboard | Pending Approvals, Total Retailers, Today's Orders, Today's Revenue with count-up animation; trend "x% vs last week" on orders/revenue | P1 | | |
| ADSH-02 | Numbers correct | Compare Pending card with Retailers → Pending; place a ₹2,730 order as retailer → back to admin | Pending count matches; Today's Orders +1; Today's Revenue + that order's total | P1 | | |
| ADSH-03 | Needs attention | Create: a pending sign-up, a UPI "I have paid" order, a stock ≤ 5, an order pending 30+ min | One chip per item with count; tapping each opens the matching filtered list; with nothing → "You're all caught up" | P1 | | |
| ADSH-04 | UPI chip filter | Tap "UPI payments to confirm" | Orders list shows only payment-claimed orders | P2 | | |
| ADSH-05 | Charts | Scroll | Orders — Last 7 Days (bars), Revenue by Category (donut), Retailer Growth (line), Order Status Funnel; tap shows tooltips; empty data shows the empty text | P2 | | |
| ADSH-06 | Top products | Scroll | Best sellers listed, or "No sales yet" | P3 | | |
| ADSH-07 | Approval preview | With > 3 pending | Up to 3 cards + "+n more waiting — tap View All"; View All → full queue | P2 | | |
| ADSH-08 | Shortcut buttons | Tap Delivery Settings, Send Broadcast, Home Banners | Each opens its screen | P2 | | |
| ADSH-09 | Pull to refresh | Pull down | Reloads | P3 | | |

### 5.19 Approvals & retailer detail (APPR)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| APPR-01 | Pending cards | Retailers → Pending | Shop name, owner, phone, address or "Address not provided yet"; Approve / Reject | P1 | | |
| APPR-02 | Approve | Tap Approve | "<name> approved successfully!"; moves to Approved; that retailer can now log in to Home | P1 | | |
| APPR-03 | Reject | Tap Reject | "<name> rejected."; removed from queue; retailer cannot order | P1 | | |
| APPR-04 | Retailer detail | Tap a card | Owner, Contact, Address/Location, GST, Business Hours, Bank Details, Registered On; Approve / Reject work here too | P2 | | |
| APPR-05 | Empty queue | Approve everyone | "Approval queue is clear!" | P3 | | |
| APPR-06 | Double tap | Tap Approve twice quickly | One approval, no error | P2 | | |
| APPR-07 | Pending count tab | Watch "Pending (n)" while approving | Count drops live | P3 | | |

### 5.20 Admin orders (AORD)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| AORD-01 | All orders | Orders tab | All retailers' orders with shop name, status badge, total; filter chips All + statuses; empty → "No delivered orders" etc. | P1 | | |
| AORD-02 | Export CSV | Tap export icon (with a filter on) | Share sheet with a .csv; opened in Sheets: correct columns, only filtered orders, Hindi/Marathi text readable | P2 | | |
| AORD-03 | Export empty | Filter with no orders → export | "No orders to export." | P3 | | |
| AORD-04 | Change status | Open order → status dropdown → Confirmed | "Status updated to Confirmed."; retailer sees Confirmed | P1 | | |
| AORD-05 | Full status flow | Pending → Confirmed → Out for Delivery → Delivered | Each change saved; retailer stepper follows | P1 | | |
| AORD-06 | Cancelled order | Open a retailer-cancelled order | Exploratory: record whether admin can still change its status | P2 | | |
| AORD-07 | UPI payment confirm | Open a payment-claimed UPI order | Payment status, screenshot visible; **Mark as Paid** → "Payment confirmed."; button disappears; retailer sees Paid | P1 | | |
| AORD-08 | COD order | Open a COD order | No payment-confirmation controls | P2 | | |
| AORD-09 | Invoice from admin | Share invoice on an order | PDF generated as in ORD-16 | P2 | | |
| AORD-10 | Pull to refresh | Pull down | Reloads | P3 | | |

### 5.21 Admin catalog — products (APRD)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| APRD-01 | Catalog tabs | Catalog tab | Products / Categories tabs; floating button switches "Add Product" ↔ "Add Category" | P1 | | |
| APRD-02 | Product list | Products tab | Name, "₹x · per unit", "Stock: n", Inactive badge; low stock in red + banner "1 product is low on stock (≤ 5)." | P2 | | |
| APRD-03 | Search / filter / sort | Search "dal"; category dropdown; sorts Name A–Z, Stock low first, Price low/high | List updates correctly; no match → "No products match" | P2 | | |
| APRD-04 | Add unit product | Add Product → name, category, price 99, unit piece, stock 10, description, photo → Save | "<name> added."; shows in admin list and for retailer | P1 | | |
| APRD-05 | Validation | Save empty; price 0; price `abc`; stock -1 | "Product name is required", "Category is required", "Price must be above ₹0", "Enter a valid price", "Stock cannot be negative" | P1 | | |
| APRD-05b | Decimal stock | Unit kg → stock `12.5` → Save; unit box → stock field | kg accepts 12.5 and shows "Stock: 12.5"; for box the `.` key can't be typed | P2 | | |
| APRD-06 | Add kg product | Unit = kg | Price field replaced by 4 rate fields prefilled 44 / 40 / 39 / 38; stock "In kilograms"; rate 0 → "Rate must be above ₹0" | P1 | | |
| APRD-07 | Edit product | Edit price → Save | "<name> updated."; retailer sees new price; no duplicate created | P1 | | |
| APRD-08 | Deactivate / reactivate | Turn Active off → Save; then on | Off: hidden from retailer, still in admin list with "Inactive"; On: visible again | P1 | | |
| APRD-09 | Top product | Turn Top Product on | Appears in retailer Home "Top Products" | P2 | | |
| APRD-10 | Photo | Pick photo from gallery; cancel picker once | Preview shown; cancel → no error | P2 | | |
| APRD-11 | Delete | Delete icon → dialog (suggests Active toggle) → Cancel; then Delete | Cancel keeps it; Delete → "<name> deleted." and gone for retailer | P1 | | |
| APRD-12 | Bulk edit stock | Select → tick 3 → Bulk Edit → Set stock to 50 → Apply | "3 of 3 products updated."; all show 50; Add button hidden while selecting | P2 | | |
| APRD-13 | Bulk edit price % | Bulk edit +10, then −5 | Prices change by those percentages; blank fields left unchanged | P2 | | |
| APRD-14 | Bulk edit validation | Stock `1.5`; price `abc` | "Enter a whole number"; "Enter a number" | P3 | | |
| APRD-15 | Long form | Add Product on small phone with keyboard | Can scroll to Save | P3 | | |

### 5.22 Admin catalog — categories (ACAT)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| ACAT-01 | Add category | Add Category → name, icon, Active → Save | Appears at the end of the list and on retailer Home | P1 | | |
| ACAT-02 | Name required | Save empty | "Category name is required" | P2 | | |
| ACAT-03 | Edit | Change name/icon | Updated everywhere | P2 | | |
| ACAT-04 | Reorder | Drag a category by its handle to the top | New order saved; retailer Home shows same order after restart | P2 | | |
| ACAT-05 | Deactivate | Active off | Hidden from retailer Home/rail; still in admin list | P1 | | |
| ACAT-06 | Edit product in hidden category | Edit a product whose category is inactive | Form opens with that category selected; no crash | P1 | | |
| ACAT-07 | Delete | Delete → dialog → Delete | Removed; its products no longer under any visible category (as the dialog says) | P2 | | |

### 5.23 Bulk import (BULK)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| BULK-01 | Open | Catalog → Bulk Import icon | Instructions + example header | P2 | | |
| BULK-02 | Valid CSV | Paste: `name,category,price,unit,stock,description` / `Test Rice 5kg,Rice,400,box,10,Demo` / `Test Soap,Cosmetics & Soaps,30,piece,100,` | Preview of 2 rows → **Import 2** → "2 product(s) created." | P1 | | |
| BULK-03 | Kg with rates | Add columns `below240g,upto999g,upto2400g,above2400g` for a kg row | Product created with those slab rates | P2 | | |
| BULK-04 | Bad rows | Unknown category, price `abc`, unit `bag` | Each bad row flagged "Row n" with a reason; good rows still import: "x product(s) created, y failed." | P2 | | |
| BULK-05 | Missing header | Paste rows without header | Clear error; nothing imported | P2 | | |
| BULK-06 | Paste from Excel/Sheets | Copy the header + rows from Google Sheets/Excel and paste | Imports exactly like comma-separated text; a comma inside a description cell stays in that cell | P1 | | |
| BULK-07 | Decimal stock | Row with unit `kg`, stock `12.5`; another with unit `box`, stock `2.5` | kg row imports with 12.5 kg; box row flagged "Stock must be a whole number ≥ 0" | P2 | | |

### 5.24 Home banners (BAN)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| BAN-01 | Empty | Dashboard → Home Banners (none) | "No banners yet" | P3 | | |
| BAN-02 | Add | Add banner → title, message, Show on Home on → Save | "Banner saved"; first slide in retailer Home carousel | P1 | | |
| BAN-03 | Title required | Save without title | "Enter a title" | P2 | | |
| BAN-04 | Hide | Show on Home off | Not shown to retailer | P2 | | |
| BAN-05 | End date | Set "Show until" to yesterday | Badge "Expired"; not shown to retailer; "Clear date" removes it | P2 | | |
| BAN-06 | Delete | Delete → confirm | "Banner deleted"; gone from Home | P2 | | |

### 5.25 Broadcast (BRD)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| BRD-01 | Empty history | Open Send Broadcast | "No broadcasts sent yet" | P3 | | |
| BRD-02 | Validation | Send with empty title/message | Blocked with errors | P2 | | |
| BRD-03 | Send | Title + message → Send to All Retailers | "Broadcast sent"; listed in history | P2 | | |
| BRD-04 | Received | Log in as retailer (Promotions on) | Appears in Notifications | P2 | | |

### 5.26 Delivery settings (DLV)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| DLV-01 | Open | From Dashboard button and from Admin Profile → Settings | Same screen both ways | P2 | | |
| DLV-02 | Rate controls | Use quick-rate chips and − / + | Hero ₹/km and "What retailers will pay" (2 / 5 / 10 / 25 km) update live; "Unsaved changes" shows | P2 | | |
| DLV-03 | Validation | Latitude `200`; rate `-5`; rate `abc` | "Enter a valid coordinate"; "Enter a valid rate" | P1 | | |
| DLV-04 | Use current location | Tap Use current location | Lat/Lng filled with phone location | P2 | | |
| DLV-05 | Save | Save | "✓ Delivery settings saved successfully"; "All changes saved" | P1 | | |
| DLV-06 | Applies to checkout | Set ₹15/km → retailer checkout with location | Charge = km × ₹15 | P1 | | |
| DLV-07 | Leave unsaved | Change rate → Back | Exploratory: record whether you're warned | P3 | | |

### 5.27 Retailers tab & admin profile (ARET / APROF)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| ARET-01 | Approved list | Retailers → Approved | Each retailer with total spend & order count, highest spend first | P2 | | |
| ARET-02 | Retailer orders | Tap a retailer | "<Shop> — Orders", only their orders, filters work | P2 | | |
| ARET-03 | Empty states | No approved retailers | "No approved retailers yet" | P3 | | |
| APROF-01 | Admin profile | Profile tab | Avatar, name, Account Info (Role: Administrator, Member since), Business Details ("Not set" or "Printed on every invoice"), Delivery Settings | P2 | | |
| APROF-02 | Edit profile | Edit icon → change name → Save | Name updated | P2 | | |
| APROF-03 | Business details | Business Details → Legal name, Registered address, GSTIN → Save; then share an invoice | Saved; printed on the invoice | P1 | | |
| APROF-04 | Admin settings | Settings tab | Same as SET-01 with Delivery settings; no Delete account | P2 | | |

### 5.28 Language (LOC)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| LOC-01 | Hindi — retailer | हिन्दी → walk Home, product, cart, checkout, orders, profile, settings | All text in Hindi; note any English left | P2 | | |
| LOC-02 | Marathi — retailer | मराठी → same walk | All text in Marathi | P2 | | |
| LOC-03 | Hindi/Marathi — admin | Walk every admin tab | All text translated | P2 | | |
| LOC-04 | No clipped Devanagari | Look at buttons, chips, cards, nav labels | No cut-off letters or overflow | P2 | | |
| LOC-05 | Error messages | Wrong pincode / password / coupon in Hindi | Should be Hindi *(currently English — KI-05)* | P3 | | |
| LOC-06 | Currency format | Big totals (e.g. ₹1,12,500) | Indian grouping and ₹ symbol in every language | P2 | | |
| LOC-07 | Persists | Restart | Same language | P2 | | |

### 5.29 Accessibility & screen sizes (UI)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| UI-01 | Large text | Text size Large → Home, category grid, product, cart, checkout, order detail, admin dashboard | No overflow; nothing cut off | P2 | | |
| UI-02 | Phone font at max | Android font size max + app Text size Auto | App caps the scale; layout still OK | P2 | | |
| UI-03 | Landscape | Rotate on Login, Pending, Home, Cart, Checkout, Order Success, Admin Dashboard | Scrollable, no overflow | P2 | | |
| UI-04 | Small screen | D2 emulator: full order flow | Everything reachable | P2 | | |
| UI-05 | Edge-to-edge (Android 15) | D3: Login, Onboarding, Pending, Order Success | Content not under status/nav bars; bar icons readable in both themes | P2 | | |
| UI-06 | Keyboard | Every form | Keyboard never hides the field being typed or the save button permanently | P2 | | |
| UI-07 | TalkBack | Turn on TalkBack; focus icon buttons | Bell, logout, delete, password eye, wishlist heart, quantity − / + read meaningful names | P3 | | |
| UI-08 | Tap targets | Use steppers with a thumb | Easy to hit; no accidental taps | P3 | | |

### 5.30 Performance, offline, data & security (SYS)

| ID | Test case | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| SYS-01 | Cold start | Kill app → open (logged in) | Home/Dashboard in under ~3 s on D1 | P2 | | |
| SYS-02 | Smooth scroll | Fling Home, category grid, admin product list | No stutter | P2 | | |
| SYS-03 | Long session | Use app 15 min across all screens | No slowdown, no crash | P3 | | |
| SYS-04 | Offline | Airplane mode → use app | Opens and works on local data; photos show placeholders; no crash | P2 | | |
| SYS-05 | Back online | Turn internet back on | Photos load | P3 | | |
| SYS-06 | Kill mid-flow | Kill app on Checkout → reopen | Cart intact; no half-created order | P2 | | |
| SYS-07 | Admin data persists | Admin edits product, category order, banner, delivery rate → restart | All kept | P1 | | |
| SYS-08 | Orders persist | Restart | All orders & statuses kept | P1 | | |
| SYS-09 | Clear data | Android Clear data | Fresh demo data, onboarding again | P2 | | |
| SYS-10 | Role isolation | Browse every retailer screen | No way to reach any admin screen | P1 | | |
| SYS-11 | Password never shown | Logs/snackbars during login errors | Password never displayed | P2 | | |
| SYS-12 | Demo login before launch | With live Firebase connected | "Simulation Demo Quick Login" must **not** appear | P1 | | |

---

## 6. End-to-end scenarios (cross-role, run on one phone)

| ID | Scenario | Steps | Expected result | Pri | ☀ | 🌙 |
|---|---|---|---|---|---|---|
| E2E-01 | New retailer, COD order to delivery | 1) Sign up new retailer 2) Admin approves 3) Retailer adds Basmati ×1 + Turmeric 2.5 kg (₹2,748.75) 4) WELCOME10 5) Checkout with location, COD 6) Admin: Confirmed → Out for Delivery → Delivered 7) Retailer checks order, shares invoice | Each step works; totals correct to the paisa; statuses match on both sides; invoice correct | P1 | | |
| E2E-02 | UPI order to paid | 1) Retailer UPI order + screenshot → I Have Paid 2) Admin sees "UPI payments to confirm" chip → opens order → sees screenshot → Mark as Paid 3) Retailer checks | Payment: Pending → Payment claimed → Paid; chip disappears | P1 | | |
| E2E-03 | Catalog changes reach retailer | 1) Admin adds category + kg product + banner 2) Retailer sees all, buys product at slab price 3) Admin deactivates product 4) Retailer can't see it; old order unchanged | All as described | P1 | | |
| E2E-04 | Cancel flow | Retailer orders → cancels within 10 min → admin views | Admin sees Cancelled; record whether dashboard revenue/orders count it | P2 | | |
| E2E-05 | Reorder with missing item | Delivered order → admin deletes one product → retailer Buy Again | Partial add message; cart correct | P2 | | |
| E2E-06 | Low stock loop | Admin sets Toor Dal stock 3 → retailer who buys it often opens app | Retailer: Home banner + stock notification; Admin: "Low stock" chip + red row | P2 | | |
| E2E-07 | Delivery rate change | Admin ₹10 → ₹15/km → retailer checkout same location | Charge × 1.5 | P1 | | |
| E2E-08 | Rejection | Sign up → admin rejects → log in | Cannot order; see PEND-10 | P2 | | |
| E2E-09 | Two retailers, one phone | Retailer A cart+wishlist → log out → Retailer B | B sees none of A's cart/wishlist; A's restored later | P1 | | |
| E2E-10 | Dark + Marathi + Large text | Set all three → full order flow + admin confirms | Works, readable, no overflow | P2 | | |

---

## 7. Theme sweep — every screen in Light and Dark

Open each screen/state once per theme and apply checklist §4 (V1–V12).

| ID | Screen / state | How to reach | ☀ | 🌙 |
|---|---|---|---|---|
| TH-01 | Splash | Open app | | |
| TH-02 | Onboarding (3 slides) | Clear data → open | | |
| TH-03 | Login + demo buttons | Logged out | | |
| TH-04 | Sign Up + field errors | Sign Up → submit empty | | |
| TH-05 | Error snackbar | Wrong login | | |
| TH-06 | Pending approval | Nirmala account | | |
| TH-07 | Home (preview mode banner) | Pending → Browse Catalog | | |
| TH-08 | Home (full: banners, live order, low stock, Buy Again, categories, Top Products) | retailer@jyoti.com | | |
| TH-09 | Home inline search results + empty result | Type in Home search | | |
| TH-10 | Exit app dialog | Back on a tab root | | |
| TH-11 | Logout confirm dialog | Home logout icon | | |
| TH-12 | Category grid + rail + out-of-stock card | Open a category | | |
| TH-13 | Quantity sheet (unit & kg) | ADD on a card | | |
| TH-14 | Product detail (unit) + toast | Open Basmati → Add | | |
| TH-15 | Product detail (kg) + rate table | Open Turmeric | | |
| TH-16 | Image zoom viewer | Tap product photo | | |
| TH-17 | Search tab: empty, recent, results, sort/filters | Search tab | | |
| TH-18 | Wishlist (empty & filled) | Wishlist icon | | |
| TH-19 | Floating cart bar | Add an item | | |
| TH-20 | Cart (empty) | Empty cart | | |
| TH-21 | Cart (below minimum: banner, progress, suggestions) | Basmati ×1 | | |
| TH-22 | Cart coupon applied / coupon error | Apply codes | | |
| TH-23 | Cart swipe-delete + Undo snackbar | Swipe a line | | |
| TH-24 | Checkout (address, payment cards, summary, ETA) | Proceed to Checkout | | |
| TH-25 | Location permission prompt & error text | Use current location → deny | | |
| TH-26 | UPI payment (QR, ID, screenshot) | UPI order | | |
| TH-27 | Order success animation | Place order | | |
| TH-28 | My Orders + filter chips + empty filter | Orders tab | | |
| TH-29 | Order detail (stepper, items, payment, cancel/buy again) | Open order | | |
| TH-30 | Cancel order dialog | Cancel on a new order | | |
| TH-31 | Notifications (hero, groups, unread filter, empty) | Bell | | |
| TH-32 | Profile tab (header, completeness, quick actions, insights) | Profile | | |
| TH-33 | Address / Business / Payout sheets + discard dialog | Profile rows | | |
| TH-34 | Saved addresses sheet | Profile → Addresses | | |
| TH-35 | Settings tab list | Profile → Settings | | |
| TH-36 | Appearance / Language / Text size / Support / About / Notifications popups | Settings rows | | |
| TH-37 | Change password & delete account dialogs | Settings rows | | |
| TH-38 | Admin dashboard (stat cards, attention strip, all 4 charts + tooltips) | Admin | | |
| TH-39 | Approval queue + retailer detail | Retailers → Pending | | |
| TH-40 | All orders + filters | Orders tab | | |
| TH-41 | Manage order (dropdown, payment, screenshot) | Open an order | | |
| TH-42 | Products list (low stock, inactive, selection/bulk bar) | Catalog → Products | | |
| TH-43 | Bulk edit dialog | Select → Bulk Edit | | |
| TH-44 | Add/Edit product (unit & kg forms, dropdowns, switches) | Add Product | | |
| TH-45 | Delete confirmation dialogs | Delete a product/category | | |
| TH-46 | Categories list (drag handles) + Add/Edit category | Catalog → Categories | | |
| TH-47 | Bulk import (input, preview, row errors) | Bulk Import | | |
| TH-48 | Home banners list + editor sheet + date picker | Dashboard → Home Banners | | |
| TH-49 | Send broadcast | Dashboard → Send Broadcast | | |
| TH-50 | Delivery settings (hero, chips, samples, save bar) | Dashboard → Delivery Settings | | |
| TH-51 | Retailers approved list + retailer orders | Retailers tab | | |
| TH-52 | Admin profile + Business details sheet | Admin Profile | | |
| TH-53 | Invoice PDF (opened in a viewer) | Share invoice | | |
| TH-54 | Loading shimmer & error/retry states | Airplane mode + pull to refresh | | |
| TH-55 | Status bar / nav bar icons on every full-screen page | All of the above | | |

---

## 8. Bug reporting

Log bugs in the **Bug Log** sheet of the Excel tracker (or any sheet) with these fields:

| Field | Example |
|---|---|
| Bug ID | BUG-07 |
| Test case ID | CART-10 |
| Title | WELCOME10 discount not removed after Clear all |
| Severity | Critical / Major / Minor / Cosmetic |
| Theme | Light / Dark / Both |
| Language | EN / HI / MR |
| Device | D1 Redmi, Android 13 |
| Steps to reproduce | 1) … 2) … 3) … |
| Expected | … |
| Actual | … |
| Screenshot / video | file name |
| Status | Open / Fixed / Verified / Won't fix |

**Severity guide:** **Critical** — crash, data loss, wrong money amount, wrong person sees data, can't log in/order. **Major** — feature broken but a workaround exists. **Minor** — small functional glitch. **Cosmetic** — looks wrong (colour, spacing, text cut) but works.

---

## 9. Known issues & questions found while writing this plan

Check these first — they are likely to show up as failures.

| ID | Where | Issue | Type |
|---|---|---|---|
| KI-01 | Login (simulation mode) | Self-signed-up accounts can log in with **any** password — the simulated login only checks the email. Real Firebase will check passwords; re-test AUTH-21 after Firebase is connected | Sim-only bug |
| KI-02 | Pending screen | ✅ **Fixed 2026-10-15** — a rejected retailer now sees "Application Not Approved" (was: "Verification Pending" forever). Verify with PEND-10 | Bug / UX |
| KI-03 | Product detail | ✅ **Fixed 2026-10-15** — Product Detail and Buy Again can only add what's left after the cart line; checkout also re-checks live stock. Verify with PDP-12, CART-22 | Bug |
| KI-04 | Cart | ✅ **Fixed 2026-10-15** — Clear all now asks "Clear cart?" first. Verify with CART-09 | UX |
| KI-05 | All forms, coupons | Validation messages ("Enter a valid 6-digit pincode", password rules…) and coupon messages ("Invalid coupon code") are English-only — not translated to Hindi/Marathi | Localization gap |
| KI-06 | Orders / stock | ✅ **Fixed 2026-10-15** — stock now drops when an order is placed and comes back if it's cancelled; kg stock keeps decimals. Verify with ORD-18…21. *Still tell the client this is the rule now* | Business rule |
| KI-07 | Bulk import | ✅ **Fixed 2026-10-15** — tab-separated paste from Excel/Google Sheets is detected and imported. Verify with BULK-06 | Bug |
| KI-08 | Coupons | WELCOME10 always gives exactly ₹250 (10% of any cart ≥ ₹2,500 hits the ₹250 cap) — fine if intended, worth telling the client | Business question |
| KI-09 | Placeholders | UPI ID `jyotitraders@upi`, empty seller GSTIN/address, no privacy-policy URL — must be replaced before launch | Launch blocker |
| KI-10 | Category rail | "Firecrackers" wraps mid-word in the category rail | Cosmetic |
| KI-11 | Product page, cart, orders | ✅ **Fixed 2026-10-15** — per-kg rates were shown rounded to whole rupees ("2.5 kg @ ₹200/kg" while ₹199.50/kg was charged). Every rate now shows exact paise when it has any (₹204.75/kg, ₹199.50/kg) and stays clean when whole (₹231/kg). Verify with PDP-07, CART-02, ORD-08 | Bug (display) |
| KI-12 | Checkout, order cancel | ✅ **Fixed 2026-10-15** — after Place Order the order *was* saved but the screen stayed on Checkout (a profile save rebuilt the cart mid-order). Also closed a double-tap window that could create two orders, and the cancel controller being torn down mid-cancel (the "Order cancelled." message never showed). Verify with CHK-12, CHK-14, ORD-10 | Bug |
| KI-13 | Admin product / category lists | Delete, bulk edit, reorder and bulk import call an auto-disposing controller the screen doesn't watch — same pattern as KI-12's cancel bug. Harmless in **release** builds (the action completes, the result message shows); in **debug** builds a "used after dispose" error can appear in the log. Fixed 2026-11-07: those screens now watch the controller (multi-row bulk-import test added) | Fixed |

---

## 10. Exit criteria (ready to release)

- [ ] 100% of **P1** cases pass in **both** Light and Dark
- [ ] ≥ 95% of P2 cases pass; every failure has a logged bug with a decision (fix now / later)
- [ ] No open **Critical** or **Major** bugs
- [ ] Theme sweep (§7) — every screen checked in both themes
- [ ] Full order flow passes in English, Hindi and Marathi
- [ ] Known issues KI-01…KI-10 each either fixed, accepted by the client, or scheduled
- [ ] Re-run AUTH, PEND, NOTI, SET and APPR after connecting the live Firebase project
- [ ] Automated checks green: `flutter analyze` (0 issues) and `flutter test` (all passing)

---

## 11. Summary (fill in at the end)

| | Total | ✅ Pass | ❌ Fail | ⏸ Blocked | ➖ N/A |
|---|---|---|---|---|---|
| Light ☀ | | | | | |
| Dark 🌙 | | | | | |

Tested by: ________ · Date: ________ · Build/version: ________ · Device(s): ________
