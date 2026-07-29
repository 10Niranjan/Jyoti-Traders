# Session notes — 2026-07-28 — Retailer Profile screen overhaul

## What was asked
Analyze the retailer Profile/Settings page for usability, then implement improvements:
1. ~~Avatar/identity anchor~~ (explicitly skipped — not requested)
2. Visually distinguish read-only vs editable fields
3. Section the page into cards instead of one flat list
4. Sticky Save bar that only appears when the form is dirty
5. Dirty-state guard (confirm before discarding unsaved changes)
6. Show an error (not just silence) if Save fails
7. GST field helper text
8. Replace the raw lat/lng "coordinates" location concept with something more scalable (resolved, human-readable address)
9. Add account-level settings: Bank & Payout details, Business Hours, Notification preferences
10. Logout confirmation dialog

## What was implemented (all 8 points done, code complete)

**New domain entities** (`lib/domain/entities/`):
- `AddressEntity` — added `formattedAddress` field + `copyWith`
- `BankDetailsEntity` (new) — accountHolderName, accountNumber, ifscCode, bankName, upiId; has `maskedAccountNumber` / static `maskAccountNumber()`
- `BusinessHoursEntity` (new) — openTime/closeTime ("HH:mm" strings), is24x7
- `NotificationPreferencesEntity` (new) — orderUpdates, promotions, lowStockAlerts (all default `true` so existing accounts keep today's behavior)

**Data/repo layer:**
- `UserModel` extended with bankDetails/businessHours/notificationPreferences (fromJson/toJson/copyWith/toEntity)
- `UserEntity` extended to match
- `AuthRepository` interface + `FirebaseAuthRepository.updateProfile()` extended (both mock/Hive branch and real Firestore branch); also fixed a pre-existing bug where lat/lng were silently dropped on Firestore save
- `ProfileController.updateProfile()` passes through the new fields

**Location redesign:**
- New `GeocodingService` (`lib/core/services/geocoding_service.dart`) wraps the `geocoding` package for on-device reverse geocoding
- "Use current location" now resolves GPS → real address, auto-fills empty street/city/pincode, shows resolved address text. Raw coordinates are never shown to the user, only kept internally for delivery-charge calc
- `AddressFormFields` (shared widget, also used by `CheckoutScreen`) redesigned around `resolvedAddress` instead of a boolean `hasCoordinates`
- `CheckoutScreen` updated to match the new widget API and also does reverse geocoding now

**New shared widgets** (`lib/shared/`):
- `widgets/section_card.dart` — titled card wrapper (used for every section)
- `widgets/read_only_field.dart` — locked/muted info row with lock icon, for identity fields
- `utils/snackbar_helper.dart` — `showAppSnackBar()` consistent success/error snackbar

**`ProfileScreen` rewrite** (`lib/features/profile/screens/profile_screen.dart`):
- Sectioned into cards: Business Identity (read-only) / Delivery Address / Business Details (GST + Business Hours) / Bank & Payout Details / Notifications / Support / Appearance
- Dirty-tracking via listeners on every controller + explicit `_markDirty()` on toggles/switches/time pickers
- Sticky bottom Discard/Save bar, visible only when dirty (`AnimatedSize`)
- `PopScope` back-guard with a "Discard changes?" confirm dialog
- `ref.listen` on `profileControllerProvider` for save error (error snackbar) and save success (success snackbar + clears dirty state)
- GST field now has helper text explaining format/purpose
- Bank & Payout section: masked view (e.g. "•••• •••• 4521") with an Edit/Add/Done toggle
- Business Hours: Open-24-hours switch + Opens/Closes time pickers
- Notifications: 3 switches (Order Updates, Promotions & Offers, Low Stock Alerts)
- Logout confirmation dialog (mentions unsaved changes if dirty)

## Build/infra fixes needed along the way
- Added `geocoding` package to `pubspec.yaml`. Initial `^3.0.0` failed on-device: `geocoding_android`'s AAR requires compileSdk 34+, project was on 33.
  - Bumped `android/app/build.gradle.kts` `compileSdk` from `flutter.compileSdkVersion` to a hardcoded `36`.
  - That alone wasn't enough — `geocoding_android` 3.3.1 itself was still built against API 33 internally. Fixed by bumping the pubspec constraint to `geocoding: ^4.0.0` (resolves `geocoding_android: 4.0.1`), NOT `^5.0.0` (that pulls in `geocoding_darwin`→`pigeon`, which conflicts with `riverpod_generator`'s `analyzer` constraint — version solving fails).
