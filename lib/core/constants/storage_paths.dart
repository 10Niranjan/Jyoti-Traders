/// Firebase Storage folder constants — kept separate from
/// [FirestorePaths] since Storage buckets and Firestore collections are
/// different namespaces that happen to use similar-looking names.
class StoragePaths {
  StoragePaths._();

  static const String productImages = 'product_images';

  static String productImage(String productId) => '$productImages/$productId.jpg';
}
