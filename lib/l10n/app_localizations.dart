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
