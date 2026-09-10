import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/network/firebase_mode.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/entities/bank_details_entity.dart';
import '../../../domain/entities/business_hours_entity.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../models/notification_model.dart';

/// Companion to `demo_catalog_seeder.dart` — same versioned,
/// simulation-mode-only pattern, but for retailers/orders/notifications
/// instead of the product catalog. Without this, a fresh install's Admin
/// screens (Approval Queue, Retailers, All Orders, Dashboard stats) and the
/// retailer's own Order History/Notifications all start completely empty,
/// which reads as broken rather than just "new" during a demo.
///
/// Deliberately separate from the two special-cased `admin@jyoti.com` /
/// `retailer@jyoti.com` quick-login accounts in `FirebaseAuthRepository`
/// (`mock_admin_uid` / `mock_retailer_uid`) — those stay as they are; this
/// only adds *other* retailers/orders around them so the lists they browse
/// aren't empty either.
const int _kActivitySeedVersion = 1;

Future<void> seedDemoRetailersIfEmpty(Box userCacheBox) async {
  if (!_isSimulationMode()) return;

  final List<dynamic> existing = userCacheBox.get(
    HiveKeys.simulatedUsers,
    defaultValue: [],
  );
  final seededVersion =
      userCacheBox.get(HiveKeys.retailerSeedVersion, defaultValue: 0) as int;
  if (existing.isNotEmpty && seededVersion >= _kActivitySeedVersion) return;

  final now = DateTime.now();
  final retailers = <UserModel>[
    UserModel(
      uid: 'demo_retailer_sharma',
      name: 'Ramesh Sharma',
      email: 'ramesh@sharmastore.com',
      phone: '9876543210',
      role: UserRole.customer,
      status: UserStatus.approved,
      businessName: 'Sharma General Store',
      address: const AddressEntity(
        street: 'FC Road, Shop 3',
        city: 'Pune',
        pincode: '411004',
      ),
      gstNumber: '27ABCDE1234F1Z5',
      createdAt: now.subtract(const Duration(days: 60)),
      bankDetails: const BankDetailsEntity(
        accountHolderName: 'Ramesh Sharma',
        accountNumber: '00001234524521',
        ifscCode: 'HDFC0001234',
        bankName: 'HDFC Bank',
        upiId: 'ramesh@okhdfcbank',
      ),
      businessHours: const BusinessHoursEntity(
        openTime: '09:00',
        closeTime: '21:00',
      ),
    ),
    UserModel(
      uid: 'demo_retailer_patil',
      name: 'Sunil Patil',
      email: 'sunil.patil@example.com',
      phone: '9021122334',
      role: UserRole.customer,
      status: UserStatus.approved,
      businessName: 'Patil Kirana Store',
      address: const AddressEntity(
        street: 'Shivaji Nagar',
        city: 'Pune',
        pincode: '411005',
      ),
      gstNumber: '27PQRSX5678L1Z2',
      createdAt: now.subtract(const Duration(days: 45)),
      bankDetails: const BankDetailsEntity(
        accountHolderName: 'Sunil Patil',
        accountNumber: '00007789012389',
        ifscCode: 'IBKL0001122',
        bankName: 'Indian Bank',
      ),
      businessHours: const BusinessHoursEntity(
        openTime: '09:00',
        closeTime: '21:00',
      ),
    ),
    UserModel(
      uid: 'demo_retailer_modern',
      name: 'Anita Deshmukh',
      email: 'anita@moderntraders.com',
      phone: '9765432109',
      role: UserRole.customer,
      status: UserStatus.approved,
      businessName: 'Modern Traders',
      address: const AddressEntity(
        street: 'Kothrud Main Road, Shop 7',
        city: 'Pune',
        pincode: '411038',
      ),
      gstNumber: '27FGHIJ5678K2Y6',
      createdAt: now.subtract(const Duration(days: 30)),
      bankDetails: const BankDetailsEntity(
        accountHolderName: 'Anita Deshmukh',
        accountNumber: '00008832001188',
        ifscCode: 'ICIC0002345',
        bankName: 'ICICI Bank',
      ),
      businessHours: const BusinessHoursEntity(
        openTime: '08:00',
        closeTime: '20:00',
      ),
    ),
    UserModel(
      uid: 'demo_retailer_verma',
      name: 'Deepak Verma',
      email: 'deepak@vermawholesale.com',
      phone: '8899011223',
      role: UserRole.customer,
      status: UserStatus.pending,
      businessName: 'Verma Wholesale',
      address: const AddressEntity(
        street: 'Hadapsar Industrial Estate, A-12',
        city: 'Pune',
        pincode: '411028',
      ),
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    UserModel(
      uid: 'demo_retailer_nirmala',
      name: 'Nirmala Joshi',
      email: 'nirmala@gmail.com',
      phone: '9988776655',
      role: UserRole.customer,
      status: UserStatus.pending,
      businessName: 'Nirmala Provision Store',
      address: const AddressEntity(
        street: 'Deccan Gymkhana',
        city: 'Pune',
        pincode: '411004',
      ),
      createdAt: now.subtract(const Duration(days: 1)),
    ),
  ];

  await userCacheBox.put(HiveKeys.simulatedUsers, [
    ...existing,
    ...retailers.map((u) => u.toJson()),
  ]);
  await userCacheBox.put(HiveKeys.retailerSeedVersion, _kActivitySeedVersion);
  debugPrint('DemoActivitySeeder: seeded ${retailers.length} retailers.');
}

Future<void> seedDemoOrdersIfEmpty(Box ordersBox) async {
  if (!_isSimulationMode()) return;

  final List<dynamic> existing = ordersBox.get(
    HiveKeys.simulatedOrders,
    defaultValue: [],
  );
  final seededVersion =
      ordersBox.get(HiveKeys.orderSeedVersion, defaultValue: 0) as int;
  if (existing.isNotEmpty && seededVersion >= _kActivitySeedVersion) return;

  final now = DateTime.now();
  const ramAddress = AddressEntity(
    street: 'MG Road, Shop No. 9',
    city: 'Pune',
    pincode: '411001',
  );
  const sharmaAddress = AddressEntity(
    street: 'FC Road, Shop 3',
    city: 'Pune',
    pincode: '411004',
  );
  const patilAddress = AddressEntity(
    street: 'Shivaji Nagar',
    city: 'Pune',
    pincode: '411005',
  );
  const modernAddress = AddressEntity(
    street: 'Kothrud Main Road, Shop 7',
    city: 'Pune',
    pincode: '411038',
  );

  OrderItemModel item(
    String productId,
    String name,
    int qty,
    double unitPrice,
    String unit,
  ) {
    return OrderItemModel(
      productId: productId,
      name: name,
      qty: qty,
      unitPrice: unitPrice,
      unit: unit,
      totalPrice: unitPrice * qty,
    );
  }

  final orders = <OrderModel>[
    OrderModel(
      id: 'demo_order_1',
      userId: 'mock_retailer_uid',
      shopName: 'Ram Kirana Store',
      items: [
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
        item('prod_4', 'Pure Ghee 1L', 1, 620, 'piece'),
      ],
      subtotal: 2870,
      deliveryCharge: 80,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'pending',
      deliveryAddress: ramAddress,
      createdAt: now,
    ),
    OrderModel(
      id: 'demo_order_2',
      userId: 'demo_retailer_sharma',
      shopName: 'Sharma General Store',
      items: [
        item('prod_3', 'Fortune Soya Health Oil 15L Tin', 1, 1680, 'piece'),
        item('prod_7', 'Toor Dal 10kg', 1, 1150, 'box'),
      ],
      subtotal: 2830,
      deliveryCharge: 75,
      paymentMethod: 'upi',
      paymentStatus: 'paid',
      orderStatus: 'delivered',
      deliveryAddress: sharmaAddress,
      createdAt: now.subtract(const Duration(days: 6)),
    ),
    OrderModel(
      id: 'demo_order_3',
      userId: 'demo_retailer_sharma',
      shopName: 'Sharma General Store',
      items: [
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
        item('prod_9', 'Assorted Biscuits Box (24 pack)', 1, 580, 'box'),
      ],
      subtotal: 2830,
      deliveryCharge: 80,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'out_for_delivery',
      deliveryAddress: sharmaAddress,
      createdAt: now,
    ),
    OrderModel(
      id: 'demo_order_4',
      userId: 'demo_retailer_patil',
      shopName: 'Patil Kirana Store',
      items: [
        item('prod_2', 'Wheat Atta 10kg', 2, 480, 'box'),
        item('prod_4', 'Pure Ghee 1L', 2, 620, 'piece'),
        item('prod_9', 'Assorted Biscuits Box (24 pack)', 1, 580, 'box'),
      ],
      subtotal: 2780,
      deliveryCharge: 65,
      paymentMethod: 'upi',
      paymentStatus: 'payment_claimed',
      orderStatus: 'confirmed',
      deliveryAddress: patilAddress,
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    OrderModel(
      id: 'demo_order_5',
      userId: 'demo_retailer_modern',
      shopName: 'Modern Traders',
      items: [
        item('prod_3', 'Fortune Soya Health Oil 15L Tin', 2, 1680, 'piece'),
        item('prod_16', 'Sugar 25kg', 1, 1320, 'box'),
      ],
      subtotal: 4680,
      deliveryCharge: 90,
      paymentMethod: 'upi',
      paymentStatus: 'paid',
      orderStatus: 'confirmed',
      deliveryAddress: modernAddress,
      createdAt: now,
    ),
    OrderModel(
      id: 'demo_order_6',
      userId: 'mock_retailer_uid',
      shopName: 'Ram Kirana Store',
      items: [
        item('prod_7', 'Toor Dal 10kg', 1, 1150, 'box'),
        item('prod_2', 'Wheat Atta 10kg', 2, 480, 'box'),
        item('prod_9', 'Assorted Biscuits Box (24 pack)', 1, 580, 'box'),
      ],
      subtotal: 2690,
      deliveryCharge: 80,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'cancelled',
      deliveryAddress: ramAddress,
      createdAt: now.subtract(const Duration(days: 5)),
    ),
    OrderModel(
      id: 'demo_order_7',
      userId: 'demo_retailer_modern',
      shopName: 'Modern Traders',
      items: [
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
        item('prod_16', 'Sugar 25kg', 1, 1320, 'box'),
      ],
      subtotal: 3570,
      deliveryCharge: 90,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'delivered',
      deliveryAddress: modernAddress,
      createdAt: now.subtract(const Duration(days: 8)),
    ),
    OrderModel(
      id: 'demo_order_8',
      userId: 'demo_retailer_patil',
      shopName: 'Patil Kirana Store',
      items: [
        item('prod_3', 'Fortune Soya Health Oil 15L Tin', 1, 1680, 'piece'),
        item('prod_9', 'Assorted Biscuits Box (24 pack)', 2, 580, 'box'),
      ],
      subtotal: 2840,
      deliveryCharge: 65,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'pending',
      deliveryAddress: patilAddress,
      createdAt: now,
    ),
  ];

  await ordersBox.put(HiveKeys.simulatedOrders, [
    ...existing,
    ...orders.map((o) => o.toJson()),
  ]);
  await ordersBox.put(HiveKeys.orderSeedVersion, _kActivitySeedVersion);
  debugPrint('DemoActivitySeeder: seeded ${orders.length} orders.');
}

Future<void> seedDemoNotificationsIfEmpty(Box notificationsBox) async {
  if (!_isSimulationMode()) return;

  final List<dynamic> existing = notificationsBox.get(
    HiveKeys.notificationItems,
    defaultValue: [],
  );
  final seededVersion =
      notificationsBox.get(HiveKeys.notificationSeedVersion, defaultValue: 0)
          as int;
  if (existing.isNotEmpty && seededVersion >= _kActivitySeedVersion) return;

  final now = DateTime.now();
  final notifications = <NotificationModel>[
    NotificationModel(
      id: 'demo_notif_1',
      title: 'Order Confirmed',
      body: 'Your order #demo_order_5 has been confirmed by the admin.',
      orderId: 'demo_order_5',
      receivedAt: now.subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: 'demo_notif_2',
      title: 'Low Stock Alert',
      body: 'Toor Dal is running low on stock at Jyoti Traders.',
      receivedAt: now.subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    NotificationModel(
      id: 'demo_notif_3',
      title: 'Order Delivered',
      body: 'Order #demo_order_2 has been delivered to your store.',
      orderId: 'demo_order_2',
      receivedAt: now.subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: 'demo_notif_4',
      title: 'Welcome to Jyoti Traders',
      body: 'Your account has been approved. Start shopping now.',
      receivedAt: now.subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  // Newest-first, matching `NotificationLocalDatasource.addNotification`.
  final combined = [...notifications.map((n) => n.toJson()), ...existing];
  await notificationsBox.put(HiveKeys.notificationItems, combined);
  await notificationsBox.put(
    HiveKeys.notificationSeedVersion,
    _kActivitySeedVersion,
  );
  debugPrint(
    'DemoActivitySeeder: seeded ${notifications.length} notifications.',
  );
}

bool _isSimulationMode() {
  try {
    return isFirebasePlaceholder(fb.FirebaseAuth.instance.app);
  } catch (e) {
    return true;
  }
}
