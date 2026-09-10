// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get navHome => 'मुख्यपृष्ठ';

  @override
  String get navSearch => 'शोधा';

  @override
  String get navOrders => 'ऑर्डर्स';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get onboardingSkip => 'वगळा';

  @override
  String get onboardingNext => 'पुढे';

  @override
  String get onboardingGetStarted => 'सुरू करा';

  @override
  String get onboardingSlide1Title => 'संपूर्ण कॅटलॉग पहा';

  @override
  String get onboardingSlide1Subtitle =>
      'घाऊक आणि किरकोळ श्रेणी, निवडक उत्पादने, नेहमी अद्ययावत.';

  @override
  String get onboardingSlide2Title => 'मोठ्या ऑर्डर, चांगल्या किमती';

  @override
  String get onboardingSlide2Subtitle =>
      '₹2,500 पासून ऑर्डर करा आणि थेट तुमच्या दुकानात डिलिव्हरी मिळवा.';

  @override
  String get onboardingSlide3Title => 'तुमच्या पद्धतीने पैसे भरा';

  @override
  String get onboardingSlide3Subtitle =>
      'कॅश ऑन डिलिव्हरी किंवा यूपीआय — ऑर्डरपासून डिलिव्हरीपर्यंत प्रत्येक टप्पा ट्रॅक करा.';

  @override
  String get authSubtitleLogin => 'घाऊक आणि किरकोळ बाजार हब';

  @override
  String get authSubtitleSignup => 'तुमचे रिटेलर खाते तयार करा';

  @override
  String get authFullName => 'पूर्ण नाव';

  @override
  String get authFullNameHelper => 'फक्त अक्षरे आणि स्पेस';

  @override
  String get authPhoneNumber => 'फोन नंबर';

  @override
  String get authPhoneHelper => '10 अंकी मोबाइल नंबर';

  @override
  String get authBusinessName => 'व्यवसाय / दुकानाचे नाव';

  @override
  String get authBusinessNameHelper => 'अक्षरे, अंक, स्पेस, & - . परवानगी आहे';

  @override
  String get authEmailAddress => 'ईमेल पत्ता';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authPasswordHelperSignup =>
      '8+ अक्षरे, ज्यात मोठी-लहान अक्षरे, अंक आणि चिन्ह असावे';

  @override
  String get authEnterPasswordError => 'पासवर्ड टाका';

  @override
  String get authSignIn => 'साइन इन करा';

  @override
  String get authCreateAccount => 'खाते तयार करा';

  @override
  String get authNoAccount => 'खाते नाही? ';

  @override
  String get authHasAccount => 'आधीच खाते आहे? ';

  @override
  String get authSignUp => 'साइन अप करा';

  @override
  String get authDemoLoginLabel => 'सिम्युलेशन डेमो क्विक लॉगिन:';

  @override
  String get authAdminDemo => 'अ‍ॅडमिन डेमो';

  @override
  String get authRetailerDemo => 'रिटेलर डेमो';

  @override
  String get homeDefaultCustomerName => 'मौल्यवान ग्राहक';

  @override
  String get homeDefaultBusinessName => 'रिटेलर';

  @override
  String homeOwnerLabel(String name) {
    return 'मालक: $name';
  }

  @override
  String get homeBrowseCategories => 'श्रेणी पहा';

  @override
  String get homeNoCategoriesTitle => 'अजून कोणतीही श्रेणी नाही';

  @override
  String get homeNoCategoriesMessage =>
      'लवकरच पुन्हा तपासा — अ‍ॅडमिन कॅटलॉग तयार करत आहे.';

  @override
  String homeLowStockBanner(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'तुमच्या $count आवडत्या वस्तू कमी किंवा संपल्या आहेत.',
      one: 'तुमची 1 आवडती वस्तू कमी किंवा संपली आहे.',
    );
    return '$_temp0';
  }

  @override
  String get homeBuyAgain => 'पुन्हा खरेदी करा';

  @override
  String get homeTodaysPicks => 'आजच्या निवडी';

  @override
  String homeFromRatePerKg(String rate) {
    return '₹$rate/किलो पासून';
  }

  @override
  String get homeOutOfStock => 'स्टॉक संपला';

  @override
  String homeOnlyLeftInStock(int stock, String unit) {
    return 'फक्त $stock $unit शिल्लक';
  }

  @override
  String get pendingUnableToDialPhone => 'फोन डायल करता आला नाही: 9860460325';

  @override
  String get pendingUnableToOpenEmail =>
      'ईमेल क्लायंट उघडता आला नाही: vishvatejkatkar007@gmail.com';

  @override
  String get pendingTitle => 'खाते पडताळणी प्रलंबित आहे';

  @override
  String get pendingMessage =>
      'तुमचा रिटेलर अर्ज सध्या Jyoti Traders च्या मालकाकडून तपासला जात आहे. मंजुरी मिळाल्यावर तुम्हाला घाऊक उत्पादने खरेदी करण्याची पूर्ण सुविधा मिळेल.';

  @override
  String get pendingCheckingStatus => 'पडताळणी स्थिती तपासत आहे...';

  @override
  String get pendingCheckStatusAgain => 'पुन्हा स्थिती तपासा';

  @override
  String get pendingContactSupportTitle =>
      'तातडीने मंजुरी हवी? सहाय्याशी संपर्क साधा';

  @override
  String get pendingCallOwner => 'मालकाला कॉल करा: +91 98604 60325';

  @override
  String get pendingEmailSupport => 'ईमेल: vishvatejkatkar007@gmail.com';

  @override
  String get pendingSignOut => 'साइन आउट करा आणि दुसरे खाते वापरून पहा';

  @override
  String get pendingBrowseCatalog => 'प्रतीक्षा करताना कॅटलॉग पहा';

  @override
  String get homePendingBanner =>
      'प्रीव्ह्यू मोड — मंजुरी मिळाल्यावर तुम्ही ऑर्डर करू शकाल.';

  @override
  String get searchHint => 'उत्पादने शोधा...';

  @override
  String get searchEmptyTitle => 'उत्पादने शोधा';

  @override
  String get searchEmptyMessage =>
      '\"तांदूळ\" किंवा \"तेल\" सारखे उत्पादनाचे नाव वापरून पहा.';

  @override
  String get searchRecentSearches => 'अलीकडील शोध';

  @override
  String get searchClear => 'साफ करा';

  @override
  String searchNoResultsFor(String query) {
    return '\"$query\" साठी कोणतेही उत्पादन सापडले नाही';
  }

  @override
  String get searchSortRelevance => 'प्रासंगिकता';

  @override
  String get searchSortPriceLowToHigh => 'किंमत: कमी ते जास्त';

  @override
  String get searchSortPriceHighToLow => 'किंमत: जास्त ते कमी';

  @override
  String get searchInStockOnly => 'फक्त स्टॉकमध्ये';

  @override
  String get searchAllCategories => 'सर्व';

  @override
  String get productDetailsTitle => 'उत्पादन तपशील';

  @override
  String get wishlistTitle => 'इच्छा यादी';

  @override
  String get wishlistEmptyTitle => 'अजून काहीही जतन केलेले नाही';

  @override
  String get wishlistEmptyMessage =>
      'उत्पादन नंतरसाठी जतन करण्यासाठी हृदयावर टॅप करा.';

  @override
  String get wishlistAdded => 'इच्छा यादीत जोडले';

  @override
  String get wishlistRemoved => 'इच्छा यादीतून काढले';

  @override
  String get wishlistAddTooltip => 'इच्छा यादीत जोडा';

  @override
  String get wishlistRemoveTooltip => 'इच्छा यादीतून काढा';

  @override
  String get productNoLongerAvailable => 'हे उत्पादन आता उपलब्ध नाही.';

  @override
  String productSoldPer(String unit) {
    return '$unit नुसार विकले जाते';
  }

  @override
  String productInStock(int stock, String unit) {
    return '$stock $unit स्टॉकमध्ये';
  }

  @override
  String get productDescription => 'वर्णन';

  @override
  String get productYouMayAlsoLike => 'तुम्हाला हे देखील आवडू शकते';

  @override
  String productAddButtonLabel(String label, String price) {
    return '$label जोडा · $price';
  }

  @override
  String get productOutOfStockButton => 'स्टॉक संपला';

  @override
  String productAddedToCart(String name) {
    return '$name कार्टमध्ये जोडले';
  }

  @override
  String get productViewCartAction => 'कार्ट पहा';

  @override
  String get categoryProductsFallbackTitle => 'उत्पादने';

  @override
  String get categoryProductsEmptyTitle =>
      'या श्रेणीत अजून कोणतीही उत्पादने नाहीत';

  @override
  String get cartTitle => 'कार्ट';

  @override
  String get cartClearAll => 'सर्व काढा';

  @override
  String get cartEmptyTitle => 'तुमची कार्ट रिकामी आहे';

  @override
  String get cartEmptyMessage => 'घाऊक ऑर्डर देण्यासाठी उत्पादने जोडा.';

  @override
  String get cartBrowseProducts => 'उत्पादने पहा';

  @override
  String cartBelowMinimum(String amount, String minimum) {
    return 'किमान ऑर्डर $minimum पर्यंत पोहोचण्यासाठी आणखी $amount जोडा.';
  }

  @override
  String get cartSubtotal => 'उपएकूण';

  @override
  String get cartDeliveryCharge => 'डिलिव्हरी शुल्क (अंदाजे)';

  @override
  String get cartTotal => 'एकूण';

  @override
  String get cartProceedToCheckout => 'चेकआउटकडे जा';

  @override
  String cartWeightAtRate(String weight, String rate) {
    return '$weight @ ₹$rate/किलो';
  }

  @override
  String get cartCouponHint => 'कूपन कोड टाका';

  @override
  String get cartCouponApply => 'लागू करा';

  @override
  String get cartCouponRemove => 'काढा';

  @override
  String cartCouponApplied(String code) {
    return '\"$code\" लागू केले';
  }

  @override
  String get cartDiscount => 'सवलत';

  @override
  String get checkoutLocationError =>
      'तुमचे स्थान मिळू शकले नाही. लोकेशन परवानगी तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get checkoutTitle => 'चेकआउट';

  @override
  String get checkoutDeliveryAddress => 'डिलिव्हरी पत्ता';

  @override
  String get checkoutPaymentMethod => 'पेमेंट पद्धत';

  @override
  String get checkoutCod => 'कॅश ऑन डिलिव्हरी (COD)';

  @override
  String get checkoutUpi => 'यूपीआय';

  @override
  String get checkoutOrderSummary => 'ऑर्डर सारांश';

  @override
  String checkoutSubtotalItems(int count) {
    return 'उपएकूण ($count वस्तू)';
  }

  @override
  String get checkoutDeliveryCharge => 'डिलिव्हरी शुल्क';

  @override
  String get checkoutDeliveryChargeEstimated => 'डिलिव्हरी शुल्क (अंदाजे)';

  @override
  String get checkoutEtaToday => 'आज पोहोचेल';

  @override
  String get checkoutEtaTomorrow => 'उद्यापर्यंत पोहोचेल';

  @override
  String get checkoutEtaFewDays => '2–3 दिवसांत पोहोचेल';

  @override
  String get checkoutEtaUnknown => '1–2 दिवसांत पोहोचेल';

  @override
  String get checkoutGrandTotal => 'एकूण रक्कम';

  @override
  String get checkoutPlaceOrder => 'ऑर्डर करा';

  @override
  String get checkoutSavedAddresses => 'जतन केलेले पत्ते';

  @override
  String get checkoutSaveAddressToggle => 'हा पत्ता नंतरसाठी जतन करा';

  @override
  String get checkoutSaveAddressLabelHint => 'लेबल (उदा. दुकान, गोदाम)';

  @override
  String get checkoutSaveAddressLabelRequired =>
      'हा पत्ता जतन करण्यासाठी लेबल जोडा';

  @override
  String upiGalleryError(String error) {
    return 'गॅलरी उघडता आली नाही: $error';
  }

  @override
  String get upiIdCopied => 'UPI आयडी कॉपी झाली.';

  @override
  String upiConfirmError(String error) {
    return 'पेमेंटची पुष्टी करता आली नाही: $error';
  }

  @override
  String get upiPaymentTitle => 'यूपीआय पेमेंट';

  @override
  String upiOrderLoadError(String error) {
    return 'ऑर्डर लोड करता आली नाही: $error';
  }

  @override
  String get upiOrderNotFound => 'हा ऑर्डर सापडला नाही.';

  @override
  String upiPayAmount(String amount) {
    return '$amount भरा';
  }

  @override
  String get upiScanInstructions =>
      'कोणत्याही UPI अ‍ॅपने स्कॅन करा, किंवा खालील आयडी वापरा';

  @override
  String get upiScreenshotLabel => 'पेमेंट स्क्रीनशॉट (ऐच्छिक)';

  @override
  String get upiIHavePaid => 'मी पेमेंट केले आहे';

  @override
  String get upiConfirmationNote =>
      'अ‍ॅडमिन लवकरच तुमच्या पेमेंटची पुष्टी करेल.';

  @override
  String get orderSuccessTitle => 'ऑर्डर दिली!';

  @override
  String orderSuccessOrderNumber(String shortId) {
    return 'ऑर्डर #$shortId';
  }

  @override
  String get orderSuccessMessage =>
      'अ‍ॅडमिनला कळवले आहे आणि ते लवकरच तुमच्या ऑर्डरची पुष्टी करतील.';

  @override
  String get orderSuccessViewOrder => 'ऑर्डर पहा';

  @override
  String get orderSuccessContinueShopping => 'खरेदी सुरू ठेवा';

  @override
  String get orderHistoryTitle => 'माझे ऑर्डर्स';

  @override
  String get orderHistoryFilterAll => 'सर्व';

  @override
  String get orderHistoryEmptyTitle => 'अजून कोणतीही ऑर्डर नाही';

  @override
  String orderHistoryEmptyFiltered(String status) {
    return 'कोणतीही $status ऑर्डर नाही';
  }

  @override
  String get orderHistoryEmptyMessage => 'तुम्ही दिलेल्या ऑर्डर इथे दिसतील.';

  @override
  String orderNumber(String shortId) {
    return 'ऑर्डर #$shortId';
  }

  @override
  String orderItemsAndDate(int count, String date) {
    return '$count वस्तू · $date';
  }

  @override
  String get orderDetailsTitle => 'ऑर्डर तपशील';

  @override
  String get orderShareTooltip => 'शेअर करा';

  @override
  String get orderCancelDialogTitle => 'ही ऑर्डर रद्द करायची?';

  @override
  String get orderCancelDialogContent => 'हे पूर्ववत करता येणार नाही.';

  @override
  String get no => 'नाही';

  @override
  String get yesCancel => 'होय, रद्द करा';

  @override
  String get orderCancelledMessage => 'ऑर्डर रद्द केली.';

  @override
  String get orderCancelFailedMessage =>
      'रद्द करणे अयशस्वी झाले. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get cancelButton => 'रद्द करा';

  @override
  String buyAgainAddedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तू कार्टमध्ये जोडल्या',
      one: '1 वस्तू कार्टमध्ये जोडली',
    );
    return '$_temp0';
  }

  @override
  String buyAgainUnavailableSuffix(int count) {
    return ' — $count आता उपलब्ध नाही.';
  }

  @override
  String get profileSettingsTab => 'सेटिंग्ज';

  @override
  String profileUpdatePhotoError(String error) {
    return 'फोटो अपडेट करता आला नाही: $error';
  }

  @override
  String profileUpdateFailed(String error) {
    return 'अपडेट अयशस्वी: $error';
  }

  @override
  String get profileUpdated => 'प्रोफाइल अपडेट झाली';

  @override
  String profileSaveFailed(String error) {
    return 'सेव्ह करता आले नाही: $error';
  }

  @override
  String get profileChangePasswordDialogTitle => 'पासवर्ड बदलायचा?';

  @override
  String profileResetLinkMessage(String email) {
    return 'आम्ही $email वर पासवर्ड रीसेट लिंक पाठवू.';
  }

  @override
  String get profileSendLink => 'लिंक पाठवा';

  @override
  String profileResetLinkFailed(String error) {
    return 'रीसेट लिंक पाठवता आली नाही: $error';
  }

  @override
  String profileResetLinkSent(String email) {
    return 'पासवर्ड रीसेट लिंक $email वर पाठवली';
  }

  @override
  String get profileLogoutDialogTitle => 'लॉग आउट करायचे?';

  @override
  String get profileLogoutDialogContent =>
      'तुमच्या खात्यात प्रवेश करण्यासाठी तुम्हाला पुन्हा साइन इन करावे लागेल.';

  @override
  String get profileLogOut => 'लॉग आउट';

  @override
  String get profileSavedAddresses => 'जतन केलेले पत्ते';

  @override
  String get profileNoSavedAddresses =>
      'चेकआउटवर तुम्ही जतन केलेले पत्ते इथे दिसतील.';

  @override
  String get profileRemoveAddressAction => 'काढा';

  @override
  String get profileRemoveAddressTitle => 'पत्ता काढायचा?';

  @override
  String profileRemoveAddressContent(String label) {
    return '\"$label\" तुमच्या जतन केलेल्या पत्त्यांमधून काढायचा?';
  }

  @override
  String get profileAddressRemoved => 'पत्ता काढला';

  @override
  String get profileBusinessDetails => 'व्यवसाय तपशील';

  @override
  String get profileGstNumber => 'GST क्रमांक (ऐच्छिक)';

  @override
  String get profileOpen24x7 => '24×7 उघडे';

  @override
  String profileOpensAt(String time) {
    return 'उघडते: $time';
  }

  @override
  String profileClosesAt(String time) {
    return 'बंद होते: $time';
  }

  @override
  String get profilePayoutDetails => 'पेआउट तपशील';

  @override
  String get profileAccountHolderName => 'खातेधारकाचे नाव';

  @override
  String get profileAccountNumber => 'खाते क्रमांक';

  @override
  String get profileIfscCode => 'IFSC कोड';

  @override
  String get profileBankName => 'बँकेचे नाव';

  @override
  String get profileUpiIdOptional => 'UPI आयडी (ऐच्छिक)';

  @override
  String get profileSaveChanges => 'बदल जतन करा';

  @override
  String get profileNotifications => 'सूचना';

  @override
  String get profileOrderUpdates => 'ऑर्डर अपडेट्स';

  @override
  String get profileOrderUpdatesSubtitle => 'तुमच्या ऑर्डरच्या स्थितीतील बदल';

  @override
  String get profilePromotions => 'जाहिराती';

  @override
  String get profilePromotionsSubtitle => 'ऑफर आणि सवलती';

  @override
  String get profileLowStockAlerts => 'कमी स्टॉक सूचना';

  @override
  String get profileLowStockAlertsSubtitle =>
      'तुम्ही वारंवार घेत असलेल्या वस्तू कमी होत असताना';

  @override
  String get profileAppearance => 'रूपरेषा';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get profileAccountSection => 'खाते';

  @override
  String get profileChangePassword => 'पासवर्ड बदला';

  @override
  String get profileSupport => 'सहाय्य';

  @override
  String get profileCallSupport => 'सहाय्याला कॉल करा';

  @override
  String get profileEmailSupport => 'सहाय्याला ईमेल करा';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageMarathi => 'मराठी';

  @override
  String get adminProfileTitle => 'अ‍ॅडमिन प्रोफाइल';

  @override
  String get profileAccountInfo => 'खाते माहिती';

  @override
  String get profileRoleLabel => 'भूमिका';

  @override
  String get profileRoleAdmin => 'प्रशासक';

  @override
  String profileMemberSince(String date) {
    return 'सदस्य झाले: $date';
  }

  @override
  String get profileStoreSection => 'स्टोअर';

  @override
  String get profileDeliverySettings => 'डिलिव्हरी सेटिंग्ज';

  @override
  String get broadcastTitle => 'प्रसारण पाठवा';

  @override
  String get broadcastTitleFieldLabel => 'शीर्षक';

  @override
  String get broadcastBodyFieldLabel => 'संदेश';

  @override
  String get broadcastSendButton => 'सर्व किरकोळ विक्रेत्यांना पाठवा';

  @override
  String get broadcastSentConfirmation => 'प्रसारण पाठवले';

  @override
  String get broadcastHistoryEmpty => 'अजून कोणतेही प्रसारण पाठवलेले नाही';

  @override
  String get profileDeliverySettingsSubtitle =>
      'डिलिव्हरी त्रिज्या, शुल्क आणि किमान ऑर्डर रक्कम';

  @override
  String get notificationsTitle => 'सूचना';

  @override
  String get notificationsMarkAllRead => 'सर्व वाचले म्हणून चिन्हांकित करा';

  @override
  String notificationsLoadError(String error) {
    return 'सूचना लोड करता आल्या नाहीत: $error';
  }

  @override
  String get notificationsEmptyTitle => 'अजून कोणतीही सूचना नाही';

  @override
  String get notificationsEmptyMessage =>
      'तुमच्या ऑर्डरबद्दलचे अपडेट्स इथे दिसतील.';

  @override
  String productPerUnit(String unit) {
    return 'प्रति $unit';
  }

  @override
  String get quantitySheetLabel => 'प्रमाण';

  @override
  String quantitySheetInStock(String label) {
    return 'स्टॉकमध्ये: $label';
  }

  @override
  String quantitySheetMinimum(String label) {
    return 'किमान $label';
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
  String get quantitySheetEnterQuantity => 'प्रमाण टाका';

  @override
  String quantitySheetUpdateTo(String label) {
    return '$label मध्ये बदला';
  }

  @override
  String quantitySheetAddToCart(String label) {
    return 'कार्टमध्ये $label जोडा';
  }

  @override
  String get quantityPickerSelectQuantity => 'प्रमाण निवडा';

  @override
  String get quantityPickerCustomQuantity => 'सानुकूल प्रमाण';

  @override
  String get rateSlabTitle => 'प्रमाणानुसार दर (₹ प्रति किलो)';

  @override
  String get rateSlabSubtitle =>
      'संपूर्ण वजन त्याच्या बँडच्या एकाच दराने बिल केले जाते.';

  @override
  String ratePerKg(String rate) {
    return '₹$rate/किलो';
  }

  @override
  String get addressStreetLabel => 'गल्ली / दुकानाचा पत्ता';

  @override
  String get addressCityLabel => 'शहर';

  @override
  String get addressPincodeLabel => 'पिनकोड';

  @override
  String get addressDetecting => 'तुमचे स्थान शोधत आहे…';

  @override
  String get addressDetectedPrefix => 'आढळले: ';

  @override
  String get addressAddForPricing =>
      'अचूक डिलिव्हरी किमतीसाठी तुमचे स्थान जोडा';

  @override
  String get addressRefreshLocation => 'स्थान रीफ्रेश करा';

  @override
  String get addressUseCurrentLocation => 'सध्याचे स्थान वापरा';

  @override
  String get orderStatusHeading => 'ऑर्डर स्थिती';

  @override
  String get orderItemsHeading => 'वस्तू';

  @override
  String orderWeighedLine(String name, String weight, String rate) {
    return '$name · $weight @ ₹$rate/किलो';
  }

  @override
  String orderUnitLine(String name, int qty) {
    return '$name × $qty';
  }

  @override
  String get orderDeliveryAddressHeading => 'डिलिव्हरी पत्ता';

  @override
  String orderAddressLine(String street, String city, String pincode) {
    return '$street, $city - $pincode';
  }

  @override
  String get orderPaymentHeading => 'पेमेंट';

  @override
  String get orderPaymentCod => 'कॅश ऑन डिलिव्हरी';

  @override
  String get orderPaymentScreenshotLabel => 'पेमेंट स्क्रीनशॉट';

  @override
  String cartItemCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तू',
      one: '1 वस्तू',
    );
    return '$_temp0';
  }

  @override
  String get cartViewCart => 'कार्ट पहा';

  @override
  String cartAddMoreShort(String amount) {
    return 'ऑर्डरसाठी आणखी $amount जोडा';
  }

  @override
  String get firstRunHintBuyAgain =>
      'पुन्हा लवकर ऑर्डर करण्यासाठी येथे कोणत्याही वस्तूवर टॅप करा';

  @override
  String get cartRemoveItemTooltip => 'वस्तू काढा';

  @override
  String get authShowPassword => 'पासवर्ड दाखवा';

  @override
  String get authHidePassword => 'पासवर्ड लपवा';

  @override
  String get adminClearSearchTooltip => 'शोध साफ करा';

  @override
  String get adminRefreshTooltip => 'रिफ्रेश करा';

  @override
  String get promoMinOrderTitle => 'घाऊक खरेदी ऑर्डर सक्तीची';

  @override
  String promoMinOrderBody(String amount) {
    return 'किमान ऑर्डर मूल्य: चेकआउटवर $amount.';
  }

  @override
  String get promoDeliveryTitle => 'स्वतःची डिलिव्हरी टीम';

  @override
  String get promoDeliveryBody =>
      'आमच्या स्वतःच्या डिलिव्हरी कर्मचाऱ्यांकडून डिलिव्हर केले जाते — कोणतेही थर्ड-पार्टी लॉजिस्टिक्स नाही.';

  @override
  String get promoHelpTitle => 'मदत हवी आहे?';

  @override
  String promoHelpBody(String phone) {
    return 'तुमच्या ऑर्डरच्या मदतीसाठी $phone वर कॉल करा.';
  }

  @override
  String get editProfileTitle => 'प्रोफाइल संपादित करा';

  @override
  String get save => 'जतन करा';

  @override
  String get editProfileTooltip => 'प्रोफाइल संपादित करा';

  @override
  String get errorGeneric => 'काहीतरी चूक झाली. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get adminCancel => 'रद्द करा';

  @override
  String get adminDelete => 'काढा';

  @override
  String get adminEdit => 'संपादित करा';

  @override
  String get adminActive => 'सक्रिय';

  @override
  String get adminSaveChanges => 'बदल जतन करा';

  @override
  String get adminApply => 'लागू करा';

  @override
  String get adminPreview => 'पूर्वावलोकन';

  @override
  String get adminDashboardTitle => 'ज्योती ट्रेडर्स ऍडमिन';

  @override
  String get adminPendingApprovals => 'प्रलंबित मंजुरी';

  @override
  String get adminTotalRetailers => 'एकूण रिटेलर्स';

  @override
  String get adminTodaysOrders => 'आजच्या ऑर्डर';

  @override
  String get adminTodaysRevenue => 'आजचे उत्पन्न';

  @override
  String get adminTopProducts => 'टॉप प्रॉडक्ट्स';

  @override
  String adminCouldntLoadTopProducts(String error) {
    return 'टॉप प्रॉडक्ट्स लोड होऊ शकले नाहीत: $error';
  }

  @override
  String get adminNoSalesYet => 'अद्याप विक्री नाही';

  @override
  String get adminSendBroadcast => 'ब्रॉडकास्ट पाठवा';

  @override
  String get adminRetailerApprovalQueue => 'रिटेलर मंजुरी यादी';

  @override
  String get adminViewAll => 'सर्व पहा';

  @override
  String adminCouldntLoadApprovalQueue(String error) {
    return 'मंजुरी यादी लोड होऊ शकली नाही: $error';
  }

  @override
  String adminMoreWaiting(int count) {
    return '+$count अजून प्रतीक्षेत — \"सर्व पहा\" वर टॅप करा';
  }

  @override
  String get adminCatalogTitle => 'कॅटलॉग';

  @override
  String get adminProductsTab => 'प्रॉडक्ट्स';

  @override
  String get adminCategoriesTab => 'श्रेणी';

  @override
  String get adminBulkImportTooltip => 'बल्क इम्पोर्ट';

  @override
  String get adminManageProductsTitle => 'प्रॉडक्ट्स व्यवस्थापित करा';

  @override
  String get adminAddProduct => 'प्रॉडक्ट जोडा';

  @override
  String get adminSearchProducts => 'प्रॉडक्ट्स शोधा';

  @override
  String get adminAllCategories => 'सर्व श्रेणी';

  @override
  String get adminSortNameAZ => 'नाव (A–Z)';

  @override
  String get adminSortStockLow => 'स्टॉक (कमी आधी)';

  @override
  String get adminSortPriceLow => 'किंमत (कमी आधी)';

  @override
  String get adminSortPriceHigh => 'किंमत (जास्त आधी)';

  @override
  String get adminSelect => 'निवडा';

  @override
  String adminCouldntLoadProducts(String error) {
    return 'प्रॉडक्ट्स लोड होऊ शकले नाहीत: $error';
  }

  @override
  String get adminNoProductsYetTitle => 'अद्याप कोणतेही प्रॉडक्ट नाही';

  @override
  String get adminNoProductsYetMessage =>
      'तुमचे पहिले कॅटलॉग आयटम तयार करण्यासाठी \"प्रॉडक्ट जोडा\" वर टॅप करा.';

  @override
  String get adminNoProductsMatchTitle => 'कोणतेही प्रॉडक्ट जुळत नाही';

  @override
  String get adminNoProductsMatchMessage =>
      'वेगळा शोध शब्द किंवा फिल्टर वापरून पहा.';

  @override
  String adminLowStockBanner(int count, int threshold) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रॉडक्ट्सचा स्टॉक कमी आहे (≤ $threshold).',
      one: '1 प्रॉडक्टचा स्टॉक कमी आहे (≤ $threshold).',
    );
    return '$_temp0';
  }

  @override
  String get adminDeleteProductTitle => 'प्रॉडक्ट काढायचे?';

  @override
  String adminDeleteProductContent(String name) {
    return '\"$name\" कॅटलॉगमधून कायमचे काढले जाईल. रिटेलर्सपासून न गमावता लपवण्यासाठी, प्रॉडक्ट संपादित करून \"सक्रिय\" बंद करा.';
  }

  @override
  String adminProductDeletedMessage(String name) {
    return '$name काढले गेले.';
  }

  @override
  String adminDeleteFailed(String error) {
    return 'काढणे अयशस्वी: $error';
  }

  @override
  String adminBulkEditTitle(int count) {
    return '$count प्रॉडक्ट्स बल्क एडिट करा';
  }

  @override
  String get adminBulkEditHint =>
      'मूल्य अपरिवर्तित ठेवण्यासाठी फील्ड रिकामे सोडा.';

  @override
  String get adminSetStockTo => 'स्टॉक इतका सेट करा';

  @override
  String get adminEnterWholeNumber => 'पूर्ण संख्या टाका';

  @override
  String get adminAdjustPriceByPercent => 'किंमत % ने समायोजित करा';

  @override
  String get adminAdjustPriceHint => 'उदा. +10% साठी 10, -5% साठी -5';

  @override
  String get adminEnterNumber => 'एक संख्या टाका';

  @override
  String adminSelectedCount(int count) {
    return '$count निवडले';
  }

  @override
  String get adminBulkEdit => 'बल्क एडिट';

  @override
  String adminBulkEditResult(int success, int total) {
    return '$total पैकी $success प्रॉडक्ट्स अपडेट झाले.';
  }

  @override
  String get adminEditProduct => 'प्रॉडक्ट संपादित करा';

  @override
  String get adminProductName => 'प्रॉडक्टचे नाव';

  @override
  String get adminProductNameHint => 'उदा. बासमती तांदूळ प्रीमियम 25kg';

  @override
  String get adminProductNameRequired => 'प्रॉडक्टचे नाव आवश्यक आहे';

  @override
  String get adminCategory => 'श्रेणी';

  @override
  String adminCouldntLoadCategories(String error) {
    return 'श्रेणी लोड होऊ शकल्या नाहीत: $error';
  }

  @override
  String get adminCategoryRequired => 'श्रेणी आवश्यक आहे';

  @override
  String get adminPriceLabel => 'किंमत (₹)';

  @override
  String get adminEnterValidPrice => 'वैध किंमत टाका';

  @override
  String get adminPriceMustBeAbove0 => 'किंमत ₹0 पेक्षा जास्त असावी';

  @override
  String get adminUnit => 'एकक';

  @override
  String adminPerUnit(String unit) {
    return 'प्रति $unit';
  }

  @override
  String get adminRateByQuantity => 'प्रमाणानुसार दर (₹ प्रति किलो)';

  @override
  String get adminRateByQuantityHint =>
      'संपूर्ण वजन त्याच्या बँडच्या एका दराने बिल केले जाते.';

  @override
  String get adminBandBelow240g => '240g पेक्षा कमी';

  @override
  String get adminBand240to999g => '240g – 999g';

  @override
  String get adminBand1to2400g => '1kg – 2.4kg';

  @override
  String get adminBandAbove2400g => '2.4kg पेक्षा जास्त';

  @override
  String adminEnterRateFor(String label) {
    return '$label साठी दर टाका';
  }

  @override
  String get adminRateMustBeAbove0 => 'दर ₹0 पेक्षा जास्त असावा';

  @override
  String get adminStockQuantity => 'स्टॉक प्रमाण';

  @override
  String get adminInKilograms => 'किलोग्राममध्ये';

  @override
  String adminInUnits(String unit) {
    return '$unit मध्ये';
  }

  @override
  String get adminEnterValidStock => 'वैध स्टॉक प्रमाण टाका';

  @override
  String get adminStockCannotBeNegative => 'स्टॉक ऋण असू शकत नाही';

  @override
  String get adminDescriptionOptional => 'वर्णन (ऐच्छिक)';

  @override
  String get adminInactiveProductsHint =>
      'निष्क्रिय प्रॉडक्ट्स तुमच्या कॅटलॉगमध्ये राहतात पण रिटेलर्सपासून लपलेले असतात.';

  @override
  String get adminChooseCategory => 'कृपया एक श्रेणी निवडा.';

  @override
  String adminCouldntOpenGallery(String error) {
    return 'गॅलरी उघडू शकली नाही: $error';
  }

  @override
  String adminUpdatedMessage(String name) {
    return '$name अपडेट झाले.';
  }

  @override
  String adminAddedMessage(String name) {
    return '$name जोडले गेले.';
  }

  @override
  String adminSaveFailed(String error) {
    return 'जतन करणे अयशस्वी: $error';
  }

  @override
  String get adminManageCategoriesTitle => 'श्रेणी व्यवस्थापित करा';

  @override
  String get adminAddCategory => 'श्रेणी जोडा';

  @override
  String get adminDeleteCategoryTitle => 'श्रेणी काढायची?';

  @override
  String adminDeleteCategoryContent(String name) {
    return '\"$name\" कायमची काढली जाईल. आधीच नियुक्त केलेली प्रॉडक्ट्स त्यांचा श्रेणी आयडी ठेवतील पण कोणत्याही दिसणाऱ्या श्रेणीखाली दिसणार नाहीत. रिटेलर्सपासून न गमावता लपवण्यासाठी, श्रेणी संपादित करून \"सक्रिय\" बंद करा.';
  }

  @override
  String adminCategoryDeletedMessage(String name) {
    return '$name काढली गेली.';
  }

  @override
  String get adminNoCategoriesYetTitle => 'अद्याप कोणतीही श्रेणी नाही';

  @override
  String get adminNoCategoriesYetMessage =>
      'तुमची पहिली श्रेणी तयार करण्यासाठी \"श्रेणी जोडा\" वर टॅप करा.';

  @override
  String get adminEditCategory => 'श्रेणी संपादित करा';

  @override
  String get adminCategoryName => 'श्रेणीचे नाव';

  @override
  String get adminCategoryNameHint => 'उदा. खाद्य तेल';

  @override
  String get adminCategoryNameRequired => 'श्रेणीचे नाव आवश्यक आहे';

  @override
  String get adminInactiveCategoriesHint =>
      'निष्क्रिय श्रेणी तुमच्या कॅटलॉगमध्ये राहतात पण रिटेलर्सपासून लपलेल्या असतात.';

  @override
  String get adminAllOrdersTitle => 'सर्व ऑर्डर';

  @override
  String get adminRetailerOrders => 'रिटेलर ऑर्डर';

  @override
  String adminRetailerOrdersTitle(String shopName) {
    return '$shopName — ऑर्डर';
  }

  @override
  String get adminExportCsvTooltip => 'CSV म्हणून एक्सपोर्ट करा';

  @override
  String get adminNoOrdersToExport =>
      'एक्सपोर्ट करण्यासाठी कोणतेही ऑर्डर नाही.';

  @override
  String get adminAllFilter => 'सर्व';

  @override
  String adminCouldntLoadOrders(String error) {
    return 'ऑर्डर लोड होऊ शकले नाहीत: $error';
  }

  @override
  String get adminNoOrdersYet => 'अद्याप कोणतेही ऑर्डर नाही';

  @override
  String adminNoStatusOrders(String status) {
    return 'कोणतेही $status ऑर्डर नाही';
  }

  @override
  String get adminManageOrderTitle => 'ऑर्डर व्यवस्थापित करा';

  @override
  String adminStatusUpdated(String status) {
    return 'स्थिती $status मध्ये अपडेट झाली.';
  }

  @override
  String adminUpdateFailed(String error) {
    return 'अपडेट अयशस्वी: $error';
  }

  @override
  String get adminPaymentConfirmed => 'पेमेंट पुष्टी झाली.';

  @override
  String adminCouldntLoadOrder(String error) {
    return 'ऑर्डर लोड होऊ शकला नाही: $error';
  }

  @override
  String get adminOrderNotFound => 'हा ऑर्डर सापडला नाही.';

  @override
  String get adminOrderStatusLabel => 'ऑर्डर स्थिती';

  @override
  String get adminMarkAsPaid => 'पेमेंट झाले म्हणून चिन्हांकित करा';

  @override
  String get adminRetailersTitle => 'रिटेलर्स';

  @override
  String get adminApprovedTab => 'मंजूर';

  @override
  String get adminPendingTab => 'प्रलंबित';

  @override
  String adminPendingTabWithCount(int count) {
    return 'प्रलंबित ($count)';
  }

  @override
  String adminCouldntLoadRetailers(String error) {
    return 'रिटेलर्स लोड होऊ शकले नाहीत: $error';
  }

  @override
  String get adminNoApprovedRetailersTitle =>
      'अद्याप कोणतेही मंजूर रिटेलर नाही';

  @override
  String get adminNoApprovedRetailersMessage =>
      'तुम्ही मंजूर केलेले रिटेलर्स त्यांच्या ऑर्डर इतिहासासह इथे दिसतील.';

  @override
  String get adminOwnerSection => 'मालक';

  @override
  String get adminFullNameLabel => 'पूर्ण नाव';

  @override
  String get adminContactSection => 'संपर्क';

  @override
  String get adminEmailLabel => 'ईमेल';

  @override
  String get adminPhoneLabel => 'फोन';

  @override
  String get adminAddressSection => 'पत्ता';

  @override
  String get adminStreetLabel => 'रस्ता';

  @override
  String get adminCityLabel => 'शहर';

  @override
  String get adminPincodeLabel => 'पिनकोड';

  @override
  String get adminLocationLabel => 'स्थान';

  @override
  String get adminAddressNotProvided => 'पत्ता अद्याप दिलेला नाही';

  @override
  String get adminGstSection => 'GST';

  @override
  String get adminGstNumberLabel => 'GST क्रमांक';

  @override
  String get adminBusinessHoursSection => 'व्यवसाय वेळ';

  @override
  String get adminOpenLabel => 'उघडे';

  @override
  String get adminOpen24x7 => '24×7 उघडे';

  @override
  String get adminBankDetailsSection => 'बँक तपशील';

  @override
  String get adminAccountHolderLabel => 'खातेधारक';

  @override
  String get adminAccountNumberLabel => 'खाते क्रमांक';

  @override
  String get adminIfscLabel => 'IFSC';

  @override
  String get adminBankNameLabel => 'बँक';

  @override
  String get adminUpiIdLabel => 'UPI ID';

  @override
  String get adminRegisteredOnSection => 'नोंदणी तारीख';

  @override
  String get adminDateLabel => 'तारीख';

  @override
  String get adminDeliverySettingsTitle => 'डिलिव्हरी सेटिंग्ज';

  @override
  String get adminWarehouseLocation => 'गोदाम स्थान';

  @override
  String get adminWarehouseLocationHint =>
      'प्रत्येक डिलिव्हरी शुल्क या ठिकाणापासूनच्या सरळ रेषेतील अंतरावरून मोजले जाते.';

  @override
  String get adminLatitude => 'अक्षांश';

  @override
  String get adminLongitude => 'रेखांश';

  @override
  String get adminEnterValidCoordinate => 'वैध निर्देशांक टाका';

  @override
  String get adminUseCurrentLocation => 'सध्याचे स्थान वापरा';

  @override
  String get adminDeliverySavedSuccess =>
      '✓ डिलिव्हरी सेटिंग्ज यशस्वीरित्या जतन झाल्या';

  @override
  String get adminPerKmRate => 'प्रति-किमी दर';

  @override
  String get adminRateLabelPerKm => 'दर (₹ प्रति किमी)';

  @override
  String get adminEnterValidRate => 'वैध दर टाका';

  @override
  String adminCouldntLoadDeliverySettings(String error) {
    return 'डिलिव्हरी सेटिंग्ज लोड होऊ शकल्या नाहीत: $error';
  }

  @override
  String get adminBulkImportTitle => 'प्रॉडक्ट्स बल्क इम्पोर्ट करा';

  @override
  String get adminBulkImportInstructions =>
      'स्प्रेडशीटमधून कॉपी केलेल्या ओळी पेस्ट करा. हेडर ओळ आवश्यक: name, category, price, unit, stock, description (description ऐच्छिक). Unit यापैकी एक आहे: piece, box, litre, kg. kg प्रॉडक्टसाठी, वजनानुसार किंमत ठरवण्यासाठी आणखी चार कॉलम जोडा: below240g, upto999g, upto2400g, above2400g — फ्लॅट प्रति-युनिट किमतीसाठी ते वगळा.';

  @override
  String get adminCsvHint =>
      'name,category,price,unit,stock,description\nBasmati Rice 25kg,Rice,1800,box,10,Premium';

  @override
  String adminCouldNotLoadCategoriesShort(String error) {
    return 'श्रेणी लोड होऊ शकल्या नाहीत: $error';
  }

  @override
  String adminImportCount(int count) {
    return '$count इम्पोर्ट करा';
  }

  @override
  String adminRowNumber(int number) {
    return 'ओळ $number';
  }

  @override
  String adminProductsCreated(int count) {
    return '$count प्रॉडक्ट्स तयार झाले.';
  }

  @override
  String adminProductsCreatedWithFailures(int created, int failed) {
    return '$created प्रॉडक्ट्स तयार झाले, $failed अयशस्वी.';
  }

  @override
  String adminOwnerNameValue(String name) {
    return 'मालक: $name';
  }

  @override
  String adminPhoneValue(String phone) {
    return 'फोन: $phone';
  }

  @override
  String get adminApprovalQueueClear => 'मंजुरी यादी रिकामी आहे!';

  @override
  String get adminAllRetailersVerified =>
      'सर्व नोंदणीकृत रिटेलर्स सत्यापित आहेत.';

  @override
  String adminOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ऑर्डर्स',
      one: '1 ऑर्डर',
    );
    return '$_temp0';
  }

  @override
  String get adminInactiveBadge => 'निष्क्रिय';

  @override
  String get adminEditTooltip => 'संपादित करा';

  @override
  String get adminDeleteTooltip => 'काढा';

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
    return 'कृती अयशस्वी: $error';
  }

  @override
  String get adminReject => 'नाकारा';

  @override
  String get adminApprove => 'मंजूर करा';

  @override
  String adminRejectedMessage(String name) {
    return '$name नाकारले गेले.';
  }

  @override
  String adminApprovedMessage(String name) {
    return '$name यशस्वीरित्या मंजूर झाले!';
  }
}
