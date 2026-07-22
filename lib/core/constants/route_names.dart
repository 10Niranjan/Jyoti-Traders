/// GoRouter path constants — routes are contractual, do not change without approval.
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String pendingApproval = '/pending-approval';
  static const String home = '/home';
  static const String admin = '/admin';
  static const String adminApprovalQueue = '/admin/approval-queue';

  // Retailer bottom-nav tabs (Phase 3)
  static const String search = '/search';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';

  // Retailer push routes (Phase 3)
  static const String productCategory = '/product-category/:categoryId';
  static const String productDetail = '/product/:productId';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success/:orderId';
  static const String orderDetail = '/order/:orderId';

  static String productCategoryPath(String categoryId) => '/product-category/$categoryId';
  static String productDetailPath(String productId) => '/product/$productId';
  static String orderSuccessPath(String orderId) => '/order-success/$orderId';
  static String orderDetailPath(String orderId) => '/order/$orderId';
}
