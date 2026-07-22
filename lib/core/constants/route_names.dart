/// GoRouter path constants — routes are contractual, do not change without approval.
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String pendingApproval = '/pending-approval';
  static const String home = '/home';
  static const String admin = '/admin';
  static const String adminApprovalQueue = '/admin/approval-queue';
  static const String adminProducts = '/admin/products';
  static const String adminAddProduct = '/admin/products/new';
  static const String adminEditProduct = '/admin/products/:productId/edit';
  static const String adminCategories = '/admin/categories';
  static const String adminAddCategory = '/admin/categories/new';
  static const String adminEditCategory = '/admin/categories/:categoryId/edit';
  static const String adminOrders = '/admin/orders';
  static const String adminOrderManagement = '/admin/orders/:orderId';
  static const String adminRetailers = '/admin/retailers';
  static const String adminRetailerOrders = '/admin/retailers/:retailerId/orders';

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

  static String adminEditProductPath(String productId) => '/admin/products/$productId/edit';
  static String adminEditCategoryPath(String categoryId) => '/admin/categories/$categoryId/edit';
  static String adminOrderManagementPath(String orderId) => '/admin/orders/$orderId';
  static String adminRetailerOrdersPath(String retailerId) => '/admin/retailers/$retailerId/orders';

  static String productCategoryPath(String categoryId) => '/product-category/$categoryId';
  static String productDetailPath(String productId) => '/product/$productId';
  static String orderSuccessPath(String orderId) => '/order-success/$orderId';
  static String orderDetailPath(String orderId) => '/order/$orderId';
}