- `flutter analyze` clean, all 120 existing tests pass (had to update `FakeAuthRepository` in `test/widget/profile_screen_test.dart` and `test/widget/upi_payment_screen_test.dart` to match the new `updateProfile()` signature).

## Manual on-device verification (Xiaomi phone, Android 13, via adb)
Signed in with the simulation-mode seeded retailer account: **`retailer@jyoti.com` / `retailer123`** (there's also a "Retailer Demo" quick-login button on the sign-in screen — its tap coordinates are `[551,1995][978,2105]` at 1080×2400 if doing this again via adb).

Confirmed working on-device:
- ✅ Sectioned cards render correctly, all 7 sections present
- ✅ Read-only Owner Name / Phone Number show with lock icons
- ✅ GST helper text renders
- ✅ Business Hours (24h switch + Opens/Closes time fields) renders
- ✅ Bank & Payout Details section renders in "Add" mode (empty state) with all 5 fields
- ✅ Notifications section — 3 switches, toggled Promotions off successfully
- ✅ **Sticky Save/Discard bar correctly appeared** the instant a toggle changed (dirty-tracking works)
- ✅ Appearance section still works (Dark mode was active)

## ⚠️ Bug found, NOT yet fixed — pick this up first tomorrow
Pressed the **Android system back button** while the sticky Save/Discard bar was showing (i.e. while dirty), expecting the `PopScope` "Discard changes?" dialog. **Instead the app closed straight to the home screen** — the dialog never appeared.

Root cause (hypothesis, not yet confirmed by reading code): `ProfileScreen` is very likely the root of a bottom-nav tab (an `IndexedStack`/`StatefulShellRoute` branch in go_router, given Home/Search/Cart/Orders/Profile bottom nav), meaning there's no route on the Navigator stack for `PopScope` to intercept — system back at the tab-root level pops the whole app (or the shell route) rather than triggering `PopScope.onPopInvokedWithResult` on `ProfileScreen`'s own Navigator.

**To fix tomorrow:** check how go_router is configured for the bottom-nav shell (`lib/core/navigation/` presumably) — whether it's `StatefulShellRoute.indexedStack` — and figure out where the back-press is actually being handled (probably needs the `PopScope` higher up in the shell, or the shell's own back-handling needs to check each branch's dirty state, or `ProfileScreen`'s `PopScope` needs `canPop` wired differently for a tab-root context). This is a real gap — right now a retailer who edits their profile and hits back will silently lose their changes with no warning, which defeats the whole point of item #5.

## Not yet done
- Haven't tested: Save Changes actually persisting (didn't get to tap Save before the interruption)
- Haven't tested: Discard button behavior
- Haven't tested: "Use current location" / geocoding flow on-device (needs location permission grant + GPS)
- Haven't tested: Logout confirmation dialog
- Haven't tested: Bank & Payout edit → masked view toggle after entering data
- Haven't tested light mode / System theme rendering of the new screen
- Nothing has been committed to git yet — all changes are local/uncommitted

## Where things are
- Dev server / app was running via `flutter run -d 4523b0eb` in a background task — likely killed when the phone went to home screen or session ended; will need to relaunch tomorrow.
- All code changes are uncommitted in the working tree (`git status` will show them).
