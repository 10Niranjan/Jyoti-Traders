import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Browse the Full Catalog'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Wholesale and retail categories, curated products, always up to date.'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Bulk Orders, Better Prices'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Order from ₹2,500 and get it delivered straight to your shop.'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Pay Your Way'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery or UPI — track every order from placement to delivery.'**
  String get onboardingSlide3Subtitle;

  /// No description provided for @authSubtitleLogin.
  ///
  /// In en, this message translates to:
  /// **'Wholesale & Retail Market Hub'**
  String get authSubtitleLogin;

  /// No description provided for @authSubtitleSignup.
  ///
  /// In en, this message translates to:
  /// **'Create Your Retailer Account'**
  String get authSubtitleSignup;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullName;

  /// No description provided for @authFullNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Letters and spaces only'**
  String get authFullNameHelper;

  /// No description provided for @authPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneNumber;

  /// No description provided for @authPhoneHelper.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get authPhoneHelper;

  /// No description provided for @authBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Business / Shop Name'**
  String get authBusinessName;

  /// No description provided for @authBusinessNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Letters, numbers, spaces, & - . allowed'**
  String get authBusinessNameHelper;

  /// No description provided for @authEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailAddress;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordHelperSignup.
  ///
  /// In en, this message translates to:
  /// **'8+ chars with upper, lower, number & symbol'**
  String get authPasswordHelperSignup;

  /// No description provided for @authEnterPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get authEnterPasswordError;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authNoAccount;

  /// No description provided for @authHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authHasAccount;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @authDemoLoginLabel.
  ///
  /// In en, this message translates to:
  /// **'Simulation Demo Quick Login:'**
  String get authDemoLoginLabel;

  /// No description provided for @authAdminDemo.
  ///
  /// In en, this message translates to:
  /// **'Admin Demo'**
  String get authAdminDemo;

  /// No description provided for @authRetailerDemo.
  ///
  /// In en, this message translates to:
  /// **'Retailer Demo'**
  String get authRetailerDemo;

  /// No description provided for @homeDefaultCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Valued Customer'**
  String get homeDefaultCustomerName;

  /// No description provided for @homeDefaultBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Retailer'**
  String get homeDefaultBusinessName;

  /// No description provided for @homeOwnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner: {name}'**
  String homeOwnerLabel(String name);

  /// No description provided for @homeBrowseCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse Categories'**
  String get homeBrowseCategories;

  /// No description provided for @homeNoCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get homeNoCategoriesTitle;

  /// No description provided for @homeNoCategoriesMessage.
  ///
  /// In en, this message translates to:
  /// **'Check back soon — the admin is setting up the catalog.'**
  String get homeNoCategoriesMessage;

  /// No description provided for @homeLowStockBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 of your regulars is low or out of stock.} other{{count} of your regulars are low or out of stock.}}'**
  String homeLowStockBanner(num count);

  /// No description provided for @homeBuyAgain.
  ///
  /// In en, this message translates to:
  /// **'Buy Again'**
  String get homeBuyAgain;

  /// No description provided for @homeTodaysPicks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Picks'**
  String get homeTodaysPicks;

  /// No description provided for @homeFromRatePerKg.
  ///
  /// In en, this message translates to:
  /// **'from ₹{rate}/kg'**
  String homeFromRatePerKg(String rate);

  /// No description provided for @homeOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get homeOutOfStock;

  /// No description provided for @homeOnlyLeftInStock.
  ///
  /// In en, this message translates to:
  /// **'Only {stock} {unit} left'**
  String homeOnlyLeftInStock(int stock, String unit);

  /// No description provided for @pendingUnableToDialPhone.
  ///
  /// In en, this message translates to:
  /// **'Unable to dial phone: 9860460325'**
  String get pendingUnableToDialPhone;

  /// No description provided for @pendingUnableToOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Unable to open email client: vishvatejkatkar007@gmail.com'**
  String get pendingUnableToOpenEmail;

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Verification Pending'**
  String get pendingTitle;

  /// No description provided for @pendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your retailer application is currently being reviewed by the owner of Jyoti Traders. Once approved, you will gain full access to wholesale product purchasing.'**
  String get pendingMessage;

  /// No description provided for @pendingCheckingStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking verification status...'**
  String get pendingCheckingStatus;

  /// No description provided for @pendingCheckStatusAgain.
  ///
  /// In en, this message translates to:
  /// **'Check Status Again'**
  String get pendingCheckStatusAgain;

  /// No description provided for @pendingContactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Need Urgent Approval? Contact Support'**
  String get pendingContactSupportTitle;

  /// No description provided for @pendingCallOwner.
  ///
  /// In en, this message translates to:
  /// **'Call Owner: +91 98604 60325'**
  String get pendingCallOwner;

  /// No description provided for @pendingEmailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email: vishvatejkatkar007@gmail.com'**
  String get pendingEmailSupport;

  /// No description provided for @pendingSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out & Try Another Account'**
  String get pendingSignOut;

  /// No description provided for @pendingBrowseCatalog.
  ///
  /// In en, this message translates to:
  /// **'Browse Catalog While You Wait'**
  String get pendingBrowseCatalog;

  /// No description provided for @homePendingBanner.
  ///
  /// In en, this message translates to:
  /// **'Preview mode — you can order once your account is approved.'**
  String get homePendingBanner;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchHint;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search for products'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a product name like \"rice\" or \"oil\".'**
  String get searchEmptyMessage;

  /// No description provided for @searchRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get searchRecentSearches;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClear;

  /// No description provided for @searchNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No products found for \"{query}\"'**
  String searchNoResultsFor(String query);

  /// No description provided for @searchSortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get searchSortRelevance;

  /// No description provided for @searchSortPriceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get searchSortPriceLowToHigh;

  /// No description provided for @searchSortPriceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get searchSortPriceHighToLow;

  /// No description provided for @searchInStockOnly.
  ///
  /// In en, this message translates to:
  /// **'In stock only'**
  String get searchInStockOnly;

  /// No description provided for @searchAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchAllCategories;

  /// No description provided for @productDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetailsTitle;

  /// No description provided for @wishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlistTitle;

  /// No description provided for @wishlistEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get wishlistEmptyTitle;

  /// No description provided for @wishlistEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a product to save it for later.'**
  String get wishlistEmptyMessage;

  /// No description provided for @wishlistAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist'**
  String get wishlistAdded;

  /// No description provided for @wishlistRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get wishlistRemoved;

  /// No description provided for @wishlistAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to wishlist'**
  String get wishlistAddTooltip;

  /// No description provided for @wishlistRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from wishlist'**
  String get wishlistRemoveTooltip;

  /// No description provided for @productNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This product is no longer available.'**
  String get productNoLongerAvailable;

  /// No description provided for @productSoldPer.
  ///
  /// In en, this message translates to:
  /// **'Sold per {unit}'**
  String productSoldPer(String unit);

  /// No description provided for @productInStock.
  ///
  /// In en, this message translates to:
  /// **'{stock} {unit} in stock'**
  String productInStock(int stock, String unit);

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescription;

  /// No description provided for @productYouMayAlsoLike.
  ///
  /// In en, this message translates to:
  /// **'You may also like'**
  String get productYouMayAlsoLike;

  /// No description provided for @productAddButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Add {label} · {price}'**
  String productAddButtonLabel(String label, String price);

  /// No description provided for @productOutOfStockButton.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get productOutOfStockButton;

  /// No description provided for @productAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'{name} added to cart'**
  String productAddedToCart(String name);

  /// No description provided for @productViewCartAction.
  ///
  /// In en, this message translates to:
  /// **'VIEW CART'**
  String get productViewCartAction;

  /// No description provided for @categoryProductsFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get categoryProductsFallbackTitle;

  /// No description provided for @categoryProductsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products in this category yet'**
  String get categoryProductsEmptyTitle;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @cartClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get cartClearAll;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add products to place a wholesale order.'**
  String get cartEmptyMessage;

  /// No description provided for @cartBrowseProducts.
  ///
  /// In en, this message translates to:
  /// **'Browse Products'**
  String get cartBrowseProducts;

  /// No description provided for @cartBelowMinimum.
  ///
  /// In en, this message translates to:
  /// **'Add {amount} more to reach the {minimum} minimum order.'**
  String cartBelowMinimum(String amount, String minimum);

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @cartDeliveryCharge.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charge (estimated)'**
  String get cartDeliveryCharge;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotal;

  /// No description provided for @cartProceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get cartProceedToCheckout;

  /// No description provided for @cartWeightAtRate.
  ///
  /// In en, this message translates to:
  /// **'{weight} @ ₹{rate}/kg'**
  String cartWeightAtRate(String weight, String rate);

  /// No description provided for @cartCouponHint.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get cartCouponHint;

  /// No description provided for @cartCouponApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get cartCouponApply;

  /// No description provided for @cartCouponRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get cartCouponRemove;

  /// No description provided for @cartCouponApplied.
  ///
  /// In en, this message translates to:
  /// **'\"{code}\" applied'**
  String cartCouponApplied(String code);

  /// No description provided for @cartDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get cartDiscount;

  /// No description provided for @checkoutLocationError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location. Check location permission and try again.'**
  String get checkoutLocationError;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get checkoutDeliveryAddress;

  /// No description provided for @checkoutPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get checkoutPaymentMethod;

  /// No description provided for @checkoutCod.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery (COD)'**
  String get checkoutCod;

  /// No description provided for @checkoutUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get checkoutUpi;

  /// No description provided for @checkoutOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get checkoutOrderSummary;

  /// No description provided for @checkoutSubtotalItems.
  ///
  /// In en, this message translates to:
  /// **'Subtotal ({count} items)'**
  String checkoutSubtotalItems(int count);

  /// No description provided for @checkoutDeliveryCharge.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charge'**
  String get checkoutDeliveryCharge;

  /// No description provided for @checkoutDeliveryChargeEstimated.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charge (estimated)'**
  String get checkoutDeliveryChargeEstimated;

  /// No description provided for @checkoutEtaToday.
  ///
  /// In en, this message translates to:
  /// **'Arrives today'**
  String get checkoutEtaToday;

  /// No description provided for @checkoutEtaTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Arrives by tomorrow'**
  String get checkoutEtaTomorrow;

  /// No description provided for @checkoutEtaFewDays.
  ///
  /// In en, this message translates to:
  /// **'Arrives in 2–3 days'**
  String get checkoutEtaFewDays;

  /// No description provided for @checkoutEtaUnknown.
  ///
  /// In en, this message translates to:
  /// **'Arrives in 1–2 days'**
  String get checkoutEtaUnknown;

  /// No description provided for @checkoutGrandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get checkoutGrandTotal;

  /// No description provided for @checkoutPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get checkoutPlaceOrder;

  /// No description provided for @checkoutSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get checkoutSavedAddresses;

  /// No description provided for @checkoutSaveAddressToggle.
  ///
  /// In en, this message translates to:
  /// **'Save this address for later'**
  String get checkoutSaveAddressToggle;

  /// No description provided for @checkoutSaveAddressLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Label (e.g. Shop, Warehouse)'**
  String get checkoutSaveAddressLabelHint;

  /// No description provided for @checkoutSaveAddressLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a label to save this address'**
  String get checkoutSaveAddressLabelRequired;

  /// No description provided for @upiGalleryError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the gallery: {error}'**
  String upiGalleryError(String error);

  /// No description provided for @upiIdCopied.
  ///
  /// In en, this message translates to:
  /// **'UPI ID copied.'**
  String get upiIdCopied;

  /// No description provided for @upiConfirmError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t confirm payment: {error}'**
  String upiConfirmError(String error);

  /// No description provided for @upiPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'UPI Payment'**
  String get upiPaymentTitle;

  /// No description provided for @upiOrderLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load order: {error}'**
  String upiOrderLoadError(String error);

  /// No description provided for @upiOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'This order could not be found.'**
  String get upiOrderNotFound;

  /// No description provided for @upiPayAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String upiPayAmount(String amount);

  /// No description provided for @upiScanInstructions.
  ///
  /// In en, this message translates to:
  /// **'Scan with any UPI app, or use the ID below'**
  String get upiScanInstructions;

  /// No description provided for @upiScreenshotLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Screenshot (optional)'**
  String get upiScreenshotLabel;

  /// No description provided for @upiIHavePaid.
  ///
  /// In en, this message translates to:
  /// **'I Have Paid'**
  String get upiIHavePaid;

  /// No description provided for @upiConfirmationNote.
  ///
  /// In en, this message translates to:
  /// **'The admin will confirm your payment shortly after.'**
  String get upiConfirmationNote;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get orderSuccessTitle;

  /// No description provided for @orderSuccessOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{shortId}'**
  String orderSuccessOrderNumber(String shortId);

  /// No description provided for @orderSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'The admin has been notified and will confirm your order shortly.'**
  String get orderSuccessMessage;

  /// No description provided for @orderSuccessViewOrder.
  ///
  /// In en, this message translates to:
  /// **'View Order'**
  String get orderSuccessViewOrder;

  /// No description provided for @orderSuccessContinueShopping.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get orderSuccessContinueShopping;

  /// No description provided for @orderHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get orderHistoryTitle;

  /// No description provided for @orderHistoryFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get orderHistoryFilterAll;

  /// No description provided for @orderHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orderHistoryEmptyTitle;

  /// No description provided for @orderHistoryEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No {status} orders'**
  String orderHistoryEmptyFiltered(String status);

  /// No description provided for @orderHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your placed orders will show up here.'**
  String get orderHistoryEmptyMessage;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{shortId}'**
  String orderNumber(String shortId);

  /// No description provided for @orderItemsAndDate.
  ///
  /// In en, this message translates to:
  /// **'{count} items · {date}'**
  String orderItemsAndDate(int count, String date);

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetailsTitle;

  /// No description provided for @orderShareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get orderShareTooltip;

  /// No description provided for @orderCancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order?'**
  String get orderCancelDialogTitle;

  /// No description provided for @orderCancelDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get orderCancelDialogContent;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @orderCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled.'**
  String get orderCancelledMessage;

  /// No description provided for @orderCancelFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Cancellation failed. Please try again.'**
  String get orderCancelFailedMessage;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @buyAgainAddedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 item added to cart} other{{count} items added to cart}}'**
  String buyAgainAddedCount(num count);

  /// No description provided for @buyAgainUnavailableSuffix.
  ///
  /// In en, this message translates to:
  /// **' — {count} no longer available.'**
  String buyAgainUnavailableSuffix(int count);

  /// No description provided for @profileSettingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsTab;

  /// No description provided for @profileUpdatePhotoError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update photo: {error}'**
  String profileUpdatePhotoError(String error);

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String profileUpdateFailed(String error);

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save: {error}'**
  String profileSaveFailed(String error);

  /// No description provided for @profileChangePasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password?'**
  String get profileChangePasswordDialogTitle;

  /// No description provided for @profileResetLinkMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a password reset link to {email}.'**
  String profileResetLinkMessage(String email);

  /// No description provided for @profileSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get profileSendLink;

  /// No description provided for @profileResetLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send reset link: {error}'**
  String profileResetLinkFailed(String error);

  /// No description provided for @profileResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to {email}'**
  String profileResetLinkSent(String email);

  /// No description provided for @profileLogoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get profileLogoutDialogTitle;

  /// No description provided for @profileLogoutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to access your account.'**
  String get profileLogoutDialogContent;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogOut;

  /// No description provided for @profileSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved Addresses'**
  String get profileSavedAddresses;

  /// No description provided for @profileNoSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses you save at checkout will appear here.'**
  String get profileNoSavedAddresses;

  /// No description provided for @profileRemoveAddressAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get profileRemoveAddressAction;

  /// No description provided for @profileRemoveAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove address?'**
  String get profileRemoveAddressTitle;

  /// No description provided for @profileRemoveAddressContent.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{label}\" from your saved addresses?'**
  String profileRemoveAddressContent(String label);

  /// No description provided for @profileAddressRemoved.
  ///
  /// In en, this message translates to:
  /// **'Address removed'**
  String get profileAddressRemoved;

  /// No description provided for @profileBusinessDetails.
  ///
  /// In en, this message translates to:
  /// **'Business Details'**
  String get profileBusinessDetails;

  /// No description provided for @profileGstNumber.
  ///
  /// In en, this message translates to:
  /// **'GST Number (optional)'**
  String get profileGstNumber;

  /// No description provided for @profileOpen24x7.
  ///
  /// In en, this message translates to:
  /// **'Open 24×7'**
  String get profileOpen24x7;

  /// No description provided for @profileOpensAt.
  ///
  /// In en, this message translates to:
  /// **'Opens: {time}'**
  String profileOpensAt(String time);

  /// No description provided for @profileClosesAt.
  ///
  /// In en, this message translates to:
  /// **'Closes: {time}'**
  String profileClosesAt(String time);

  /// No description provided for @profilePayoutDetails.
  ///
  /// In en, this message translates to:
  /// **'Payout Details'**
  String get profilePayoutDetails;

  /// No description provided for @profileAccountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get profileAccountHolderName;

  /// No description provided for @profileAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get profileAccountNumber;

  /// No description provided for @profileIfscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get profileIfscCode;

  /// No description provided for @profileBankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get profileBankName;

  /// No description provided for @profileUpiIdOptional.
  ///
  /// In en, this message translates to:
  /// **'UPI ID (optional)'**
  String get profileUpiIdOptional;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSaveChanges;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileOrderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order Updates'**
  String get profileOrderUpdates;

  /// No description provided for @profileOrderUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Status changes for your orders'**
  String get profileOrderUpdatesSubtitle;

  /// No description provided for @profilePromotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get profilePromotions;

  /// No description provided for @profilePromotionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offers and discounts'**
  String get profilePromotionsSubtitle;

  /// No description provided for @profileLowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get profileLowStockAlerts;

  /// No description provided for @profileLowStockAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When items you buy often are running low'**
  String get profileLowStockAlertsSubtitle;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @profileAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccountSection;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupport;

  /// No description provided for @profileCallSupport.
  ///
  /// In en, this message translates to:
  /// **'Call Support'**
  String get profileCallSupport;

  /// No description provided for @profileEmailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get profileEmailSupport;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @languageMarathi.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get languageMarathi;

  /// No description provided for @adminProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Profile'**
  String get adminProfileTitle;

  /// No description provided for @profileAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get profileAccountInfo;

  /// No description provided for @profileRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRoleLabel;

  /// No description provided for @profileRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get profileRoleAdmin;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String profileMemberSince(String date);

  /// No description provided for @profileStoreSection.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get profileStoreSection;

  /// No description provided for @profileDeliverySettings.
  ///
  /// In en, this message translates to:
  /// **'Delivery Settings'**
  String get profileDeliverySettings;

  /// No description provided for @broadcastTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Broadcast'**
  String get broadcastTitle;

  /// No description provided for @broadcastTitleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get broadcastTitleFieldLabel;

  /// No description provided for @broadcastBodyFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get broadcastBodyFieldLabel;

  /// No description provided for @broadcastSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send to All Retailers'**
  String get broadcastSendButton;

  /// No description provided for @broadcastSentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Broadcast sent'**
  String get broadcastSentConfirmation;

  /// No description provided for @broadcastHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No broadcasts sent yet'**
  String get broadcastHistoryEmpty;

  /// No description provided for @profileDeliverySettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery radius, fees, and minimum order value'**
  String get profileDeliverySettingsSubtitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load notifications: {error}'**
  String notificationsLoadError(String error);

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Updates about your orders will show up here.'**
  String get notificationsEmptyMessage;

  /// No description provided for @productPerUnit.
  ///
  /// In en, this message translates to:
  /// **'per {unit}'**
  String productPerUnit(String unit);

  /// No description provided for @quantitySheetLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantitySheetLabel;

  /// No description provided for @quantitySheetInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock: {label}'**
  String quantitySheetInStock(String label);

  /// No description provided for @quantitySheetMinimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum {label}'**
  String quantitySheetMinimum(String label);

  /// No description provided for @quantitySheetRateAtBand.
  ///
  /// In en, this message translates to:
  /// **'₹{rate}/kg · {band}'**
  String quantitySheetRateAtBand(String rate, String band);

  /// No description provided for @quantitySheetPricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'{price} per {unit}'**
  String quantitySheetPricePerUnit(String price, String unit);

  /// No description provided for @quantitySheetEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity'**
  String get quantitySheetEnterQuantity;

  /// No description provided for @quantitySheetUpdateTo.
  ///
  /// In en, this message translates to:
  /// **'Update to {label}'**
  String quantitySheetUpdateTo(String label);

  /// No description provided for @quantitySheetAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add {label} to Cart'**
  String quantitySheetAddToCart(String label);

  /// No description provided for @quantityPickerSelectQuantity.
  ///
  /// In en, this message translates to:
  /// **'Select quantity'**
  String get quantityPickerSelectQuantity;

  /// No description provided for @quantityPickerCustomQuantity.
  ///
  /// In en, this message translates to:
  /// **'Custom quantity'**
  String get quantityPickerCustomQuantity;

  /// No description provided for @rateSlabTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate by quantity (₹ per kg)'**
  String get rateSlabTitle;

  /// No description provided for @rateSlabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The whole weight is billed at the one rate its band earns.'**
  String get rateSlabSubtitle;

  /// No description provided for @ratePerKg.
  ///
  /// In en, this message translates to:
  /// **'₹{rate}/kg'**
  String ratePerKg(String rate);

  /// No description provided for @addressStreetLabel.
  ///
  /// In en, this message translates to:
  /// **'Street / Shop Address'**
  String get addressStreetLabel;

  /// No description provided for @addressCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get addressCityLabel;

  /// No description provided for @addressPincodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get addressPincodeLabel;

  /// No description provided for @addressDetecting.
  ///
  /// In en, this message translates to:
  /// **'Detecting your location…'**
  String get addressDetecting;

  /// No description provided for @addressDetectedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Detected: '**
  String get addressDetectedPrefix;

  /// No description provided for @addressAddForPricing.
  ///
  /// In en, this message translates to:
  /// **'Add your location for accurate delivery pricing'**
  String get addressAddForPricing;

  /// No description provided for @addressRefreshLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh location'**
  String get addressRefreshLocation;

  /// No description provided for @addressUseCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get addressUseCurrentLocation;

  /// No description provided for @orderStatusHeading.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatusHeading;

  /// No description provided for @orderItemsHeading.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get orderItemsHeading;

  /// No description provided for @orderWeighedLine.
  ///
  /// In en, this message translates to:
  /// **'{name} · {weight} @ ₹{rate}/kg'**
  String orderWeighedLine(String name, String weight, String rate);

  /// No description provided for @orderUnitLine.
  ///
  /// In en, this message translates to:
  /// **'{name} × {qty}'**
  String orderUnitLine(String name, int qty);

  /// No description provided for @orderDeliveryAddressHeading.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY ADDRESS'**
  String get orderDeliveryAddressHeading;

  /// No description provided for @orderAddressLine.
  ///
  /// In en, this message translates to:
  /// **'{street}, {city} - {pincode}'**
  String orderAddressLine(String street, String city, String pincode);

  /// No description provided for @orderPaymentHeading.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT'**
  String get orderPaymentHeading;

  /// No description provided for @orderPaymentCod.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get orderPaymentCod;

  /// No description provided for @orderPaymentScreenshotLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Screenshot'**
  String get orderPaymentScreenshotLabel;

  /// No description provided for @cartItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 item} other{{count} items}}'**
  String cartItemCount(num count);

  /// No description provided for @cartViewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get cartViewCart;

  /// No description provided for @cartAddMoreShort.
  ///
  /// In en, this message translates to:
  /// **'Add {amount} more to order'**
  String cartAddMoreShort(String amount);

  /// No description provided for @firstRunHintBuyAgain.
  ///
  /// In en, this message translates to:
  /// **'Tap any item here to quickly reorder it'**
  String get firstRunHintBuyAgain;

  /// No description provided for @cartRemoveItemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get cartRemoveItemTooltip;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @adminClearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get adminClearSearchTooltip;

  /// No description provided for @adminRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get adminRefreshTooltip;

  /// No description provided for @promoMinOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Purchase Order Enforced'**
  String get promoMinOrderTitle;

  /// No description provided for @promoMinOrderBody.
  ///
  /// In en, this message translates to:
  /// **'Minimum order value: {amount} at checkout.'**
  String promoMinOrderBody(String amount);

  /// No description provided for @promoDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Own Fleet Delivery'**
  String get promoDeliveryTitle;

  /// No description provided for @promoDeliveryBody.
  ///
  /// In en, this message translates to:
  /// **'Delivered by our own delivery staff — no third-party logistics.'**
  String get promoDeliveryBody;

  /// No description provided for @promoHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get promoHelpTitle;

  /// No description provided for @promoHelpBody.
  ///
  /// In en, this message translates to:
  /// **'Call {phone} for support with your order.'**
  String promoHelpBody(String phone);

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTooltip;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @adminCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminCancel;

  /// No description provided for @adminDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminDelete;

  /// No description provided for @adminEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminEdit;

  /// No description provided for @adminActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminActive;

  /// No description provided for @adminSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get adminSaveChanges;

  /// No description provided for @adminApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get adminApply;

  /// No description provided for @adminPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get adminPreview;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Jyoti Traders Admin'**
  String get adminDashboardTitle;

  /// No description provided for @adminPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get adminPendingApprovals;

  /// No description provided for @adminTotalRetailers.
  ///
  /// In en, this message translates to:
  /// **'Total Retailers'**
  String get adminTotalRetailers;

  /// No description provided for @adminTodaysOrders.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Orders'**
  String get adminTodaysOrders;

  /// No description provided for @adminTodaysRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Revenue'**
  String get adminTodaysRevenue;

  /// No description provided for @adminTopProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get adminTopProducts;

  /// No description provided for @adminCouldntLoadTopProducts.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load top products: {error}'**
  String adminCouldntLoadTopProducts(String error);

  /// No description provided for @adminNoSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales yet'**
  String get adminNoSalesYet;

  /// No description provided for @adminSendBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Send Broadcast'**
  String get adminSendBroadcast;

  /// No description provided for @adminRetailerApprovalQueue.
  ///
  /// In en, this message translates to:
  /// **'Retailer Approval Queue'**
  String get adminRetailerApprovalQueue;

  /// No description provided for @adminViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get adminViewAll;

  /// No description provided for @adminCouldntLoadApprovalQueue.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load approval queue: {error}'**
  String adminCouldntLoadApprovalQueue(String error);

  /// No description provided for @adminMoreWaiting.
  ///
  /// In en, this message translates to:
  /// **'+{count} more waiting — tap \"View All\"'**
  String adminMoreWaiting(int count);

  /// No description provided for @adminCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get adminCatalogTitle;

  /// No description provided for @adminProductsTab.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminProductsTab;

  /// No description provided for @adminCategoriesTab.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get adminCategoriesTab;

  /// No description provided for @adminBulkImportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Bulk Import'**
  String get adminBulkImportTooltip;

  /// No description provided for @adminManageProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Products'**
  String get adminManageProductsTitle;

  /// No description provided for @adminAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get adminAddProduct;

  /// No description provided for @adminSearchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get adminSearchProducts;

  /// No description provided for @adminAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get adminAllCategories;

  /// No description provided for @adminSortNameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A–Z)'**
  String get adminSortNameAZ;

  /// No description provided for @adminSortStockLow.
  ///
  /// In en, this message translates to:
  /// **'Stock (low first)'**
  String get adminSortStockLow;

  /// No description provided for @adminSortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price (low first)'**
  String get adminSortPriceLow;

  /// No description provided for @adminSortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price (high first)'**
  String get adminSortPriceHigh;

  /// No description provided for @adminSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get adminSelect;

  /// No description provided for @adminCouldntLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load products: {error}'**
  String adminCouldntLoadProducts(String error);

  /// No description provided for @adminNoProductsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get adminNoProductsYetTitle;

  /// No description provided for @adminNoProductsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Product\" to create your first catalog item.'**
  String get adminNoProductsYetMessage;

  /// No description provided for @adminNoProductsMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No products match'**
  String get adminNoProductsMatchTitle;

  /// No description provided for @adminNoProductsMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term or filter.'**
  String get adminNoProductsMatchMessage;

  /// No description provided for @adminLowStockBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 product is low on stock (≤ {threshold}).} other{{count} products are low on stock (≤ {threshold}).}}'**
  String adminLowStockBanner(int count, int threshold);

  /// No description provided for @adminDeleteProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete product?'**
  String get adminDeleteProductTitle;

  /// No description provided for @adminDeleteProductContent.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be permanently removed from the catalog. To hide it from retailers without losing it, edit the product and turn off \"Active\" instead.'**
  String adminDeleteProductContent(String name);

  /// No description provided for @adminProductDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted.'**
  String adminProductDeletedMessage(String name);

  /// No description provided for @adminDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String adminDeleteFailed(String error);

  /// No description provided for @adminBulkEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk edit {count} products'**
  String adminBulkEditTitle(int count);

  /// No description provided for @adminBulkEditHint.
  ///
  /// In en, this message translates to:
  /// **'Leave a field blank to leave that value unchanged.'**
  String get adminBulkEditHint;

  /// No description provided for @adminSetStockTo.
  ///
  /// In en, this message translates to:
  /// **'Set stock to'**
  String get adminSetStockTo;

  /// No description provided for @adminEnterWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get adminEnterWholeNumber;

  /// No description provided for @adminAdjustPriceByPercent.
  ///
  /// In en, this message translates to:
  /// **'Adjust price by %'**
  String get adminAdjustPriceByPercent;

  /// No description provided for @adminAdjustPriceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10 for +10%, -5 for -5%'**
  String get adminAdjustPriceHint;

  /// No description provided for @adminEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get adminEnterNumber;

  /// No description provided for @adminSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String adminSelectedCount(int count);

  /// No description provided for @adminBulkEdit.
  ///
  /// In en, this message translates to:
  /// **'Bulk Edit'**
  String get adminBulkEdit;

  /// No description provided for @adminBulkEditResult.
  ///
  /// In en, this message translates to:
  /// **'{success} of {total} products updated.'**
  String adminBulkEditResult(int success, int total);

  /// No description provided for @adminEditProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get adminEditProduct;

  /// No description provided for @adminProductName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get adminProductName;

  /// No description provided for @adminProductNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Basmati Rice Premium 25kg'**
  String get adminProductNameHint;

  /// No description provided for @adminProductNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get adminProductNameRequired;

  /// No description provided for @adminCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get adminCategory;

  /// No description provided for @adminCouldntLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load categories: {error}'**
  String adminCouldntLoadCategories(String error);

  /// No description provided for @adminCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category is required'**
  String get adminCategoryRequired;

  /// No description provided for @adminPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (₹)'**
  String get adminPriceLabel;

  /// No description provided for @adminEnterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price'**
  String get adminEnterValidPrice;

  /// No description provided for @adminPriceMustBeAbove0.
  ///
  /// In en, this message translates to:
  /// **'Price must be above ₹0'**
  String get adminPriceMustBeAbove0;

  /// No description provided for @adminUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get adminUnit;

  /// No description provided for @adminPerUnit.
  ///
  /// In en, this message translates to:
  /// **'per {unit}'**
  String adminPerUnit(String unit);

  /// No description provided for @adminRateByQuantity.
  ///
  /// In en, this message translates to:
  /// **'Rate by quantity (₹ per kg)'**
  String get adminRateByQuantity;

  /// No description provided for @adminRateByQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'The whole weight is billed at the one rate its band earns.'**
  String get adminRateByQuantityHint;

  /// No description provided for @adminBandBelow240g.
  ///
  /// In en, this message translates to:
  /// **'Below 240g'**
  String get adminBandBelow240g;

  /// No description provided for @adminBand240to999g.
  ///
  /// In en, this message translates to:
  /// **'240g – 999g'**
  String get adminBand240to999g;

  /// No description provided for @adminBand1to2400g.
  ///
  /// In en, this message translates to:
  /// **'1kg – 2.4kg'**
  String get adminBand1to2400g;

  /// No description provided for @adminBandAbove2400g.
  ///
  /// In en, this message translates to:
  /// **'Above 2.4kg'**
  String get adminBandAbove2400g;

  /// No description provided for @adminEnterRateFor.
  ///
  /// In en, this message translates to:
  /// **'Enter a rate for {label}'**
  String adminEnterRateFor(String label);

  /// No description provided for @adminRateMustBeAbove0.
  ///
  /// In en, this message translates to:
  /// **'Rate must be above ₹0'**
  String get adminRateMustBeAbove0;

  /// No description provided for @adminStockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock quantity'**
  String get adminStockQuantity;

  /// No description provided for @adminInKilograms.
  ///
  /// In en, this message translates to:
  /// **'In kilograms'**
  String get adminInKilograms;

  /// No description provided for @adminInUnits.
  ///
  /// In en, this message translates to:
  /// **'In {unit}'**
  String adminInUnits(String unit);

  /// No description provided for @adminEnterValidStock.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid stock quantity'**
  String get adminEnterValidStock;

  /// No description provided for @adminStockCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Stock cannot be negative'**
  String get adminStockCannotBeNegative;

  /// No description provided for @adminDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get adminDescriptionOptional;

  /// No description provided for @adminInactiveProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Inactive products stay in your catalog but are hidden from retailers.'**
  String get adminInactiveProductsHint;

  /// No description provided for @adminChooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Please choose a category.'**
  String get adminChooseCategory;

  /// No description provided for @adminCouldntOpenGallery.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the gallery: {error}'**
  String adminCouldntOpenGallery(String error);

  /// No description provided for @adminUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} updated.'**
  String adminUpdatedMessage(String name);

  /// No description provided for @adminAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} added.'**
  String adminAddedMessage(String name);

  /// No description provided for @adminSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String adminSaveFailed(String error);

  /// No description provided for @adminManageCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get adminManageCategoriesTitle;

  /// No description provided for @adminAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get adminAddCategory;

  /// No description provided for @adminDeleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get adminDeleteCategoryTitle;

  /// No description provided for @adminDeleteCategoryContent.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be permanently removed. Products already assigned to it will keep their category id but won\'t show up under any visible category. To hide it from retailers without losing it, edit the category and turn off \"Active\" instead.'**
  String adminDeleteCategoryContent(String name);

  /// No description provided for @adminCategoryDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted.'**
  String adminCategoryDeletedMessage(String name);

  /// No description provided for @adminNoCategoriesYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get adminNoCategoriesYetTitle;

  /// No description provided for @adminNoCategoriesYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Category\" to create your first one.'**
  String get adminNoCategoriesYetMessage;

  /// No description provided for @adminEditCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get adminEditCategory;

  /// No description provided for @adminCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get adminCategoryName;

  /// No description provided for @adminCategoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Edible Oils'**
  String get adminCategoryNameHint;

  /// No description provided for @adminCategoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name is required'**
  String get adminCategoryNameRequired;

  /// No description provided for @adminInactiveCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Inactive categories stay in your catalog but are hidden from retailers.'**
  String get adminInactiveCategoriesHint;

  /// No description provided for @adminAllOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get adminAllOrdersTitle;

  /// No description provided for @adminRetailerOrders.
  ///
  /// In en, this message translates to:
  /// **'Retailer Orders'**
  String get adminRetailerOrders;

  /// No description provided for @adminRetailerOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'{shopName} — Orders'**
  String adminRetailerOrdersTitle(String shopName);

  /// No description provided for @adminExportCsvTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get adminExportCsvTooltip;

  /// No description provided for @adminNoOrdersToExport.
  ///
  /// In en, this message translates to:
  /// **'No orders to export.'**
  String get adminNoOrdersToExport;

  /// No description provided for @adminAllFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminAllFilter;

  /// No description provided for @adminCouldntLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load orders: {error}'**
  String adminCouldntLoadOrders(String error);

  /// No description provided for @adminNoOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get adminNoOrdersYet;

  /// No description provided for @adminNoStatusOrders.
  ///
  /// In en, this message translates to:
  /// **'No {status} orders'**
  String adminNoStatusOrders(String status);

  /// No description provided for @adminManageOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Order'**
  String get adminManageOrderTitle;

  /// No description provided for @adminStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated to {status}.'**
  String adminStatusUpdated(String status);

  /// No description provided for @adminUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String adminUpdateFailed(String error);

  /// No description provided for @adminPaymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed.'**
  String get adminPaymentConfirmed;

  /// No description provided for @adminCouldntLoadOrder.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load order: {error}'**
  String adminCouldntLoadOrder(String error);

  /// No description provided for @adminOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'This order could not be found.'**
  String get adminOrderNotFound;

  /// No description provided for @adminOrderStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get adminOrderStatusLabel;

  /// No description provided for @adminMarkAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get adminMarkAsPaid;

  /// No description provided for @adminRetailersTitle.
  ///
  /// In en, this message translates to:
  /// **'Retailers'**
  String get adminRetailersTitle;

  /// No description provided for @adminApprovedTab.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get adminApprovedTab;

  /// No description provided for @adminPendingTab.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminPendingTab;

  /// No description provided for @adminPendingTabWithCount.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String adminPendingTabWithCount(int count);

  /// No description provided for @adminCouldntLoadRetailers.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load retailers: {error}'**
  String adminCouldntLoadRetailers(String error);

  /// No description provided for @adminNoApprovedRetailersTitle.
  ///
  /// In en, this message translates to:
  /// **'No approved retailers yet'**
  String get adminNoApprovedRetailersTitle;

  /// No description provided for @adminNoApprovedRetailersMessage.
  ///
  /// In en, this message translates to:
  /// **'Retailers you approve will show up here with their order history.'**
  String get adminNoApprovedRetailersMessage;

  /// No description provided for @adminOwnerSection.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get adminOwnerSection;

  /// No description provided for @adminFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get adminFullNameLabel;

  /// No description provided for @adminContactSection.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get adminContactSection;

  /// No description provided for @adminEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminEmailLabel;

  /// No description provided for @adminPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get adminPhoneLabel;

  /// No description provided for @adminAddressSection.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get adminAddressSection;

  /// No description provided for @adminStreetLabel.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get adminStreetLabel;

  /// No description provided for @adminCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get adminCityLabel;

  /// No description provided for @adminPincodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get adminPincodeLabel;

  /// No description provided for @adminLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get adminLocationLabel;

  /// No description provided for @adminAddressNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Address not provided yet'**
  String get adminAddressNotProvided;

  /// No description provided for @adminGstSection.
  ///
  /// In en, this message translates to:
  /// **'GST'**
  String get adminGstSection;

  /// No description provided for @adminGstNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'GST Number'**
  String get adminGstNumberLabel;

  /// No description provided for @adminBusinessHoursSection.
  ///
  /// In en, this message translates to:
  /// **'Business Hours'**
  String get adminBusinessHoursSection;

  /// No description provided for @adminOpenLabel.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get adminOpenLabel;

  /// No description provided for @adminOpen24x7.
  ///
  /// In en, this message translates to:
  /// **'Open 24×7'**
  String get adminOpen24x7;

  /// No description provided for @adminBankDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Bank Details'**
  String get adminBankDetailsSection;

  /// No description provided for @adminAccountHolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Account holder'**
  String get adminAccountHolderLabel;

  /// No description provided for @adminAccountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get adminAccountNumberLabel;

  /// No description provided for @adminIfscLabel.
  ///
  /// In en, this message translates to:
  /// **'IFSC'**
  String get adminIfscLabel;

  /// No description provided for @adminBankNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get adminBankNameLabel;

  /// No description provided for @adminUpiIdLabel.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get adminUpiIdLabel;

  /// No description provided for @adminRegisteredOnSection.
  ///
  /// In en, this message translates to:
  /// **'Registered On'**
  String get adminRegisteredOnSection;

  /// No description provided for @adminDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get adminDateLabel;

  /// No description provided for @adminDeliverySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Settings'**
  String get adminDeliverySettingsTitle;

  /// No description provided for @adminWarehouseLocation.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Location'**
  String get adminWarehouseLocation;

  /// No description provided for @adminWarehouseLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Every delivery charge is calculated as straight-line distance from this point.'**
  String get adminWarehouseLocationHint;

  /// No description provided for @adminLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get adminLatitude;

  /// No description provided for @adminLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get adminLongitude;

  /// No description provided for @adminEnterValidCoordinate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid coordinate'**
  String get adminEnterValidCoordinate;

  /// No description provided for @adminUseCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get adminUseCurrentLocation;

  /// No description provided for @adminDeliverySavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'✓ Delivery settings saved successfully'**
  String get adminDeliverySavedSuccess;

  /// No description provided for @adminPerKmRate.
  ///
  /// In en, this message translates to:
  /// **'Per-km Rate'**
  String get adminPerKmRate;

  /// No description provided for @adminRateLabelPerKm.
  ///
  /// In en, this message translates to:
  /// **'Rate (₹ per km)'**
  String get adminRateLabelPerKm;

  /// No description provided for @adminEnterValidRate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid rate'**
  String get adminEnterValidRate;

  /// No description provided for @adminCouldntLoadDeliverySettings.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load delivery settings: {error}'**
  String adminCouldntLoadDeliverySettings(String error);

  /// No description provided for @adminBulkImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk Import Products'**
  String get adminBulkImportTitle;

  /// No description provided for @adminBulkImportInstructions.
  ///
  /// In en, this message translates to:
  /// **'Paste rows copied from a spreadsheet. Header row required: name, category, price, unit, stock, description (description optional). Unit is one of: piece, box, litre, kg. For a kg product, add four more columns to price it by weight: below240g, upto999g, upto2400g, above2400g — leave them out for a flat per-unit price.'**
  String get adminBulkImportInstructions;

  /// No description provided for @adminCsvHint.
  ///
  /// In en, this message translates to:
  /// **'name,category,price,unit,stock,description\nBasmati Rice 25kg,Rice,1800,box,10,Premium'**
  String get adminCsvHint;

  /// No description provided for @adminCouldNotLoadCategoriesShort.
  ///
  /// In en, this message translates to:
  /// **'Could not load categories: {error}'**
  String adminCouldNotLoadCategoriesShort(String error);

  /// No description provided for @adminImportCount.
  ///
  /// In en, this message translates to:
  /// **'Import {count}'**
  String adminImportCount(int count);

  /// No description provided for @adminRowNumber.
  ///
  /// In en, this message translates to:
  /// **'Row {number}'**
  String adminRowNumber(int number);

  /// No description provided for @adminProductsCreated.
  ///
  /// In en, this message translates to:
  /// **'{count} product(s) created.'**
  String adminProductsCreated(int count);

  /// No description provided for @adminProductsCreatedWithFailures.
  ///
  /// In en, this message translates to:
  /// **'{created} product(s) created, {failed} failed.'**
  String adminProductsCreatedWithFailures(int created, int failed);

  /// No description provided for @adminOwnerNameValue.
  ///
  /// In en, this message translates to:
  /// **'Owner: {name}'**
  String adminOwnerNameValue(String name);

  /// No description provided for @adminPhoneValue.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String adminPhoneValue(String phone);

  /// No description provided for @adminApprovalQueueClear.
  ///
  /// In en, this message translates to:
  /// **'Approval queue is clear!'**
  String get adminApprovalQueueClear;

  /// No description provided for @adminAllRetailersVerified.
  ///
  /// In en, this message translates to:
  /// **'All registered retailers are verified.'**
  String get adminAllRetailersVerified;

  /// No description provided for @adminOrderCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 order} other{{count} orders}}'**
  String adminOrderCount(int count);

  /// No description provided for @adminInactiveBadge.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get adminInactiveBadge;

  /// No description provided for @adminEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminEditTooltip;

  /// No description provided for @adminDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminDeleteTooltip;

  /// No description provided for @adminPricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'{price} · per {unit}'**
  String adminPricePerUnit(String price, String unit);

  /// No description provided for @adminStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock: {count}'**
  String adminStockLabel(int count);

  /// No description provided for @adminActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed: {error}'**
  String adminActionFailed(String error);

  /// No description provided for @adminReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminReject;

  /// No description provided for @adminApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminApprove;

  /// No description provided for @adminRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} rejected.'**
  String adminRejectedMessage(String name);

  /// No description provided for @adminApprovedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} approved successfully!'**
  String adminApprovedMessage(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
