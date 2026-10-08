# Figma reference — "Polished Mobile App UI"

Source code pulled from the Figma Make prototype the user shared, so we don't
have to re-open/re-click through the flaky Figma Make editor UI every session.

**Figma file:** https://www.figma.com/make/JIugBreYxgbqImxliaghaX/Polished-Mobile-App-UI

**Important context:** this prototype was itself generated *from* this Flutter
app — its build log (visible in Figma Make's own AI chat history when you open
the file) says it was built from PDF exports of this app's screens
(`Jyoti_Traders_Admin_App.pdf`, `Jyoti_Traders_Customer_App.pdf`,
`Jyoti_Traders_Component_Library.pdf`), then "polished" by AI with a modern
quick-commerce look (Zepto/Blinkit-inspired). It already uses the same violet
primary (`#7C3AED`) as `lib/core/constants/app_colors.dart`. So this folder is
a **refinement reference**, not a spec to build from scratch — cross-check
against the existing Flutter screens in `lib/features/**/screens/` before
changing anything, most differences are just spacing/border/color polish.

## What's fully captured

- `src/App.tsx` — screen router/shell (phone-frame wrapper, slide transitions)
- `src/components.tsx` — shared components: `BackButton`, `StatusBadge`,
  `Toggle`, `CartBar`, `BottomNav`/`AdminBottomNav`, `Avatar`, `Spinner`,
  `SectionHeader`, `FormField`, `Input`, `Select`
- `src/context.tsx` — app state (navigation history, cart, admin mode,
  notifications, retailers, orders)
- `src/data.ts` — full mock data (categories, products, orders, retailers,
  notifications)
- `src/types.ts` — all TypeScript interfaces
- `src/index.css` — fonts, background color, animation keyframes/classes

## What's partially captured

- `src/screens/account.tsx` (460 lines total, ~210 captured) — has the full
  `MyOrders` screen and most of `OrderDetail` (through the items/totals
  section). Missing: the rest of `OrderDetail`'s delivery/payment block and
  buy-again/cancel actions, plus the entire `Notifications` and `Profile`
  screens.

## Not captured (ran out of reliable editor access this session)

- `src/screens/admin.tsx` (782 lines) — AdminDashboard, AdminOrders,
  AdminOrderDetail, AdminCatalog, AdminRetailers, AdminRetailerDetail,
  AdminDeliverySettings, AdminProductForm, AdminCategoryForm
- `src/screens/auth.tsx` (275 lines) — Splash, SignIn, SignUp, PendingApproval
- `src/screens/commerce.tsx` (422 lines) — Cart, Checkout, UPIPayment,
  OrderSuccess
- `src/screens/home.tsx` (209 lines) — Home (Buy Again rail, category grid,
  low-stock banner, delivery banner)
- `src/screens/products.tsx` (360 lines) — CategoryProducts, ProductDetail,
  Search

For all of these, the **design system captured above already covers the
visual recipe** (colors, spacing, radii, the shared badge/nav/input/button
components) — most of what's missing is screen-specific layout structure, not
new visual tokens. The screen-by-screen feature list (what each screen
contains) is preserved below from Figma's own build summary, which is enough
to compare against the existing Flutter screens without the exact JSX.

## How to pull the rest later

1. Open the file in the Figma Make **code editor** (not the plain preview):
   append nothing extra to the URL above — Figma auto-redirects a bare
   `/make/<id>/<slug>` URL into the editor with the diff panel open on the
   left.
2. In the left panel, click "Show all" under "Edited 12 files" to reveal
   every file, then click each `src/screens/*.tsx` row to expand its diff.
3. Use a page-text extraction tool (not screenshots — the diff panel is a
   canvas-rendered React app that renders each expanded file's full source as
   real DOM text, even though only a few lines are visible in the scrollable
   box). Save each result to the matching path under `figma_reference/src/`.
4. Known friction: the diff panel occasionally shows "Diff unavailable" or
   "Couldn't load Make" — a full page reload (re-navigate to the same URL)
   usually fixes it. The clickable demo-login buttons in the live preview pane
   are unreliable to drive via automated clicks (coordinates that visually
   line up with the button often don't register) — don't rely on the
   interactive preview if the code editor is available instead.

## Screen inventory (from Figma's build summary — useful even without the JSX)

**Customer app (17 screens):**
Splash → Sign In / Sign Up → Pending Approval; Home (Buy Again rail, 8-category
grid, Today's Picks, low-stock banner, delivery banner); Category Products
(2-col grid); Product Detail (quantity presets, price tiers, stepper,
add-to-cart toast); Search (recent chips + live results); Cart (min-order
warning, qty controls); Checkout (address, COD/UPI, order summary); UPI
Payment (QR grid, UPI ID copy, screenshot upload); Order Success (animated
checkmark); My Orders (5 filter tabs); Order Detail (status timeline, items,
totals, buy-again/cancel); Notifications (unread dots); Profile (business
details, payout info, delivery address, settings tab).

**Admin app (9 screens):**
Dashboard (stat cards, 7-day bar chart, retailer approval queue); All Orders
(filter tabs); Manage Order (status dropdown, mark-as-paid); Catalog
(Products + Categories tabs, low-stock alert); Add/Edit Product form (tiered
pricing grid); Add/Edit Category form; Retailers (Approved + Pending tabs);
Retailer Detail (full info, approve/reject); Delivery Settings (lat/lng,
per-km rate).

## Design tokens (already applied to the Flutter app as of 2026-09-01)

- Primary: `violet-600` / `#7C3AED`
- Page background: `#F1F0F5` (lavender-tinted off-white)
- Font: Inter, weights 400–800
- Status badges: `bg-{color}-50` + `border-{color}-200` + `text-{color}-700`,
  fully rounded — pending=amber, confirmed=blue, out-for-delivery=violet,
  delivered=emerald, cancelled/rejected=red, approved=emerald, inactive=slate
- Inputs: `rounded-xl`, `border-slate-200`, focus → `border-violet-500` +
  `ring-2 ring-violet-100`
- Bottom nav: plain icon+label color swap (slate-400 → violet-600), **no**
  Material-style selection pill/indicator
- Radii: 12px (`rounded-xl`), 16px (`rounded-2xl`), full pill
- Motion: screen-enter slide 0.2s ease-out, fade 0.25s, scale-in 0.35s
  cubic-bezier(0.34,1.56,0.64,1) (bouncy), slide-up 0.18s, spin 0.9s,
  pulse 1.5s
