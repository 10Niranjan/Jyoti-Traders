// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navOrders => 'Orders';

  @override
  String get navProfile => 'Profile';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingSlide1Title => 'Browse the Full Catalog';

  @override
  String get onboardingSlide1Subtitle =>
      'Wholesale and retail categories, curated products, always up to date.';

  @override
  String get onboardingSlide2Title => 'Bulk Orders, Better Prices';

  @override
  String get onboardingSlide2Subtitle =>
      'Order from ₹2,500 and get it delivered straight to your shop.';

  @override
  String get onboardingSlide3Title => 'Pay Your Way';

  @override
  String get onboardingSlide3Subtitle =>
      'Cash on Delivery or UPI — track every order from placement to delivery.';

  @override
  String get authSubtitleLogin => 'Wholesale & Retail Market Hub';

  @override
  String get authSubtitleSignup => 'Create Your Retailer Account';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authFullNameHelper => 'Letters and spaces only';

  @override
  String get authPhoneNumber => 'Phone Number';

  @override
  String get authPhoneHelper => '10-digit mobile number';

  @override
  String get authBusinessName => 'Business / Shop Name';

  @override
  String get authBusinessNameHelper =>
      'Letters, numbers, spaces, & - . allowed';

  @override
  String get authEmailAddress => 'Email Address';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHelperSignup =>
      '8+ chars with upper, lower, number & symbol';

  @override
  String get authEnterPasswordError => 'Enter password';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authHasAccount => 'Already have an account? ';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authDemoLoginLabel => 'Simulation Demo Quick Login:';

  @override
  String get authAdminDemo => 'Admin Demo';

  @override
  String get authRetailerDemo => 'Retailer Demo';

  @override
  String get homeDefaultCustomerName => 'Valued Customer';

  @override
  String get homeDefaultBusinessName => 'Retailer';

  @override
  String homeOwnerLabel(String name) {
    return 'Owner: $name';
  }

  @override
  String get homeBrowseCategories => 'Browse Categories';

  @override
  String get homeNoCategoriesTitle => 'No categories yet';

  @override
  String get homeNoCategoriesMessage =>
      'Check back soon — the admin is setting up the catalog.';

  @override
  String homeLowStockBanner(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of your regulars are low or out of stock.',
      one: '1 of your regulars is low or out of stock.',
    );
    return '$_temp0';
  }

  @override
  String get homeBuyAgain => 'Buy Again';

  @override
  String get homeTodaysPicks => 'Today\'s Picks';

  @override
  String homeFromRatePerKg(String rate) {
    return 'from ₹$rate/kg';
  }

  @override
  String get homeOutOfStock => 'Out of stock';

  @override
  String homeOnlyLeftInStock(int stock, String unit) {
    return 'Only $stock $unit left';
  }

  @override
  String get pendingUnableToDialPhone => 'Unable to dial phone: 9860460325';

  @override
  String get pendingUnableToOpenEmail =>
      'Unable to open email client: vishvatejkatkar007@gmail.com';

  @override
  String get pendingTitle => 'Account Verification Pending';

  @override
  String get pendingMessage =>
      'Your retailer application is currently being reviewed by the owner of Jyoti Traders. Once approved, you will gain full access to wholesale product purchasing.';

  @override
  String get pendingCheckingStatus => 'Checking verification status...';

  @override
  String get pendingCheckStatusAgain => 'Check Status Again';

  @override
  String get pendingContactSupportTitle =>
      'Need Urgent Approval? Contact Support';

  @override
  String get pendingCallOwner => 'Call Owner: +91 98604 60325';

  @override
  String get pendingEmailSupport => 'Email: vishvatejkatkar007@gmail.com';

  @override
  String get pendingSignOut => 'Sign Out & Try Another Account';

  @override
  String get searchHint => 'Search products...';

  @override
  String get searchEmptyTitle => 'Search for products';

  @override
  String get searchEmptyMessage =>
      'Try a product name like \"rice\" or \"oil\".';

  @override
  String get searchRecentSearches => 'Recent Searches';

  @override
  String get searchClear => 'Clear';

  @override
  String searchNoResultsFor(String query) {
    return 'No products found for \"$query\"';
  }

  @override
  String get productDetailsTitle => 'Product Details';

  @override
  String get productNoLongerAvailable => 'This product is no longer available.';

  @override
  String productSoldPer(String unit) {
    return 'Sold per $unit';
  }

  @override
  String productInStock(int stock, String unit) {
    return '$stock $unit in stock';
  }

  @override
  String get productDescription => 'Description';

  @override
  String productAddButtonLabel(String label, String price) {
    return 'Add $label · $price';
  }

  @override
  String get productOutOfStockButton => 'Out of Stock';

  @override
  String productAddedToCart(String name) {
    return '$name added to cart';
  }

  @override
  String get productViewCartAction => 'VIEW CART';

  @override
  String get categoryProductsFallbackTitle => 'Products';

  @override
  String get categoryProductsEmptyTitle => 'No products in this category yet';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartClearAll => 'Clear all';

  @override
  String get cartEmptyTitle => 'Your cart is empty';

  @override
  String get cartEmptyMessage => 'Add products to place a wholesale order.';

  @override
  String get cartBrowseProducts => 'Browse Products';

  @override
  String cartBelowMinimum(String amount, String minimum) {
    return 'Add $amount more to reach the $minimum minimum order.';
  }

  @override
  String get cartSubtotal => 'Subtotal';

  @override
  String get cartDeliveryCharge => 'Delivery Charge (estimated)';

  @override
  String get cartTotal => 'Total';

  @override
  String get cartProceedToCheckout => 'Proceed to Checkout';

  @override
  String cartWeightAtRate(String weight, String rate) {
    return '$weight @ ₹$rate/kg';
  }

  @override
  String get checkoutLocationError =>
      'Couldn\'t get your location. Check location permission and try again.';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutDeliveryAddress => 'Delivery Address';

  @override
  String get checkoutPaymentMethod => 'Payment Method';

  @override
  String get checkoutCod => 'Cash on Delivery (COD)';

  @override
  String get checkoutUpi => 'UPI';

  @override
  String get checkoutOrderSummary => 'Order Summary';

  @override
  String checkoutSubtotalItems(int count) {
    return 'Subtotal ($count items)';
  }

  @override
  String get checkoutDeliveryCharge => 'Delivery Charge';

  @override
  String get checkoutDeliveryChargeEstimated => 'Delivery Charge (estimated)';

  @override
  String get checkoutGrandTotal => 'Grand Total';

  @override
  String get checkoutPlaceOrder => 'Place Order';

  @override
  String upiGalleryError(String error) {
    return 'Couldn\'t open the gallery: $error';
  }

  @override
  String get upiIdCopied => 'UPI ID copied.';

  @override
  String upiConfirmError(String error) {
    return 'Couldn\'t confirm payment: $error';
  }

  @override
  String get upiPaymentTitle => 'UPI Payment';

  @override
  String upiOrderLoadError(String error) {
    return 'Couldn\'t load order: $error';
  }

  @override
  String get upiOrderNotFound => 'This order could not be found.';

  @override
  String upiPayAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get upiScanInstructions =>
      'Scan with any UPI app, or use the ID below';

  @override
  String get upiScreenshotLabel => 'Payment Screenshot (optional)';

  @override
  String get upiIHavePaid => 'I Have Paid';

  @override
  String get upiConfirmationNote =>
      'The admin will confirm your payment shortly after.';

  @override
  String get orderSuccessTitle => 'Order Placed!';

  @override
  String orderSuccessOrderNumber(String shortId) {
    return 'Order #$shortId';
  }

  @override
  String get orderSuccessMessage =>
      'The admin has been notified and will confirm your order shortly.';

  @override
  String get orderSuccessViewOrder => 'View Order';

  @override
  String get orderSuccessContinueShopping => 'Continue Shopping';

  @override
  String get orderHistoryTitle => 'My Orders';

  @override
  String get orderHistoryFilterAll => 'All';

  @override
  String get orderHistoryEmptyTitle => 'No orders yet';

  @override
  String orderHistoryEmptyFiltered(String status) {
    return 'No $status orders';
  }

  @override
  String get orderHistoryEmptyMessage =>
      'Your placed orders will show up here.';

  @override
  String orderNumber(String shortId) {
    return 'Order #$shortId';
  }

  @override
  String orderItemsAndDate(int count, String date) {
    return '$count items · $date';
  }

  @override
  String get orderDetailsTitle => 'Order Details';

  @override
  String get orderShareTooltip => 'Share';

  @override
  String get orderCancelDialogTitle => 'Cancel this order?';

  @override
  String get orderCancelDialogContent => 'This cannot be undone.';

  @override
  String get no => 'No';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get orderCancelledMessage => 'Order cancelled.';

  @override
  String get orderCancelFailedMessage =>
      'Cancellation failed. Please try again.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String buyAgainAddedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items added to cart',
      one: '1 item added to cart',
    );
    return '$_temp0';
  }

  @override
  String buyAgainUnavailableSuffix(int count) {
    return ' — $count no longer available.';
  }

  @override
  String get profileSettingsTab => 'Settings';

  @override
  String profileUpdatePhotoError(String error) {
    return 'Couldn\'t update photo: $error';
  }

  @override
  String profileUpdateFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String profileSaveFailed(String error) {
    return 'Couldn\'t save: $error';
  }

  @override
  String get profileChangePasswordDialogTitle => 'Change Password?';

  @override
  String profileResetLinkMessage(String email) {
    return 'We\'ll send a password reset link to $email.';
  }

  @override
  String get profileSendLink => 'Send Link';

  @override
  String profileResetLinkFailed(String error) {
    return 'Couldn\'t send reset link: $error';
  }

  @override
  String profileResetLinkSent(String email) {
    return 'Password reset link sent to $email';
  }

  @override
  String get profileLogoutDialogTitle => 'Log out?';

  @override
  String get profileLogoutDialogContent =>
      'You\'ll need to sign in again to access your account.';

  @override
  String get profileLogOut => 'Log Out';

  @override
  String get profileBusinessDetails => 'Business Details';

  @override
  String get profileGstNumber => 'GST Number (optional)';

  @override
  String get profileOpen24x7 => 'Open 24×7';

  @override
  String profileOpensAt(String time) {
    return 'Opens: $time';
  }

  @override
  String profileClosesAt(String time) {
    return 'Closes: $time';
  }

  @override
  String get profilePayoutDetails => 'Payout Details';

  @override
  String get profileAccountHolderName => 'Account Holder Name';

  @override
  String get profileAccountNumber => 'Account Number';

  @override
  String get profileIfscCode => 'IFSC Code';

  @override
  String get profileBankName => 'Bank Name';

  @override
  String get profileUpiIdOptional => 'UPI ID (optional)';

  @override
  String get profileSaveChanges => 'Save Changes';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileOrderUpdates => 'Order Updates';

  @override
  String get profileOrderUpdatesSubtitle => 'Status changes for your orders';

  @override
  String get profilePromotions => 'Promotions';

  @override
  String get profilePromotionsSubtitle => 'Offers and discounts';

  @override
  String get profileLowStockAlerts => 'Low Stock Alerts';

  @override
  String get profileLowStockAlertsSubtitle =>
      'When items you buy often are running low';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get profileAccountSection => 'Account';

  @override
  String get profileChangePassword => 'Change Password';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileCallSupport => 'Call Support';

  @override
  String get profileEmailSupport => 'Email Support';

  @override
  String get profileLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String notificationsLoadError(String error) {
    return 'Couldn\'t load notifications: $error';
  }

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptyMessage =>
      'Updates about your orders will show up here.';

  @override
  String productPerUnit(String unit) {
    return 'per $unit';
  }

  @override
  String get quantitySheetLabel => 'Quantity';

  @override
  String quantitySheetInStock(String label) {
    return 'In stock: $label';
  }

  @override
  String quantitySheetMinimum(String label) {
    return 'Minimum $label';
  }

  @override
  String quantitySheetRateAtBand(String rate, String band) {
    return '₹$rate/kg · $band';
  }

  @override
  String quantitySheetPricePerUnit(String price, String unit) {
    return '$price per $unit';
  }

  @override
  String get quantitySheetEnterQuantity => 'Enter a quantity';

  @override
  String quantitySheetUpdateTo(String label) {
    return 'Update to $label';
  }

  @override
  String quantitySheetAddToCart(String label) {
    return 'Add $label to Cart';
  }

  @override
  String get quantityPickerSelectQuantity => 'Select quantity';

  @override
  String get quantityPickerCustomQuantity => 'Custom quantity';

  @override
  String get rateSlabTitle => 'Rate by quantity (₹ per kg)';

  @override
  String get rateSlabSubtitle =>
      'The whole weight is billed at the one rate its band earns.';

  @override
  String ratePerKg(String rate) {
    return '₹$rate/kg';
  }

  @override
  String get addressStreetLabel => 'Street / Shop Address';

  @override
  String get addressCityLabel => 'City';

  @override
  String get addressPincodeLabel => 'Pincode';

  @override
  String get addressDetecting => 'Detecting your location…';

  @override
  String get addressDetectedPrefix => 'Detected: ';

  @override
  String get addressAddForPricing =>
      'Add your location for accurate delivery pricing';

  @override
  String get addressRefreshLocation => 'Refresh location';

  @override
  String get addressUseCurrentLocation => 'Use current location';

  @override
  String get orderStatusHeading => 'Order Status';

  @override
  String get orderItemsHeading => 'Items';

  @override
  String orderWeighedLine(String name, String weight, String rate) {
    return '$name · $weight @ ₹$rate/kg';
  }

  @override
  String orderUnitLine(String name, int qty) {
    return '$name × $qty';
  }

  @override
  String get orderDeliveryAddressHeading => 'DELIVERY ADDRESS';

  @override
  String orderAddressLine(String street, String city, String pincode) {
    return '$street, $city - $pincode';
  }

  @override
  String get orderPaymentHeading => 'PAYMENT';

  @override
  String get orderPaymentCod => 'Cash on Delivery';

  @override
  String get orderPaymentScreenshotLabel => 'Payment Screenshot';

  @override
  String cartItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get cartViewCart => 'View Cart';

  @override
  String get promoMinOrderTitle => 'Wholesale Purchase Order Enforced';

  @override
  String promoMinOrderBody(String amount) {
    return 'Minimum order value: $amount at checkout.';
  }

  @override
  String get promoDeliveryTitle => 'Own Fleet Delivery';

  @override
  String get promoDeliveryBody =>
      'Delivered by our own delivery staff — no third-party logistics.';

  @override
  String get promoHelpTitle => 'Need Help?';

  @override
  String promoHelpBody(String phone) {
    return 'Call $phone for support with your order.';
  }

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get save => 'Save';

  @override
  String get editProfileTooltip => 'Edit profile';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Retry';
}
