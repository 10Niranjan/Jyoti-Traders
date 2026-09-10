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
}
