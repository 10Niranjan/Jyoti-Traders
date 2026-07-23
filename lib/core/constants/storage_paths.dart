/// Firebase Storage folder constants — kept separate from
/// [FirestorePaths] since Storage buckets and Firestore collections are
/// different namespaces that happen to use similar-looking names.
class StoragePaths {
  StoragePaths._();

  static const String productImages = 'product_images';
  static const String categoryIcons = 'category_icons';
  static const String paymentScreenshots = 'payment_screenshots';

  static String productImage(String productId) => '$productImages/$productId.jpg';

  static String categoryIcon(String categoryId) => '$categoryIcons/$categoryId.jpg';

  static String paymentScreenshot(String orderId) => '$paymentScreenshots/$orderId.jpg';
}
