// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get navHome => 'होम';

  @override
  String get navSearch => 'खोजें';

  @override
  String get navOrders => 'ऑर्डर';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get onboardingSkip => 'छोड़ें';

  @override
  String get onboardingNext => 'आगे';

  @override
  String get onboardingGetStarted => 'शुरू करें';

  @override
  String get onboardingSlide1Title => 'पूरा कैटलॉग देखें';

  @override
  String get onboardingSlide1Subtitle =>
      'थोक और खुदरा श्रेणियाँ, चुने हुए उत्पाद, हमेशा अपडेटेड।';

  @override
  String get onboardingSlide2Title => 'थोक ऑर्डर, बेहतर कीमतें';

  @override
  String get onboardingSlide2Subtitle =>
      '₹2,500 से ऑर्डर करें और सीधे अपनी दुकान पर डिलीवरी पाएं।';

  @override
  String get onboardingSlide3Title => 'अपने तरीके से भुगतान करें';

  @override
  String get onboardingSlide3Subtitle =>
      'कैश ऑन डिलीवरी या यूपीआई — ऑर्डर से डिलीवरी तक हर स्टेप ट्रैक करें।';

  @override
  String get authSubtitleLogin => 'थोक और खुदरा बाज़ार हब';

  @override
  String get authSubtitleSignup => 'अपना रिटेलर खाता बनाएं';

  @override
  String get authFullName => 'पूरा नाम';

  @override
  String get authFullNameHelper => 'केवल अक्षर और स्पेस';

  @override
  String get authPhoneNumber => 'फ़ोन नंबर';

  @override
  String get authPhoneHelper => '10 अंकों का मोबाइल नंबर';

  @override
  String get authBusinessName => 'व्यवसाय / दुकान का नाम';

  @override
  String get authBusinessNameHelper => 'अक्षर, अंक, स्पेस, & - . मान्य हैं';

  @override
  String get authEmailAddress => 'ईमेल पता';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authPasswordHelperSignup =>
      '8+ अक्षर, जिसमें बड़े-छोटे अक्षर, अंक और चिह्न हों';

  @override
  String get authEnterPasswordError => 'पासवर्ड डालें';

  @override
  String get authSignIn => 'साइन इन करें';

  @override
  String get authCreateAccount => 'खाता बनाएं';

  @override
  String get authNoAccount => 'खाता नहीं है? ';

  @override
  String get authHasAccount => 'पहले से खाता है? ';

  @override
  String get authSignUp => 'साइन अप करें';

  @override
  String get authDemoLoginLabel => 'सिमुलेशन डेमो क्विक लॉगिन:';

  @override
  String get authAdminDemo => 'एडमिन डेमो';

  @override
  String get authRetailerDemo => 'रिटेलर डेमो';

  @override
  String get homeDefaultCustomerName => 'मूल्यवान ग्राहक';

  @override
  String get homeDefaultBusinessName => 'रिटेलर';

  @override
  String homeOwnerLabel(String name) {
    return 'मालिक: $name';
  }

  @override
  String get homeBrowseCategories => 'श्रेणियाँ देखें';

  @override
  String get homeNoCategoriesTitle => 'अभी कोई श्रेणी नहीं';

  @override
  String get homeNoCategoriesMessage =>
      'जल्द ही दोबारा देखें — एडमिन कैटलॉग तैयार कर रहा है।';

  @override
  String homeLowStockBanner(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आपकी $count पसंदीदा वस्तुएं कम या खत्म हो गई हैं।',
      one: 'आपकी 1 पसंदीदा वस्तु कम या खत्म हो गई है।',
    );
    return '$_temp0';
  }

  @override
  String get homeBuyAgain => 'फिर से खरीदें';

  @override
  String get homeTodaysPicks => 'आज की पसंद';

  @override
  String homeFromRatePerKg(String rate) {
    return '₹$rate/किलो से';
  }

  @override
  String get homeOutOfStock => 'स्टॉक खत्म';

  @override
  String homeOnlyLeftInStock(int stock, String unit) {
    return 'केवल $stock $unit बचे हैं';
  }

  @override
  String get pendingUnableToDialPhone => 'फ़ोन डायल नहीं हो सका: 9860460325';

  @override
  String get pendingUnableToOpenEmail =>
      'ईमेल क्लाइंट नहीं खुल सका: vishvatejkatkar007@gmail.com';

  @override
  String get pendingTitle => 'खाता सत्यापन लंबित है';

  @override
  String get pendingMessage =>
      'आपका रिटेलर आवेदन फ़िलहाल Jyoti Traders के मालिक द्वारा जांचा जा रहा है। स्वीकृति मिलते ही आपको थोक उत्पाद खरीदने की पूरी सुविधा मिल जाएगी।';

  @override
  String get pendingCheckingStatus => 'सत्यापन स्थिति जांची जा रही है...';

  @override
  String get pendingCheckStatusAgain => 'फिर से स्थिति जांचें';

  @override
  String get pendingContactSupportTitle =>
      'तुरंत स्वीकृति चाहिए? सहायता से संपर्क करें';

  @override
  String get pendingCallOwner => 'मालिक को कॉल करें: +91 98604 60325';

  @override
  String get pendingEmailSupport => 'ईमेल: vishvatejkatkar007@gmail.com';

  @override
  String get pendingSignOut => 'साइन आउट करें और दूसरा खाता आज़माएं';

  @override
  String get pendingBrowseCatalog => 'प्रतीक्षा करते समय कैटलॉग देखें';

  @override
  String get homePendingBanner =>
      'प्रीव्यू मोड — स्वीकृति मिलने के बाद आप ऑर्डर कर सकेंगे।';

  @override
  String get searchHint => 'उत्पाद खोजें...';

  @override
  String get searchEmptyTitle => 'उत्पाद खोजें';

  @override
  String get searchEmptyMessage =>
      '\"चावल\" या \"तेल\" जैसा उत्पाद नाम आज़माएं।';

  @override
  String get searchRecentSearches => 'हाल की खोजें';

  @override
  String get searchClear => 'साफ़ करें';

  @override
  String searchNoResultsFor(String query) {
    return '\"$query\" के लिए कोई उत्पाद नहीं मिला';
  }

  @override
  String get searchSortRelevance => 'प्रासंगिकता';

  @override
  String get searchSortPriceLowToHigh => 'कीमत: कम से ज्यादा';

  @override
  String get searchSortPriceHighToLow => 'कीमत: ज्यादा से कम';

  @override
  String get searchInStockOnly => 'केवल स्टॉक में';

  @override
  String get searchAllCategories => 'सभी';

  @override
  String get productDetailsTitle => 'उत्पाद विवरण';

  @override
  String get wishlistTitle => 'पसंदीदा सूची';

  @override
  String get wishlistEmptyTitle => 'अभी तक कुछ भी सहेजा नहीं गया';

  @override
  String get wishlistEmptyMessage =>
      'किसी उत्पाद को बाद के लिए सहेजने के लिए हार्ट पर टैप करें।';

  @override
  String get wishlistAdded => 'पसंदीदा सूची में जोड़ा गया';

  @override
  String get wishlistRemoved => 'पसंदीदा सूची से हटाया गया';

  @override
  String get wishlistAddTooltip => 'पसंदीदा सूची में जोड़ें';

  @override
  String get wishlistRemoveTooltip => 'पसंदीदा सूची से हटाएं';

  @override
  String get productNoLongerAvailable => 'यह उत्पाद अब उपलब्ध नहीं है।';

  @override
  String productSoldPer(String unit) {
    return '$unit के हिसाब से बिकता है';
  }

  @override
  String productInStock(int stock, String unit) {
    return '$stock $unit स्टॉक में';
  }

  @override
  String get productDescription => 'विवरण';

  @override
  String get productYouMayAlsoLike => 'आपको यह भी पसंद आ सकता है';

  @override
  String productAddButtonLabel(String label, String price) {
    return '$label जोड़ें · $price';
  }

  @override
  String get productOutOfStockButton => 'स्टॉक खत्म';

  @override
  String productAddedToCart(String name) {
    return '$name कार्ट में जोड़ा गया';
  }

  @override
  String get productViewCartAction => 'कार्ट देखें';

  @override
  String get categoryProductsFallbackTitle => 'उत्पाद';

  @override
  String get categoryProductsEmptyTitle => 'इस श्रेणी में अभी कोई उत्पाद नहीं';

  @override
  String get cartTitle => 'कार्ट';

  @override
  String get cartClearAll => 'सभी हटाएं';

  @override
  String get cartEmptyTitle => 'आपकी कार्ट खाली है';

  @override
  String get cartEmptyMessage => 'थोक ऑर्डर देने के लिए उत्पाद जोड़ें।';

  @override
  String get cartBrowseProducts => 'उत्पाद देखें';

  @override
  String cartBelowMinimum(String amount, String minimum) {
    return 'न्यूनतम ऑर्डर $minimum तक पहुँचने के लिए $amount और जोड़ें।';
  }

  @override
  String get cartSubtotal => 'सबटोटल';

  @override
  String get cartDeliveryCharge => 'डिलीवरी शुल्क (अनुमानित)';

  @override
  String get cartTotal => 'कुल';

  @override
  String get cartProceedToCheckout => 'चेकआउट पर जाएं';

  @override
  String cartWeightAtRate(String weight, String rate) {
    return '$weight @ ₹$rate/किलो';
  }

  @override
  String get cartCouponHint => 'कूपन कोड डालें';

  @override
  String get cartCouponApply => 'लागू करें';

  @override
  String get cartCouponRemove => 'हटाएं';

  @override
  String cartCouponApplied(String code) {
    return '\"$code\" लागू किया गया';
  }

  @override
  String get cartDiscount => 'छूट';

  @override
  String get checkoutLocationError =>
      'आपकी लोकेशन नहीं मिल सकी। लोकेशन अनुमति जांचें और फिर से प्रयास करें।';

  @override
  String get checkoutTitle => 'चेकआउट';

  @override
  String get checkoutDeliveryAddress => 'डिलीवरी पता';

  @override
  String get checkoutPaymentMethod => 'भुगतान का तरीका';

  @override
  String get checkoutCod => 'कैश ऑन डिलीवरी (COD)';

  @override
  String get checkoutUpi => 'यूपीआई';

  @override
  String get checkoutOrderSummary => 'ऑर्डर सारांश';

  @override
  String checkoutSubtotalItems(int count) {
    return 'सबटोटल ($count वस्तुएं)';
  }

  @override
  String get checkoutDeliveryCharge => 'डिलीवरी शुल्क';

  @override
  String get checkoutDeliveryChargeEstimated => 'डिलीवरी शुल्क (अनुमानित)';

  @override
  String get checkoutEtaToday => 'आज पहुंचेगा';

  @override
  String get checkoutEtaTomorrow => 'कल तक पहुंचेगा';

  @override
  String get checkoutEtaFewDays => '2–3 दिनों में पहुंचेगा';

  @override
  String get checkoutEtaUnknown => '1–2 दिनों में पहुंचेगा';

  @override
  String get checkoutGrandTotal => 'कुल योग';

  @override
  String get checkoutPlaceOrder => 'ऑर्डर करें';

  @override
  String get checkoutSavedAddresses => 'सहेजे गए पते';

  @override
  String get checkoutSaveAddressToggle => 'यह पता बाद के लिए सहेजें';

  @override
  String get checkoutSaveAddressLabelHint => 'लेबल (जैसे दुकान, गोदाम)';

  @override
  String get checkoutSaveAddressLabelRequired =>
      'इस पते को सहेजने के लिए एक लेबल जोड़ें';

  @override
  String upiGalleryError(String error) {
    return 'गैलरी नहीं खुल सकी: $error';
  }

  @override
  String get upiIdCopied => 'UPI आईडी कॉपी हो गई।';

  @override
  String upiConfirmError(String error) {
    return 'भुगतान की पुष्टि नहीं हो सकी: $error';
  }

  @override
  String get upiPaymentTitle => 'यूपीआई भुगतान';

  @override
  String upiOrderLoadError(String error) {
    return 'ऑर्डर लोड नहीं हो सका: $error';
  }

  @override
  String get upiOrderNotFound => 'यह ऑर्डर नहीं मिला।';

  @override
  String upiPayAmount(String amount) {
    return '$amount भुगतान करें';
  }

  @override
  String get upiScanInstructions =>
      'किसी भी UPI ऐप से स्कैन करें, या नीचे दी गई आईडी का उपयोग करें';

  @override
  String get upiScreenshotLabel => 'भुगतान स्क्रीनशॉट (वैकल्पिक)';

  @override
  String get upiIHavePaid => 'मैंने भुगतान कर दिया है';

  @override
  String get upiConfirmationNote =>
      'एडमिन जल्द ही आपके भुगतान की पुष्टि करेगा।';

  @override
  String get orderSuccessTitle => 'ऑर्डर हो गया!';

  @override
  String orderSuccessOrderNumber(String shortId) {
    return 'ऑर्डर #$shortId';
  }

  @override
  String get orderSuccessMessage =>
      'एडमिन को सूचित कर दिया गया है और वे जल्द ही आपके ऑर्डर की पुष्टि करेंगे।';

  @override
  String get orderSuccessViewOrder => 'ऑर्डर देखें';

  @override
  String get orderSuccessContinueShopping => 'खरीदारी जारी रखें';

  @override
  String get orderHistoryTitle => 'मेरे ऑर्डर';

  @override
  String get orderHistoryFilterAll => 'सभी';

  @override
  String get orderHistoryEmptyTitle => 'अभी कोई ऑर्डर नहीं';

  @override
  String orderHistoryEmptyFiltered(String status) {
    return 'कोई $status ऑर्डर नहीं';
  }

  @override
  String get orderHistoryEmptyMessage => 'आपके किए गए ऑर्डर यहां दिखाई देंगे।';

  @override
  String orderNumber(String shortId) {
    return 'ऑर्डर #$shortId';
  }

  @override
  String orderItemsAndDate(int count, String date) {
    return '$count वस्तुएं · $date';
  }

  @override
  String get orderDetailsTitle => 'ऑर्डर विवरण';

  @override
  String get orderShareTooltip => 'शेयर करें';

  @override
  String get orderCancelDialogTitle => 'इस ऑर्डर को रद्द करें?';

  @override
  String get orderCancelDialogContent => 'यह पूर्ववत नहीं किया जा सकता।';

  @override
  String get no => 'नहीं';

  @override
  String get yesCancel => 'हां, रद्द करें';

  @override
  String get orderCancelledMessage => 'ऑर्डर रद्द कर दिया गया।';

  @override
  String get orderCancelFailedMessage =>
      'रद्द करना विफल रहा। कृपया फिर से प्रयास करें।';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String buyAgainAddedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तुएं कार्ट में जोड़ी गईं',
      one: '1 वस्तु कार्ट में जोड़ी गई',
    );
    return '$_temp0';
  }

  @override
  String buyAgainUnavailableSuffix(int count) {
    return ' — $count अब उपलब्ध नहीं है।';
  }

  @override
  String get profileSettingsTab => 'सेटिंग्स';

  @override
  String profileUpdatePhotoError(String error) {
    return 'फोटो अपडेट नहीं हो सका: $error';
  }

  @override
  String profileUpdateFailed(String error) {
    return 'अपडेट विफल: $error';
  }

  @override
  String get profileUpdated => 'प्रोफ़ाइल अपडेट हो गई';

  @override
  String profileSaveFailed(String error) {
    return 'सेव नहीं हो सका: $error';
  }

  @override
  String get profileChangePasswordDialogTitle => 'पासवर्ड बदलें?';

  @override
  String profileResetLinkMessage(String email) {
    return 'हम $email पर पासवर्ड रीसेट लिंक भेजेंगे।';
  }

  @override
  String get profileSendLink => 'लिंक भेजें';

  @override
  String profileResetLinkFailed(String error) {
    return 'रीसेट लिंक नहीं भेजा जा सका: $error';
  }

  @override
  String profileResetLinkSent(String email) {
    return 'पासवर्ड रीसेट लिंक $email पर भेजा गया';
  }

  @override
  String get profileLogoutDialogTitle => 'लॉग आउट करें?';

  @override
  String get profileLogoutDialogContent =>
      'अपने खाते तक पहुंचने के लिए आपको फिर से साइन इन करना होगा।';

  @override
  String get profileLogOut => 'लॉग आउट';

  @override
  String get profileSavedAddresses => 'सहेजे गए पते';

  @override
  String get profileNoSavedAddresses =>
      'चेकआउट पर आपके द्वारा सहेजे गए पते यहाँ दिखेंगे।';

  @override
  String get profileRemoveAddressAction => 'हटाएं';

  @override
  String get profileRemoveAddressTitle => 'पता हटाएं?';

  @override
  String profileRemoveAddressContent(String label) {
    return '\"$label\" को अपने सहेजे गए पतों से हटाएं?';
  }

  @override
  String get profileAddressRemoved => 'पता हटा दिया गया';

  @override
  String get profileBusinessDetails => 'व्यवसाय विवरण';

  @override
  String get profileGstNumber => 'GST नंबर (वैकल्पिक)';

  @override
  String get profileOpen24x7 => '24×7 खुला';

  @override
  String profileOpensAt(String time) {
    return 'खुलता है: $time';
  }

  @override
  String profileClosesAt(String time) {
    return 'बंद होता है: $time';
  }

  @override
  String get profilePayoutDetails => 'भुगतान विवरण';

  @override
  String get profileAccountHolderName => 'खाताधारक का नाम';

  @override
  String get profileAccountNumber => 'खाता संख्या';

  @override
  String get profileIfscCode => 'IFSC कोड';

  @override
  String get profileBankName => 'बैंक का नाम';

  @override
  String get profileUpiIdOptional => 'UPI आईडी (वैकल्पिक)';

  @override
  String get profileSaveChanges => 'बदलाव सहेजें';

  @override
  String get profileNotifications => 'सूचनाएं';

  @override
  String get profileOrderUpdates => 'ऑर्डर अपडेट';

  @override
  String get profileOrderUpdatesSubtitle => 'आपके ऑर्डर की स्थिति में बदलाव';

  @override
  String get profilePromotions => 'प्रचार';

  @override
  String get profilePromotionsSubtitle => 'ऑफ़र और छूट';

  @override
  String get profileLowStockAlerts => 'कम स्टॉक अलर्ट';

  @override
  String get profileLowStockAlertsSubtitle =>
      'जब आपके अक्सर खरीदे जाने वाले उत्पाद कम हो जाएं';

  @override
  String get profileAppearance => 'दिखावट';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get profileAccountSection => 'खाता';

  @override
  String get profileChangePassword => 'पासवर्ड बदलें';

  @override
  String get profileSupport => 'सहायता';

  @override
  String get profileCallSupport => 'सहायता को कॉल करें';

  @override
  String get profileEmailSupport => 'सहायता को ईमेल करें';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get adminProfileTitle => 'एडमिन प्रोफ़ाइल';

  @override
  String get profileAccountInfo => 'खाता जानकारी';

  @override
  String get profileRoleLabel => 'भूमिका';

  @override
  String get profileRoleAdmin => 'प्रशासक';

  @override
  String profileMemberSince(String date) {
    return 'सदस्य बने: $date';
  }

  @override
  String get profileStoreSection => 'स्टोर';

  @override
  String get profileDeliverySettings => 'डिलीवरी सेटिंग्स';

  @override
  String get broadcastTitle => 'प्रसारण भेजें';

  @override
  String get broadcastTitleFieldLabel => 'शीर्षक';

  @override
  String get broadcastBodyFieldLabel => 'संदेश';

  @override
  String get broadcastSendButton => 'सभी रिटेलर्स को भेजें';

  @override
  String get broadcastSentConfirmation => 'प्रसारण भेजा गया';

  @override
  String get broadcastHistoryEmpty => 'अभी तक कोई प्रसारण नहीं भेजा गया';

  @override
  String get profileDeliverySettingsSubtitle =>
      'डिलीवरी दायरा, शुल्क और न्यूनतम ऑर्डर राशि';

  @override
  String get notificationsTitle => 'सूचनाएं';

  @override
  String get notificationsMarkAllRead => 'सभी को पढ़ा हुआ चिह्नित करें';

  @override
  String notificationsLoadError(String error) {
    return 'सूचनाएं लोड नहीं हो सकीं: $error';
  }

  @override
  String get notificationsEmptyTitle => 'अभी कोई सूचना नहीं';

  @override
  String get notificationsEmptyMessage =>
      'आपके ऑर्डर के बारे में अपडेट यहां दिखाई देंगे।';

  @override
  String productPerUnit(String unit) {
    return 'प्रति $unit';
  }

  @override
  String get quantitySheetLabel => 'मात्रा';

  @override
  String quantitySheetInStock(String label) {
    return 'स्टॉक में: $label';
  }

  @override
  String quantitySheetMinimum(String label) {
    return 'न्यूनतम $label';
  }

  @override
  String quantitySheetRateAtBand(String rate, String band) {
    return '₹$rate/किलो · $band';
  }

  @override
  String quantitySheetPricePerUnit(String price, String unit) {
    return '$price प्रति $unit';
  }

  @override
  String get quantitySheetEnterQuantity => 'मात्रा दर्ज करें';

  @override
  String quantitySheetUpdateTo(String label) {
    return '$label में बदलें';
  }

  @override
  String quantitySheetAddToCart(String label) {
    return 'कार्ट में $label जोड़ें';
  }

  @override
  String get quantityPickerSelectQuantity => 'मात्रा चुनें';

  @override
  String get quantityPickerCustomQuantity => 'कस्टम मात्रा';

  @override
  String get rateSlabTitle => 'मात्रा अनुसार दर (₹ प्रति किलो)';

  @override
  String get rateSlabSubtitle =>
      'पूरा वजन उसके बैंड की एक ही दर पर बिल किया जाता है।';

  @override
  String ratePerKg(String rate) {
    return '₹$rate/किलो';
  }

  @override
  String get addressStreetLabel => 'गली / दुकान का पता';

  @override
  String get addressCityLabel => 'शहर';

  @override
  String get addressPincodeLabel => 'पिनकोड';

  @override
  String get addressDetecting => 'आपकी लोकेशन पता की जा रही है…';

  @override
  String get addressDetectedPrefix => 'पता चला: ';

  @override
  String get addressAddForPricing =>
      'सटीक डिलीवरी कीमत के लिए अपनी लोकेशन जोड़ें';

  @override
  String get addressRefreshLocation => 'लोकेशन रीफ़्रेश करें';

  @override
  String get addressUseCurrentLocation => 'वर्तमान लोकेशन का उपयोग करें';

  @override
  String get orderStatusHeading => 'ऑर्डर स्थिति';

  @override
  String get orderItemsHeading => 'वस्तुएं';

  @override
  String orderWeighedLine(String name, String weight, String rate) {
    return '$name · $weight @ ₹$rate/किलो';
  }

  @override
  String orderUnitLine(String name, int qty) {
    return '$name × $qty';
  }

  @override
  String get orderDeliveryAddressHeading => 'डिलीवरी पता';

  @override
  String orderAddressLine(String street, String city, String pincode) {
    return '$street, $city - $pincode';
  }

  @override
  String get orderPaymentHeading => 'भुगतान';

  @override
  String get orderPaymentCod => 'कैश ऑन डिलीवरी';

  @override
  String get orderPaymentScreenshotLabel => 'भुगतान स्क्रीनशॉट';

  @override
  String cartItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तुएं',
      one: '1 वस्तु',
    );
    return '$_temp0';
  }

  @override
  String get cartViewCart => 'कार्ट देखें';

  @override
  String cartAddMoreShort(String amount) {
    return 'ऑर्डर के लिए $amount और जोड़ें';
  }

  @override
  String get firstRunHintBuyAgain =>
      'जल्दी दोबारा ऑर्डर करने के लिए यहां किसी भी आइटम पर टैप करें';

  @override
  String get cartRemoveItemTooltip => 'आइटम हटाएं';

  @override
  String get authShowPassword => 'पासवर्ड दिखाएं';

  @override
  String get authHidePassword => 'पासवर्ड छिपाएं';

  @override
  String get adminClearSearchTooltip => 'खोज साफ़ करें';

  @override
  String get adminRefreshTooltip => 'रीफ़्रेश करें';

  @override
  String get promoMinOrderTitle => 'थोक खरीद ऑर्डर अनिवार्य';

  @override
  String promoMinOrderBody(String amount) {
    return 'न्यूनतम ऑर्डर मूल्य: चेकआउट पर $amount।';
  }

  @override
  String get promoDeliveryTitle => 'अपनी खुद की डिलीवरी टीम';

  @override
  String get promoDeliveryBody =>
      'हमारे अपने डिलीवरी स्टाफ द्वारा डिलीवर किया जाता है — कोई थर्ड-पार्टी लॉजिस्टिक्स नहीं।';

  @override
  String get promoHelpTitle => 'मदद चाहिए?';

  @override
  String promoHelpBody(String phone) {
    return 'अपने ऑर्डर की सहायता के लिए $phone पर कॉल करें।';
  }

  @override
  String get editProfileTitle => 'प्रोफ़ाइल संपादित करें';

  @override
  String get save => 'सहेजें';

  @override
  String get editProfileTooltip => 'प्रोफ़ाइल संपादित करें';

  @override
  String get errorGeneric => 'कुछ गड़बड़ हो गई। कृपया फिर से प्रयास करें।';

  @override
  String get retry => 'फिर से प्रयास करें';

  @override
  String get adminCancel => 'रद्द करें';

  @override
  String get adminDelete => 'हटाएं';

  @override
  String get adminEdit => 'संपादित करें';

  @override
  String get adminActive => 'सक्रिय';

  @override
  String get adminSaveChanges => 'बदलाव सहेजें';

  @override
  String get adminApply => 'लागू करें';

  @override
  String get adminPreview => 'पूर्वावलोकन';

  @override
  String get adminDashboardTitle => 'ज्योति ट्रेडर्स एडमिन';

  @override
  String get adminPendingApprovals => 'लंबित स्वीकृतियां';

  @override
  String get adminTotalRetailers => 'कुल रिटेलर्स';

  @override
  String get adminTodaysOrders => 'आज के ऑर्डर';

  @override
  String get adminTodaysRevenue => 'आज की आय';

  @override
  String get adminTopProducts => 'टॉप प्रोडक्ट्स';

  @override
  String adminCouldntLoadTopProducts(String error) {
    return 'टॉप प्रोडक्ट्स लोड नहीं हो सके: $error';
  }

  @override
  String get adminNoSalesYet => 'अभी तक कोई बिक्री नहीं';

  @override
  String get adminSendBroadcast => 'ब्रॉडकास्ट भेजें';

  @override
  String get adminRetailerApprovalQueue => 'रिटेलर स्वीकृति सूची';

  @override
  String get adminViewAll => 'सभी देखें';

  @override
  String adminCouldntLoadApprovalQueue(String error) {
    return 'स्वीकृति सूची लोड नहीं हो सकी: $error';
  }

  @override
  String adminMoreWaiting(int count) {
    return '+$count और प्रतीक्षा में — \"सभी देखें\" पर टैप करें';
  }

  @override
  String get adminCatalogTitle => 'कैटलॉग';

  @override
  String get adminProductsTab => 'प्रोडक्ट्स';

  @override
  String get adminCategoriesTab => 'श्रेणियां';

  @override
  String get adminBulkImportTooltip => 'बल्क इम्पोर्ट';

  @override
  String get adminManageProductsTitle => 'प्रोडक्ट्स प्रबंधित करें';

  @override
  String get adminAddProduct => 'प्रोडक्ट जोड़ें';

  @override
  String get adminSearchProducts => 'प्रोडक्ट्स खोजें';

  @override
  String get adminAllCategories => 'सभी श्रेणियां';

  @override
  String get adminSortNameAZ => 'नाम (A–Z)';

  @override
  String get adminSortStockLow => 'स्टॉक (कम पहले)';

  @override
  String get adminSortPriceLow => 'कीमत (कम पहले)';

  @override
  String get adminSortPriceHigh => 'कीमत (ज्यादा पहले)';

  @override
  String get adminSelect => 'चुनें';

  @override
  String adminCouldntLoadProducts(String error) {
    return 'प्रोडक्ट्स लोड नहीं हो सके: $error';
  }

  @override
  String get adminNoProductsYetTitle => 'अभी तक कोई प्रोडक्ट नहीं';

  @override
  String get adminNoProductsYetMessage =>
      'अपना पहला कैटलॉग आइटम बनाने के लिए \"प्रोडक्ट जोड़ें\" पर टैप करें।';

  @override
  String get adminNoProductsMatchTitle => 'कोई प्रोडक्ट मेल नहीं खाता';

  @override
  String get adminNoProductsMatchMessage =>
      'एक अलग खोज शब्द या फ़िल्टर आज़माएं।';

  @override
  String adminLowStockBanner(int count, int threshold) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रोडक्ट्स का स्टॉक कम है (≤ $threshold).',
      one: '1 प्रोडक्ट का स्टॉक कम है (≤ $threshold).',
    );
    return '$_temp0';
  }

  @override
  String get adminDeleteProductTitle => 'प्रोडक्ट हटाएं?';

  @override
  String adminDeleteProductContent(String name) {
    return '\"$name\" को कैटलॉग से हमेशा के लिए हटा दिया जाएगा। इसे रिटेलर्स से बिना खोए छिपाने के लिए, प्रोडक्ट संपादित करें और \"सक्रिय\" बंद करें।';
  }

  @override
  String adminProductDeletedMessage(String name) {
    return '$name हटा दिया गया।';
  }

  @override
  String adminDeleteFailed(String error) {
    return 'हटाना विफल: $error';
  }

  @override
  String adminBulkEditTitle(int count) {
    return '$count प्रोडक्ट्स बल्क एडिट करें';
  }

  @override
  String get adminBulkEditHint =>
      'वैल्यू अपरिवर्तित रखने के लिए फ़ील्ड खाली छोड़ें।';

  @override
  String get adminSetStockTo => 'स्टॉक इतना सेट करें';

  @override
  String get adminEnterWholeNumber => 'पूर्ण संख्या दर्ज करें';

  @override
  String get adminAdjustPriceByPercent => 'कीमत % से समायोजित करें';

  @override
  String get adminAdjustPriceHint => 'उदा. +10% के लिए 10, -5% के लिए -5';

  @override
  String get adminEnterNumber => 'एक संख्या दर्ज करें';

  @override
  String adminSelectedCount(int count) {
    return '$count चयनित';
  }

  @override
  String get adminBulkEdit => 'बल्क एडिट';

  @override
  String adminBulkEditResult(int success, int total) {
    return '$total में से $success प्रोडक्ट अपडेट हुए।';
  }

  @override
  String get adminEditProduct => 'प्रोडक्ट संपादित करें';

  @override
  String get adminProductName => 'प्रोडक्ट का नाम';

  @override
  String get adminProductNameHint => 'उदा. बासमती चावल प्रीमियम 25kg';

  @override
  String get adminProductNameRequired => 'प्रोडक्ट का नाम आवश्यक है';

  @override
  String get adminCategory => 'श्रेणी';

  @override
  String adminCouldntLoadCategories(String error) {
    return 'श्रेणियां लोड नहीं हो सकीं: $error';
  }

  @override
  String get adminCategoryRequired => 'श्रेणी आवश्यक है';

  @override
  String get adminPriceLabel => 'कीमत (₹)';

  @override
  String get adminEnterValidPrice => 'मान्य कीमत दर्ज करें';

  @override
  String get adminPriceMustBeAbove0 => 'कीमत ₹0 से अधिक होनी चाहिए';

  @override
  String get adminUnit => 'इकाई';

  @override
  String adminPerUnit(String unit) {
    return 'प्रति $unit';
  }

  @override
  String get adminRateByQuantity => 'मात्रा के अनुसार दर (₹ प्रति किलो)';

  @override
  String get adminRateByQuantityHint =>
      'पूरा वजन उसके बैंड की एक दर पर बिल किया जाता है।';

  @override
  String get adminBandBelow240g => '240g से कम';

  @override
  String get adminBand240to999g => '240g – 999g';

  @override
  String get adminBand1to2400g => '1kg – 2.4kg';

  @override
  String get adminBandAbove2400g => '2.4kg से अधिक';

  @override
  String adminEnterRateFor(String label) {
    return '$label के लिए दर दर्ज करें';
  }

  @override
  String get adminRateMustBeAbove0 => 'दर ₹0 से अधिक होनी चाहिए';

  @override
  String get adminStockQuantity => 'स्टॉक मात्रा';

  @override
  String get adminInKilograms => 'किलोग्राम में';

  @override
  String adminInUnits(String unit) {
    return '$unit में';
  }

  @override
  String get adminEnterValidStock => 'मान्य स्टॉक मात्रा दर्ज करें';

  @override
  String get adminStockCannotBeNegative => 'स्टॉक नकारात्मक नहीं हो सकता';

  @override
  String get adminDescriptionOptional => 'विवरण (वैकल्पिक)';

  @override
  String get adminInactiveProductsHint =>
      'निष्क्रिय प्रोडक्ट्स आपके कैटलॉग में रहते हैं लेकिन रिटेलर्स से छिपे रहते हैं।';

  @override
  String get adminChooseCategory => 'कृपया एक श्रेणी चुनें।';

  @override
  String adminCouldntOpenGallery(String error) {
    return 'गैलरी नहीं खुल सकी: $error';
  }

  @override
  String adminUpdatedMessage(String name) {
    return '$name अपडेट हुआ।';
  }

  @override
  String adminAddedMessage(String name) {
    return '$name जोड़ा गया।';
  }

  @override
  String adminSaveFailed(String error) {
    return 'सहेजना विफल: $error';
  }

  @override
  String get adminManageCategoriesTitle => 'श्रेणियां प्रबंधित करें';

  @override
  String get adminAddCategory => 'श्रेणी जोड़ें';

  @override
  String get adminDeleteCategoryTitle => 'श्रेणी हटाएं?';

  @override
  String adminDeleteCategoryContent(String name) {
    return '\"$name\" को हमेशा के लिए हटा दिया जाएगा। इसे सौंपे गए प्रोडक्ट्स अपनी श्रेणी आईडी रखेंगे लेकिन किसी भी दिखाई देने वाली श्रेणी में नहीं दिखेंगे। इसे रिटेलर्स से बिना खोए छिपाने के लिए, श्रेणी संपादित करें और \"सक्रिय\" बंद करें।';
  }

  @override
  String adminCategoryDeletedMessage(String name) {
    return '$name हटा दिया गया।';
  }

  @override
  String get adminNoCategoriesYetTitle => 'अभी तक कोई श्रेणी नहीं';

  @override
  String get adminNoCategoriesYetMessage =>
      'अपनी पहली श्रेणी बनाने के लिए \"श्रेणी जोड़ें\" पर टैप करें।';

  @override
  String get adminEditCategory => 'श्रेणी संपादित करें';

  @override
  String get adminCategoryName => 'श्रेणी का नाम';

  @override
  String get adminCategoryNameHint => 'उदा. खाद्य तेल';

  @override
  String get adminCategoryNameRequired => 'श्रेणी का नाम आवश्यक है';

  @override
  String get adminInactiveCategoriesHint =>
      'निष्क्रिय श्रेणियां आपके कैटलॉग में रहती हैं लेकिन रिटेलर्स से छिपी रहती हैं।';

  @override
  String get adminAllOrdersTitle => 'सभी ऑर्डर';

  @override
  String get adminRetailerOrders => 'रिटेलर ऑर्डर';

  @override
  String adminRetailerOrdersTitle(String shopName) {
    return '$shopName — ऑर्डर';
  }

  @override
  String get adminExportCsvTooltip => 'CSV के रूप में एक्सपोर्ट करें';

  @override
  String get adminNoOrdersToExport => 'एक्सपोर्ट करने के लिए कोई ऑर्डर नहीं।';

  @override
  String get adminAllFilter => 'सभी';

  @override
  String adminCouldntLoadOrders(String error) {
    return 'ऑर्डर लोड नहीं हो सके: $error';
  }

  @override
  String get adminNoOrdersYet => 'अभी तक कोई ऑर्डर नहीं';

  @override
  String adminNoStatusOrders(String status) {
    return 'कोई $status ऑर्डर नहीं';
  }

  @override
  String get adminManageOrderTitle => 'ऑर्डर प्रबंधित करें';

  @override
  String adminStatusUpdated(String status) {
    return 'स्थिति $status में अपडेट हुई।';
  }

  @override
  String adminUpdateFailed(String error) {
    return 'अपडेट विफल: $error';
  }

  @override
  String get adminPaymentConfirmed => 'भुगतान की पुष्टि हुई।';

  @override
  String adminCouldntLoadOrder(String error) {
    return 'ऑर्डर लोड नहीं हो सका: $error';
  }

  @override
  String get adminOrderNotFound => 'यह ऑर्डर नहीं मिल सका।';

  @override
  String get adminOrderStatusLabel => 'ऑर्डर स्थिति';

  @override
  String get adminMarkAsPaid => 'भुगतान हुआ चिह्नित करें';

  @override
  String get adminRetailersTitle => 'रिटेलर्स';

  @override
  String get adminApprovedTab => 'स्वीकृत';

  @override
  String get adminPendingTab => 'लंबित';

  @override
  String adminPendingTabWithCount(int count) {
    return 'लंबित ($count)';
  }

  @override
  String adminCouldntLoadRetailers(String error) {
    return 'रिटेलर्स लोड नहीं हो सके: $error';
  }

  @override
  String get adminNoApprovedRetailersTitle => 'अभी तक कोई स्वीकृत रिटेलर नहीं';

  @override
  String get adminNoApprovedRetailersMessage =>
      'आपके स्वीकृत किए गए रिटेलर्स यहां उनके ऑर्डर इतिहास के साथ दिखेंगे।';

  @override
  String get adminOwnerSection => 'मालिक';

  @override
  String get adminFullNameLabel => 'पूरा नाम';

  @override
  String get adminContactSection => 'संपर्क';

  @override
  String get adminEmailLabel => 'ईमेल';

  @override
  String get adminPhoneLabel => 'फ़ोन';

  @override
  String get adminAddressSection => 'पता';

  @override
  String get adminStreetLabel => 'गली';

  @override
  String get adminCityLabel => 'शहर';

  @override
  String get adminPincodeLabel => 'पिनकोड';

  @override
  String get adminLocationLabel => 'स्थान';

  @override
  String get adminAddressNotProvided => 'पता अभी उपलब्ध नहीं है';

  @override
  String get adminGstSection => 'GST';

  @override
  String get adminGstNumberLabel => 'GST नंबर';

  @override
  String get adminBusinessHoursSection => 'व्यापार समय';

  @override
  String get adminOpenLabel => 'खुला';

  @override
  String get adminOpen24x7 => '24×7 खुला';

  @override
  String get adminBankDetailsSection => 'बैंक विवरण';

  @override
  String get adminAccountHolderLabel => 'खाताधारक';

  @override
  String get adminAccountNumberLabel => 'खाता संख्या';

  @override
  String get adminIfscLabel => 'IFSC';

  @override
  String get adminBankNameLabel => 'बैंक';

  @override
  String get adminUpiIdLabel => 'UPI ID';

  @override
  String get adminRegisteredOnSection => 'पंजीकरण तिथि';

  @override
  String get adminDateLabel => 'तारीख';

  @override
  String get adminDeliverySettingsTitle => 'डिलीवरी सेटिंग्स';

  @override
  String get adminWarehouseLocation => 'गोदाम स्थान';

  @override
  String get adminWarehouseLocationHint =>
      'हर डिलीवरी शुल्क इस स्थान से सीधी दूरी के आधार पर गणना की जाती है।';

  @override
  String get adminLatitude => 'अक्षांश';

  @override
  String get adminLongitude => 'देशांतर';

  @override
  String get adminEnterValidCoordinate => 'मान्य निर्देशांक दर्ज करें';

  @override
  String get adminUseCurrentLocation => 'वर्तमान स्थान का उपयोग करें';

  @override
  String get adminDeliverySavedSuccess =>
      '✓ डिलीवरी सेटिंग्स सफलतापूर्वक सहेजी गईं';

  @override
  String get adminPerKmRate => 'प्रति-किमी दर';

  @override
  String get adminRateLabelPerKm => 'दर (₹ प्रति किमी)';

  @override
  String get adminEnterValidRate => 'मान्य दर दर्ज करें';

  @override
  String adminCouldntLoadDeliverySettings(String error) {
    return 'डिलीवरी सेटिंग्स लोड नहीं हो सकीं: $error';
  }

  @override
  String get adminBulkImportTitle => 'प्रोडक्ट्स बल्क इम्पोर्ट करें';

  @override
  String get adminBulkImportInstructions =>
      'स्प्रेडशीट से कॉपी की गई पंक्तियां पेस्ट करें। हेडर पंक्ति आवश्यक: name, category, price, unit, stock, description (description वैकल्पिक है)। Unit इनमें से एक है: piece, box, litre, kg। kg प्रोडक्ट के लिए, वजन के अनुसार कीमत तय करने हेतु चार और कॉलम जोड़ें: below240g, upto999g, upto2400g, above2400g — फ्लैट प्रति-यूनिट कीमत के लिए इन्हें छोड़ दें।';

  @override
  String get adminCsvHint =>
      'name,category,price,unit,stock,description\nBasmati Rice 25kg,Rice,1800,box,10,Premium';

  @override
  String adminCouldNotLoadCategoriesShort(String error) {
    return 'श्रेणियां लोड नहीं हो सकीं: $error';
  }

  @override
  String adminImportCount(int count) {
    return '$count इम्पोर्ट करें';
  }

  @override
  String adminRowNumber(int number) {
    return 'पंक्ति $number';
  }

  @override
  String adminProductsCreated(int count) {
    return '$count प्रोडक्ट बनाए गए।';
  }

  @override
  String adminProductsCreatedWithFailures(int created, int failed) {
    return '$created प्रोडक्ट बनाए गए, $failed विफल।';
  }

  @override
  String adminOwnerNameValue(String name) {
    return 'मालिक: $name';
  }

  @override
  String adminPhoneValue(String phone) {
    return 'फ़ोन: $phone';
  }

  @override
  String get adminApprovalQueueClear => 'स्वीकृति सूची खाली है!';

  @override
  String get adminAllRetailersVerified => 'सभी पंजीकृत रिटेलर्स सत्यापित हैं।';

  @override
  String adminOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ऑर्डर',
      one: '1 ऑर्डर',
    );
    return '$_temp0';
  }

  @override
  String get adminInactiveBadge => 'निष्क्रिय';

  @override
  String get adminEditTooltip => 'संपादित करें';

  @override
  String get adminDeleteTooltip => 'हटाएं';

  @override
  String adminPricePerUnit(String price, String unit) {
    return '$price · प्रति $unit';
  }

  @override
  String adminStockLabel(int count) {
    return 'स्टॉक: $count';
  }

  @override
  String adminActionFailed(String error) {
    return 'कार्रवाई विफल: $error';
  }

  @override
  String get adminReject => 'अस्वीकार करें';

  @override
  String get adminApprove => 'स्वीकृत करें';

  @override
  String adminRejectedMessage(String name) {
    return '$name अस्वीकृत किया गया।';
  }

  @override
  String adminApprovedMessage(String name) {
    return '$name सफलतापूर्वक स्वीकृत हुआ!';
  }
}
