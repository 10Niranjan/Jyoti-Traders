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
  String get pendingBrowseCatalog => 'Browse Catalog While You Wait';

  @override
  String get homePendingBanner =>
      'Preview mode — you can order once your account is approved.';

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
  String get searchSortRelevance => 'Relevance';

  @override
  String get searchSortPriceLowToHigh => 'Price: Low to High';

  @override
  String get searchSortPriceHighToLow => 'Price: High to Low';

  @override
  String get searchInStockOnly => 'In stock only';

  @override
  String get searchAllCategories => 'All';

  @override
  String get productDetailsTitle => 'Product Details';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistEmptyTitle => 'Nothing saved yet';

  @override
  String get wishlistEmptyMessage =>
      'Tap the heart on a product to save it for later.';

  @override
  String get wishlistAdded => 'Added to wishlist';

  @override
  String get wishlistRemoved => 'Removed from wishlist';

  @override
  String get wishlistAddTooltip => 'Add to wishlist';

  @override
  String get wishlistRemoveTooltip => 'Remove from wishlist';

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
  String get productYouMayAlsoLike => 'You may also like';

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
  String get cartCouponHint => 'Enter coupon code';

  @override
  String get cartCouponApply => 'Apply';

  @override
  String get cartCouponRemove => 'Remove';

  @override
  String cartCouponApplied(String code) {
    return '\"$code\" applied';
  }

  @override
  String get cartDiscount => 'Discount';

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
  String get checkoutEtaToday => 'Arrives today';

  @override
  String get checkoutEtaTomorrow => 'Arrives by tomorrow';

  @override
  String get checkoutEtaFewDays => 'Arrives in 2–3 days';

  @override
  String get checkoutEtaUnknown => 'Arrives in 1–2 days';

  @override
  String get checkoutGrandTotal => 'Grand Total';

  @override
  String get checkoutPlaceOrder => 'Place Order';

  @override
  String get checkoutSavedAddresses => 'Saved addresses';

  @override
  String get checkoutSaveAddressToggle => 'Save this address for later';

  @override
  String get checkoutSaveAddressLabelHint => 'Label (e.g. Shop, Warehouse)';

  @override
  String get checkoutSaveAddressLabelRequired =>
      'Add a label to save this address';

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
  String get profileSavedAddresses => 'Saved Addresses';

  @override
  String get profileNoSavedAddresses =>
      'Addresses you save at checkout will appear here.';

  @override
  String get profileRemoveAddressAction => 'Remove';

  @override
  String get profileRemoveAddressTitle => 'Remove address?';

  @override
  String profileRemoveAddressContent(String label) {
    return 'Remove \"$label\" from your saved addresses?';
  }

  @override
  String get profileAddressRemoved => 'Address removed';

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
  String get adminProfileTitle => 'Admin Profile';

  @override
  String get profileAccountInfo => 'Account Info';

  @override
  String get profileRoleLabel => 'Role';

  @override
  String get profileRoleAdmin => 'Administrator';

  @override
  String profileMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get profileStoreSection => 'Store';

  @override
  String get profileDeliverySettings => 'Delivery Settings';

  @override
  String get broadcastTitle => 'Send Broadcast';

  @override
  String get broadcastTitleFieldLabel => 'Title';

  @override
  String get broadcastBodyFieldLabel => 'Message';

  @override
  String get broadcastSendButton => 'Send to All Retailers';

  @override
  String get broadcastSentConfirmation => 'Broadcast sent';

  @override
  String get broadcastHistoryEmpty => 'No broadcasts sent yet';

  @override
  String get profileDeliverySettingsSubtitle =>
      'Delivery radius, fees, and minimum order value';

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
  String cartAddMoreShort(String amount) {
    return 'Add $amount more to order';
  }

  @override
  String get firstRunHintBuyAgain => 'Tap any item here to quickly reorder it';

  @override
  String get cartRemoveItemTooltip => 'Remove item';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get adminClearSearchTooltip => 'Clear search';

  @override
  String get adminRefreshTooltip => 'Refresh';

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

  @override
  String get adminCancel => 'Cancel';

  @override
  String get adminDelete => 'Delete';

  @override
  String get adminEdit => 'Edit';

  @override
  String get adminActive => 'Active';

  @override
  String get adminSaveChanges => 'Save Changes';

  @override
  String get adminApply => 'Apply';

  @override
  String get adminPreview => 'Preview';

  @override
  String get adminDashboardTitle => 'Jyoti Traders Admin';

  @override
  String get adminPendingApprovals => 'Pending Approvals';

  @override
  String get adminTotalRetailers => 'Total Retailers';

  @override
  String get adminTodaysOrders => 'Today\'s Orders';

  @override
  String get adminTodaysRevenue => 'Today\'s Revenue';

  @override
  String get adminTopProducts => 'Top Products';

  @override
  String adminCouldntLoadTopProducts(String error) {
    return 'Couldn\'t load top products: $error';
  }

  @override
  String get adminNoSalesYet => 'No sales yet';

  @override
  String get adminSendBroadcast => 'Send Broadcast';

  @override
  String get adminRetailerApprovalQueue => 'Retailer Approval Queue';

  @override
  String get adminViewAll => 'View All';

  @override
  String adminCouldntLoadApprovalQueue(String error) {
    return 'Couldn\'t load approval queue: $error';
  }

  @override
  String adminMoreWaiting(int count) {
    return '+$count more waiting — tap \"View All\"';
  }

  @override
  String get adminCatalogTitle => 'Catalog';

  @override
  String get adminProductsTab => 'Products';

  @override
  String get adminCategoriesTab => 'Categories';

  @override
  String get adminBulkImportTooltip => 'Bulk Import';

  @override
  String get adminManageProductsTitle => 'Manage Products';

  @override
  String get adminAddProduct => 'Add Product';

  @override
  String get adminSearchProducts => 'Search products';

  @override
  String get adminAllCategories => 'All Categories';

  @override
  String get adminSortNameAZ => 'Name (A–Z)';

  @override
  String get adminSortStockLow => 'Stock (low first)';

  @override
  String get adminSortPriceLow => 'Price (low first)';

  @override
  String get adminSortPriceHigh => 'Price (high first)';

  @override
  String get adminSelect => 'Select';

  @override
  String adminCouldntLoadProducts(String error) {
    return 'Couldn\'t load products: $error';
  }

  @override
  String get adminNoProductsYetTitle => 'No products yet';

  @override
  String get adminNoProductsYetMessage =>
      'Tap \"Add Product\" to create your first catalog item.';

  @override
  String get adminNoProductsMatchTitle => 'No products match';

  @override
  String get adminNoProductsMatchMessage =>
      'Try a different search term or filter.';

  @override
  String adminLowStockBanner(int count, int threshold) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products are low on stock (≤ $threshold).',
      one: '1 product is low on stock (≤ $threshold).',
    );
    return '$_temp0';
  }

  @override
  String get adminDeleteProductTitle => 'Delete product?';

  @override
  String adminDeleteProductContent(String name) {
    return '\"$name\" will be permanently removed from the catalog. To hide it from retailers without losing it, edit the product and turn off \"Active\" instead.';
  }

  @override
  String adminProductDeletedMessage(String name) {
    return '$name deleted.';
  }

  @override
  String adminDeleteFailed(String error) {
    return 'Delete failed: $error';
  }

  @override
  String adminBulkEditTitle(int count) {
    return 'Bulk edit $count products';
  }

  @override
  String get adminBulkEditHint =>
      'Leave a field blank to leave that value unchanged.';

  @override
  String get adminSetStockTo => 'Set stock to';

  @override
  String get adminEnterWholeNumber => 'Enter a whole number';

  @override
  String get adminAdjustPriceByPercent => 'Adjust price by %';

  @override
  String get adminAdjustPriceHint => 'e.g. 10 for +10%, -5 for -5%';

  @override
  String get adminEnterNumber => 'Enter a number';

  @override
  String adminSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get adminBulkEdit => 'Bulk Edit';

  @override
  String adminBulkEditResult(int success, int total) {
    return '$success of $total products updated.';
  }

  @override
  String get adminEditProduct => 'Edit Product';

  @override
  String get adminProductName => 'Product name';

  @override
  String get adminProductNameHint => 'e.g. Basmati Rice Premium 25kg';

  @override
  String get adminProductNameRequired => 'Product name is required';

  @override
  String get adminCategory => 'Category';

  @override
  String adminCouldntLoadCategories(String error) {
    return 'Couldn\'t load categories: $error';
  }

  @override
  String get adminCategoryRequired => 'Category is required';

  @override
  String get adminPriceLabel => 'Price (₹)';

  @override
  String get adminEnterValidPrice => 'Enter a valid price';

  @override
  String get adminPriceMustBeAbove0 => 'Price must be above ₹0';

  @override
  String get adminUnit => 'Unit';

  @override
  String adminPerUnit(String unit) {
    return 'per $unit';
  }

  @override
  String get adminRateByQuantity => 'Rate by quantity (₹ per kg)';

  @override
  String get adminRateByQuantityHint =>
      'The whole weight is billed at the one rate its band earns.';

  @override
  String get adminBandBelow240g => 'Below 240g';

  @override
  String get adminBand240to999g => '240g – 999g';

  @override
  String get adminBand1to2400g => '1kg – 2.4kg';

  @override
  String get adminBandAbove2400g => 'Above 2.4kg';

  @override
  String adminEnterRateFor(String label) {
    return 'Enter a rate for $label';
  }

  @override
  String get adminRateMustBeAbove0 => 'Rate must be above ₹0';

  @override
  String get adminStockQuantity => 'Stock quantity';

  @override
  String get adminInKilograms => 'In kilograms';

  @override
  String adminInUnits(String unit) {
    return 'In $unit';
  }

  @override
  String get adminEnterValidStock => 'Enter a valid stock quantity';

  @override
  String get adminStockCannotBeNegative => 'Stock cannot be negative';

  @override
  String get adminDescriptionOptional => 'Description (optional)';

  @override
  String get adminInactiveProductsHint =>
      'Inactive products stay in your catalog but are hidden from retailers.';

  @override
  String get adminChooseCategory => 'Please choose a category.';

  @override
  String adminCouldntOpenGallery(String error) {
    return 'Couldn\'t open the gallery: $error';
  }

  @override
  String adminUpdatedMessage(String name) {
    return '$name updated.';
  }

  @override
  String adminAddedMessage(String name) {
    return '$name added.';
  }

  @override
  String adminSaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get adminManageCategoriesTitle => 'Manage Categories';

  @override
  String get adminAddCategory => 'Add Category';

  @override
  String get adminDeleteCategoryTitle => 'Delete category?';

  @override
  String adminDeleteCategoryContent(String name) {
    return '\"$name\" will be permanently removed. Products already assigned to it will keep their category id but won\'t show up under any visible category. To hide it from retailers without losing it, edit the category and turn off \"Active\" instead.';
  }

  @override
  String adminCategoryDeletedMessage(String name) {
    return '$name deleted.';
  }

  @override
  String get adminNoCategoriesYetTitle => 'No categories yet';

  @override
  String get adminNoCategoriesYetMessage =>
      'Tap \"Add Category\" to create your first one.';

  @override
  String get adminEditCategory => 'Edit Category';

  @override
  String get adminCategoryName => 'Category name';

  @override
  String get adminCategoryNameHint => 'e.g. Edible Oils';

  @override
  String get adminCategoryNameRequired => 'Category name is required';

  @override
  String get adminInactiveCategoriesHint =>
      'Inactive categories stay in your catalog but are hidden from retailers.';

  @override
  String get adminAllOrdersTitle => 'All Orders';

  @override
  String get adminRetailerOrders => 'Retailer Orders';

  @override
  String adminRetailerOrdersTitle(String shopName) {
    return '$shopName — Orders';
  }

  @override
  String get adminExportCsvTooltip => 'Export as CSV';

  @override
  String get adminNoOrdersToExport => 'No orders to export.';

  @override
  String get adminAllFilter => 'All';

  @override
  String adminCouldntLoadOrders(String error) {
    return 'Couldn\'t load orders: $error';
  }

  @override
  String get adminNoOrdersYet => 'No orders yet';

  @override
  String adminNoStatusOrders(String status) {
    return 'No $status orders';
  }

  @override
  String get adminManageOrderTitle => 'Manage Order';

  @override
  String adminStatusUpdated(String status) {
    return 'Status updated to $status.';
  }

  @override
  String adminUpdateFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String get adminPaymentConfirmed => 'Payment confirmed.';

  @override
  String adminCouldntLoadOrder(String error) {
    return 'Couldn\'t load order: $error';
  }

  @override
  String get adminOrderNotFound => 'This order could not be found.';

  @override
  String get adminOrderStatusLabel => 'Order status';

  @override
  String get adminMarkAsPaid => 'Mark as Paid';

  @override
  String get adminRetailersTitle => 'Retailers';

  @override
  String get adminApprovedTab => 'Approved';

  @override
  String get adminPendingTab => 'Pending';

  @override
  String adminPendingTabWithCount(int count) {
    return 'Pending ($count)';
  }

  @override
  String adminCouldntLoadRetailers(String error) {
    return 'Couldn\'t load retailers: $error';
  }

  @override
  String get adminNoApprovedRetailersTitle => 'No approved retailers yet';

  @override
  String get adminNoApprovedRetailersMessage =>
      'Retailers you approve will show up here with their order history.';

  @override
  String get adminOwnerSection => 'Owner';

  @override
  String get adminFullNameLabel => 'Full name';

  @override
  String get adminContactSection => 'Contact';

  @override
  String get adminEmailLabel => 'Email';

  @override
  String get adminPhoneLabel => 'Phone';

  @override
  String get adminAddressSection => 'Address';

  @override
  String get adminStreetLabel => 'Street';

  @override
  String get adminCityLabel => 'City';

  @override
  String get adminPincodeLabel => 'Pincode';

  @override
  String get adminLocationLabel => 'Location';

  @override
  String get adminAddressNotProvided => 'Address not provided yet';

  @override
  String get adminGstSection => 'GST';

  @override
  String get adminGstNumberLabel => 'GST Number';

  @override
  String get adminBusinessHoursSection => 'Business Hours';

  @override
  String get adminOpenLabel => 'Open';

  @override
  String get adminOpen24x7 => 'Open 24×7';

  @override
  String get adminBankDetailsSection => 'Bank Details';

  @override
  String get adminAccountHolderLabel => 'Account holder';

  @override
  String get adminAccountNumberLabel => 'Account number';

  @override
  String get adminIfscLabel => 'IFSC';

  @override
  String get adminBankNameLabel => 'Bank';

  @override
  String get adminUpiIdLabel => 'UPI ID';

  @override
  String get adminRegisteredOnSection => 'Registered On';

  @override
  String get adminDateLabel => 'Date';

  @override
  String get adminDeliverySettingsTitle => 'Delivery Settings';

  @override
  String get adminWarehouseLocation => 'Warehouse Location';

  @override
  String get adminWarehouseLocationHint =>
      'Every delivery charge is calculated as straight-line distance from this point.';

  @override
  String get adminLatitude => 'Latitude';

  @override
  String get adminLongitude => 'Longitude';

  @override
  String get adminEnterValidCoordinate => 'Enter a valid coordinate';

  @override
  String get adminUseCurrentLocation => 'Use current location';

  @override
  String get adminDeliverySavedSuccess =>
      '✓ Delivery settings saved successfully';

  @override
  String get adminPerKmRate => 'Per-km Rate';

  @override
  String get adminRateLabelPerKm => 'Rate (₹ per km)';

  @override
  String get adminEnterValidRate => 'Enter a valid rate';

  @override
  String adminCouldntLoadDeliverySettings(String error) {
    return 'Couldn\'t load delivery settings: $error';
  }

  @override
  String get adminBulkImportTitle => 'Bulk Import Products';

  @override
  String get adminBulkImportInstructions =>
      'Paste rows copied from a spreadsheet. Header row required: name, category, price, unit, stock, description (description optional). Unit is one of: piece, box, litre, kg. For a kg product, add four more columns to price it by weight: below240g, upto999g, upto2400g, above2400g — leave them out for a flat per-unit price.';

  @override
  String get adminCsvHint =>
      'name,category,price,unit,stock,description\nBasmati Rice 25kg,Rice,1800,box,10,Premium';

  @override
  String adminCouldNotLoadCategoriesShort(String error) {
    return 'Could not load categories: $error';
  }

  @override
  String adminImportCount(int count) {
    return 'Import $count';
  }

  @override
  String adminRowNumber(int number) {
    return 'Row $number';
  }

  @override
  String adminProductsCreated(int count) {
    return '$count product(s) created.';
  }

  @override
  String adminProductsCreatedWithFailures(int created, int failed) {
    return '$created product(s) created, $failed failed.';
  }

  @override
  String adminOwnerNameValue(String name) {
    return 'Owner: $name';
  }

  @override
  String adminPhoneValue(String phone) {
    return 'Phone: $phone';
  }

  @override
  String get adminApprovalQueueClear => 'Approval queue is clear!';

  @override
  String get adminAllRetailersVerified =>
      'All registered retailers are verified.';

  @override
  String adminOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
    );
    return '$_temp0';
  }

  @override
  String get adminInactiveBadge => 'Inactive';

  @override
  String get adminEditTooltip => 'Edit';

  @override
  String get adminDeleteTooltip => 'Delete';

  @override
  String adminPricePerUnit(String price, String unit) {
    return '$price · per $unit';
  }

  @override
  String adminStockLabel(int count) {
    return 'Stock: $count';
  }

  @override
  String adminActionFailed(String error) {
    return 'Action failed: $error';
  }

  @override
  String get adminReject => 'Reject';

  @override
  String get adminApprove => 'Approve';

  @override
  String adminRejectedMessage(String name) {
    return '$name rejected.';
  }

  @override
  String adminApprovedMessage(String name) {
    return '$name approved successfully!';
  }
}
