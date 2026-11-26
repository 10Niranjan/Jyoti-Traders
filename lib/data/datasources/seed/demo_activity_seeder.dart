import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/network/firebase_mode.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/entities/bank_details_entity.dart';
import '../../../domain/entities/business_hours_entity.dart';
import '../../../core/utils/firestore_date_parser.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../models/notification_model.dart';
import '../../../domain/entities/notification_entity.dart';

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
const int _kActivitySeedVersion = 3;

Future<void> seedDemoRetailersIfEmpty(Box userCacheBox) async {
  if (!_isSimulationMode()) return;

  final List<dynamic> existing = userCacheBox.get(
    HiveKeys.simulatedUsers,
    defaultValue: [],
  );
  final seededVersion =
      userCacheBox.get(HiveKeys.retailerSeedVersion, defaultValue: 0) as int;
  if (existing.isNotEmpty && seededVersion >= _kActivitySeedVersion) return;
  // Only append entries this device doesn't already have (by uid) — on a
  // version bump `existing` is already populated from the prior seed, and
  // re-appending the whole literal list below would duplicate every one of
  // those rows instead of just adding the new ones.
  final existingUids = existing.map((e) => (e as Map)['uid'] as String).toSet();

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
    // Version 2: a longer signup history (for the retailer-growth chart) and
    // a bigger approval-queue backlog.
    UserModel(
      uid: 'demo_retailer_bhosale',
      name: 'Prakash Bhosale',
      email: 'prakash@bhosalemart.com',
      phone: '9822334455',
      role: UserRole.customer,
      status: UserStatus.approved,
      businessName: 'Bhosale Wholesale Mart',
      address: const AddressEntity(
        street: 'Hadapsar Gaothan',
        city: 'Pune',
        pincode: '411028',
      ),
      gstNumber: '27BHOSA1234M1Z8',
      createdAt: now.subtract(const Duration(days: 75)),
      bankDetails: const BankDetailsEntity(
        accountHolderName: 'Prakash Bhosale',
        accountNumber: '00009911002233',
        ifscCode: 'SBIN0001567',
        bankName: 'State Bank of India',
      ),
      businessHours: const BusinessHoursEntity(
        openTime: '08:30',
        closeTime: '21:30',
      ),
    ),
    UserModel(
      uid: 'demo_retailer_shaikh',
      name: 'Imran Shaikh',
      email: 'imran@shaikhbazaar.com',
      phone: '9112233445',
      role: UserRole.customer,
      status: UserStatus.approved,
      businessName: 'Shaikh Super Bazaar',
      address: const AddressEntity(
        street: 'Camp, East Street',
        city: 'Pune',
        pincode: '411001',
      ),
      gstNumber: '27SHAIK5678N1Z4',
      createdAt: now.subtract(const Duration(days: 20)),
      bankDetails: const BankDetailsEntity(
        accountHolderName: 'Imran Shaikh',
        accountNumber: '00002244668800',
        ifscCode: 'PUNB0001890',
        bankName: 'Punjab National Bank',
      ),
      businessHours: const BusinessHoursEntity(
        openTime: '09:00',
        closeTime: '22:00',
      ),
    ),
    UserModel(
      uid: 'demo_retailer_gaikwad',
      name: 'Vaibhav Gaikwad',
      email: 'vaibhav.gaikwad@example.com',
      phone: '9765123480',
      role: UserRole.customer,
      status: UserStatus.pending,
      businessName: 'Gaikwad Kirana',
      address: const AddressEntity(
        street: 'Baner Road',
        city: 'Pune',
        pincode: '411045',
      ),
      createdAt: now,
    ),
    UserModel(
      uid: 'demo_retailer_khan',
      name: 'Aslam Khan',
      email: 'aslam.khan@example.com',
      phone: '9898011224',
      role: UserRole.customer,
      status: UserStatus.pending,
      businessName: 'Khan Grocery Mart',
      address: const AddressEntity(
        street: 'Wakad Chowk',
        city: 'Pune',
        pincode: '411057',
      ),
      createdAt: now.subtract(const Duration(days: 3)),
    ),
  ];

  final newOnes = retailers.where((u) => !existingUids.contains(u.uid));
  await userCacheBox.put(HiveKeys.simulatedUsers, [
    ...existing,
    ...newOnes.map((u) => u.toJson()),
  ]);
  await userCacheBox.put(HiveKeys.retailerSeedVersion, _kActivitySeedVersion);
  debugPrint('DemoActivitySeeder: seeded ${newOnes.length} retailers.');
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
  final existingIds = existing.map((e) => (e as Map)['id'] as String).toSet();

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
  const bhosaleAddress = AddressEntity(
    street: 'Hadapsar Gaothan',
    city: 'Pune',
    pincode: '411028',
  );
  const shaikhAddress = AddressEntity(
    street: 'Camp, East Street',
    city: 'Pune',
    pincode: '411001',
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

  // Subtotal is always derived from the line items, never hand-typed — the
  // one thing every one of these demo orders must still satisfy honestly is
  // the real ₹2,500 checkout minimum (PlaceOrderUseCase), so a real order
  // history doesn't show something the app itself would have refused.
  double sum(List<OrderItemModel> items) =>
      items.fold(0.0, (s, i) => s + (i.totalPrice ?? i.unitPrice * i.qty));

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
    // Version 2: a month of spread-out activity across every status,
    // payment method and the 8 categories that had zero stock until the
    // catalog seeder's own version 5 — so the admin dashboard's charts
    // (last-7-days bar, category-revenue donut, status funnel,
    // week-over-week trend) and the retailer's own Buy Again rail /
    // low-stock nudge all have real numbers to show instead of a near-empty
    // demo. `mock_retailer_uid` repeats Rice/Ghee/Toor Dal/Wheat Atta/Tea
    // across several non-cancelled orders on purpose, to actually clear the
    // "bought ≥2 times" bar the Buy Again rail and stock-alert logic use.
    OrderModel(
      id: 'demo_order_9',
      userId: 'mock_retailer_uid',
      shopName: 'Ram Kirana Store',
      items: [
        item('prod_7', 'Toor Dal 10kg', 1, 1150, 'box'),
        item('prod_2', 'Wheat Atta 10kg', 2, 480, 'box'),
        item('prod_13', 'Tea Powder 1kg', 1, 420, 'kg'),
      ],
      subtotal: sum([
        item('prod_7', 'Toor Dal 10kg', 1, 1150, 'box'),
        item('prod_2', 'Wheat Atta 10kg', 2, 480, 'box'),
        item('prod_13', 'Tea Powder 1kg', 1, 420, 'kg'),
      ]),
      deliveryCharge: 70,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'delivered',
      deliveryAddress: ramAddress,
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    OrderModel(
      id: 'demo_order_10',
      userId: 'mock_retailer_uid',
      shopName: 'Ram Kirana Store',
      items: [
        item('prod_6', 'Red Chilli Powder 1kg', 2, 260, 'kg'),
        item('prod_13', 'Tea Powder 1kg', 2, 420, 'kg'),
        item('prod_10', 'Namkeen Mix 5kg', 2, 720, 'box'),
      ],
      subtotal: sum([
        item('prod_6', 'Red Chilli Powder 1kg', 2, 260, 'kg'),
        item('prod_13', 'Tea Powder 1kg', 2, 420, 'kg'),
        item('prod_10', 'Namkeen Mix 5kg', 2, 720, 'box'),
      ]),
      deliveryCharge: 60,
      paymentMethod: 'upi',
      paymentStatus: 'paid',
      orderStatus: 'delivered',
      deliveryAddress: ramAddress,
      createdAt: now.subtract(const Duration(days: 3)),
    ),
    OrderModel(
      id: 'demo_order_11',
      userId: 'mock_retailer_uid',
      shopName: 'Ram Kirana Store',
      items: [
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
        item('prod_4', 'Pure Ghee 1L', 1, 620, 'piece'),
      ],
      subtotal: sum([
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
        item('prod_4', 'Pure Ghee 1L', 1, 620, 'piece'),
      ]),
      deliveryCharge: 80,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'delivered',
      deliveryAddress: ramAddress,
      createdAt: now.subtract(const Duration(days: 7)),
    ),
    OrderModel(
      id: 'demo_order_12',
      userId: 'demo_retailer_sharma',
      shopName: 'Sharma General Store',
      items: [
        item('prod_17', 'Chyawanprash 1kg', 2, 320, 'piece'),
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
      ],
      subtotal: sum([
        item('prod_17', 'Chyawanprash 1kg', 2, 320, 'piece'),
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
      ]),
      deliveryCharge: 80,
      paymentMethod: 'upi',
      paymentStatus: 'paid',
      orderStatus: 'confirmed',
      deliveryAddress: sharmaAddress,
      createdAt: now.subtract(const Duration(days: 4)),
    ),
    OrderModel(
      id: 'demo_order_13',
      userId: 'demo_retailer_patil',
      shopName: 'Patil Kirana Store',
      items: [
        item('prod_19', 'LED Bulb 9W (Pack of 2)', 2, 150, 'piece'),
        item('prod_20', 'Extension Board 4-Socket', 1, 320, 'piece'),
        item('prod_7', 'Toor Dal 10kg', 1, 1150, 'box'),
        item('prod_2', 'Wheat Atta 10kg', 2, 480, 'box'),
      ],
      subtotal: sum([
        item('prod_19', 'LED Bulb 9W (Pack of 2)', 2, 150, 'piece'),
        item('prod_20', 'Extension Board 4-Socket', 1, 320, 'piece'),
        item('prod_7', 'Toor Dal 10kg', 1, 1150, 'box'),
        item('prod_2', 'Wheat Atta 10kg', 2, 480, 'box'),
      ]),
      deliveryCharge: 70,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'delivered',
      deliveryAddress: patilAddress,
      createdAt: now.subtract(const Duration(days: 10)),
    ),
    OrderModel(
      id: 'demo_order_14',
      userId: 'demo_retailer_modern',
      shopName: 'Modern Traders',
      items: [
        item('prod_21', 'Anti-Dandruff Shampoo 340ml', 2, 210, 'piece'),
        item('prod_22', 'Herbal Shampoo 650ml', 1, 280, 'piece'),
        item('prod_3', 'Fortune Soya Health Oil 15L Tin', 1, 1680, 'piece'),
        item('prod_14', 'Instant Coffee 200g', 1, 340, 'piece'),
      ],
      subtotal: sum([
        item('prod_21', 'Anti-Dandruff Shampoo 340ml', 2, 210, 'piece'),
        item('prod_22', 'Herbal Shampoo 650ml', 1, 280, 'piece'),
        item('prod_3', 'Fortune Soya Health Oil 15L Tin', 1, 1680, 'piece'),
        item('prod_14', 'Instant Coffee 200g', 1, 340, 'piece'),
      ]),
      deliveryCharge: 90,
      paymentMethod: 'upi',
      paymentStatus: 'payment_claimed',
      orderStatus: 'out_for_delivery',
      deliveryAddress: modernAddress,
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    OrderModel(
      id: 'demo_order_15',
      userId: 'mock_retailer_uid',
      shopName: 'Ram Kirana Store',
      items: [
        item('prod_23', 'Kattha (Catechu) 500g', 2, 140, 'piece'),
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
      ],
      subtotal: sum([
        item('prod_23', 'Kattha (Catechu) 500g', 2, 140, 'piece'),
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
      ]),
      deliveryCharge: 70,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'pending',
      deliveryAddress: ramAddress,
      createdAt: now,
    ),
    OrderModel(
      id: 'demo_order_16',
      userId: 'demo_retailer_sharma',
      shopName: 'Sharma General Store',
      items: [
        item('prod_25', 'Sparklers Box (10 pcs)', 2, 150, 'box'),
        item('prod_26', 'Flower Pots (Anar) Pack of 5', 1, 350, 'box'),
        item('prod_16', 'Sugar 25kg', 1, 1320, 'box'),
        item('prod_11', 'Detergent Powder 5kg', 1, 540, 'box'),
      ],
      subtotal: sum([
        item('prod_25', 'Sparklers Box (10 pcs)', 2, 150, 'box'),
        item('prod_26', 'Flower Pots (Anar) Pack of 5', 1, 350, 'box'),
        item('prod_16', 'Sugar 25kg', 1, 1320, 'box'),
        item('prod_11', 'Detergent Powder 5kg', 1, 540, 'box'),
      ]),
      deliveryCharge: 75,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'delivered',
      deliveryAddress: sharmaAddress,
      createdAt: now.subtract(const Duration(days: 15)),
    ),
    OrderModel(
      id: 'demo_order_17',
      userId: 'demo_retailer_patil',
      shopName: 'Patil Kirana Store',
      items: [
        item('prod_27', 'Nylon Rope 50m', 2, 220, 'piece'),
        item('prod_28', 'Cotton Thread Spool (Suut) Pack of 10', 1, 180, 'box'),
        item('prod_7', 'Toor Dal 10kg', 2, 1150, 'box'),
      ],
      subtotal: sum([
        item('prod_27', 'Nylon Rope 50m', 2, 220, 'piece'),
        item('prod_28', 'Cotton Thread Spool (Suut) Pack of 10', 1, 180, 'box'),
        item('prod_7', 'Toor Dal 10kg', 2, 1150, 'box'),
      ]),
      deliveryCharge: 65,
      paymentMethod: 'upi',
      paymentStatus: 'paid',
      orderStatus: 'delivered',
      deliveryAddress: patilAddress,
      createdAt: now.subtract(const Duration(days: 20)),
    ),
    OrderModel(
      id: 'demo_order_18',
      userId: 'demo_retailer_modern',
      shopName: 'Modern Traders',
      items: [
        item('prod_29', 'Suhana Garam Masala 500g', 2, 160, 'piece'),
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
      ],
      subtotal: sum([
        item('prod_29', 'Suhana Garam Masala 500g', 2, 160, 'piece'),
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
      ]),
      deliveryCharge: 90,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'cancelled',
      deliveryAddress: modernAddress,
      createdAt: now.subtract(const Duration(days: 25)),
    ),
    OrderModel(
      id: 'demo_order_19',
      userId: 'demo_retailer_bhosale',
      shopName: 'Bhosale Wholesale Mart',
      items: [
        item('prod_16', 'Sugar 25kg', 1, 1320, 'box'),
        item('prod_12', 'Bathing Soap (72 pack)', 1, 860, 'box'),
        item('prod_11', 'Detergent Powder 5kg', 1, 540, 'box'),
      ],
      subtotal: sum([
        item('prod_16', 'Sugar 25kg', 1, 1320, 'box'),
        item('prod_12', 'Bathing Soap (72 pack)', 1, 860, 'box'),
        item('prod_11', 'Detergent Powder 5kg', 1, 540, 'box'),
      ]),
      deliveryCharge: 85,
      paymentMethod: 'upi',
      paymentStatus: 'paid',
      orderStatus: 'confirmed',
      deliveryAddress: bhosaleAddress,
      createdAt: now.subtract(const Duration(days: 5)),
    ),
    OrderModel(
      id: 'demo_order_20',
      userId: 'demo_retailer_shaikh',
      shopName: 'Shaikh Super Bazaar',
      items: [
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
        item('prod_3', 'Fortune Soya Health Oil 15L Tin', 1, 1680, 'piece'),
      ],
      subtotal: sum([
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
        item('prod_3', 'Fortune Soya Health Oil 15L Tin', 1, 1680, 'piece'),
      ]),
      deliveryCharge: 95,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'pending',
      deliveryAddress: shaikhAddress,
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    OrderModel(
      id: 'demo_order_21',
      userId: 'mock_retailer_uid',
      shopName: 'Ram Kirana Store',
      items: [
        item('prod_7', 'Toor Dal 10kg', 1, 1150, 'box'),
        item('prod_2', 'Wheat Atta 10kg', 2, 480, 'box'),
        item('prod_4', 'Pure Ghee 1L', 1, 620, 'piece'),
      ],
      subtotal: sum([
        item('prod_7', 'Toor Dal 10kg', 1, 1150, 'box'),
        item('prod_2', 'Wheat Atta 10kg', 2, 480, 'box'),
        item('prod_4', 'Pure Ghee 1L', 1, 620, 'piece'),
      ]),
      deliveryCharge: 80,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'delivered',
      deliveryAddress: ramAddress,
      createdAt: now.subtract(const Duration(days: 12)),
    ),
    OrderModel(
      id: 'demo_order_22',
      userId: 'demo_retailer_sharma',
      shopName: 'Sharma General Store',
      items: [
        item('prod_3', 'Fortune Soya Health Oil 15L Tin', 1, 1680, 'piece'),
        item('prod_7', 'Toor Dal 10kg', 1, 1150, 'box'),
      ],
      subtotal: sum([
        item('prod_3', 'Fortune Soya Health Oil 15L Tin', 1, 1680, 'piece'),
        item('prod_7', 'Toor Dal 10kg', 1, 1150, 'box'),
      ]),
      deliveryCharge: 75,
      paymentMethod: 'upi',
      paymentStatus: 'payment_claimed',
      orderStatus: 'out_for_delivery',
      deliveryAddress: sharmaAddress,
      createdAt: now,
    ),
    OrderModel(
      id: 'demo_order_23',
      userId: 'demo_retailer_modern',
      shopName: 'Modern Traders',
      items: [
        item('prod_16', 'Sugar 25kg', 1, 1320, 'box'),
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
      ],
      subtotal: sum([
        item('prod_16', 'Sugar 25kg', 1, 1320, 'box'),
        item('prod_1', 'Basmati Rice Premium 25kg', 1, 2250, 'box'),
      ]),
      deliveryCharge: 90,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      orderStatus: 'delivered',
      deliveryAddress: modernAddress,
      createdAt: now.subtract(const Duration(days: 30)),
    ),
  ];

  final newOnes = orders.where((o) => !existingIds.contains(o.id));
  await ordersBox.put(HiveKeys.simulatedOrders, [
    ...existing,
    ...newOnes.map((o) => o.toJson()),
  ]);
  await ordersBox.put(HiveKeys.orderSeedVersion, _kActivitySeedVersion);
  debugPrint('DemoActivitySeeder: seeded ${newOnes.length} orders.');
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
  final existingIds = existing.map((e) => (e as Map)['id'] as String).toSet();

  final now = DateTime.now();
  final notifications = <NotificationModel>[
    NotificationModel(
      id: 'demo_notif_1',
      title: 'Order Confirmed',
      body: 'Your order #demo_order_5 has been confirmed by the admin.',
      orderId: 'demo_order_5',
      kind: NotificationKind.order,
      receivedAt: now.subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: 'demo_notif_2',
      title: 'Low Stock Alert',
      body: 'Toor Dal is running low on stock at Jyoti Kirana Store.',
      kind: NotificationKind.stock,
      receivedAt: now.subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    NotificationModel(
      id: 'demo_notif_3',
      title: 'Order Delivered',
      body: 'Order #demo_order_2 has been delivered to your store.',
      orderId: 'demo_order_2',
      kind: NotificationKind.order,
      receivedAt: now.subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: 'demo_notif_4',
      title: 'Welcome to Jyoti Kirana Store',
      body: 'Your account has been approved. Start shopping now.',
      receivedAt: now.subtract(const Duration(days: 3)),
      isRead: true,
    ),
    // Version 2: a few more, tied to the richer order history above.
    NotificationModel(
      id: 'demo_notif_5',
      title: 'Out for Delivery',
      body: 'Order #demo_order_14 is out for delivery.',
      orderId: 'demo_order_14',
      kind: NotificationKind.order,
      receivedAt: now.subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationModel(
      id: 'demo_notif_6',
      title: 'Diwali Offer',
      body: '10% off on Firecrackers and Suhana Masala this week only!',
      kind: NotificationKind.broadcast,
      receivedAt: now.subtract(const Duration(hours: 8)),
      isRead: false,
    ),
    NotificationModel(
      id: 'demo_notif_7',
      title: 'Payment Received',
      body: 'Payment for order #demo_order_17 has been confirmed.',
      orderId: 'demo_order_17',
      kind: NotificationKind.order,
      receivedAt: now.subtract(const Duration(days: 20)),
      isRead: true,
    ),
    // Version 3: a fuller inbox for demo builds.
    NotificationModel(
      id: 'demo_notif_8',
      title: 'New arrivals: Suhana Masala',
      body: 'Pav Bhaji, Misal and Kanda Lasun masala are now in stock.',
      kind: NotificationKind.broadcast,
      receivedAt: now.subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    NotificationModel(
      id: 'demo_notif_9',
      title: 'Low Stock Alert',
      body: 'Kabuli Chana has only 2 kg left — order soon.',
      kind: NotificationKind.stock,
      receivedAt: now.subtract(const Duration(hours: 3)),
      isRead: false,
    ),
    NotificationModel(
      id: 'demo_notif_10',
      title: 'Order Confirmed',
      body: 'Order #demo_order_19 has been confirmed and is being packed.',
      orderId: 'demo_order_19',
      kind: NotificationKind.order,
      receivedAt: now.subtract(const Duration(days: 2)),
      isRead: true,
    ),
    NotificationModel(
      id: 'demo_notif_11',
      title: 'Use coupon WELCOME10',
      body: 'Get 10% off (up to ₹250) on orders above ₹2,500.',
      kind: NotificationKind.broadcast,
      receivedAt: now.subtract(const Duration(days: 4)),
      isRead: true,
    ),
    NotificationModel(
      id: 'demo_notif_12',
      title: 'Order Cancelled',
      body: 'Order #demo_order_18 was cancelled and the stock returned.',
      orderId: 'demo_order_18',
      kind: NotificationKind.order,
      receivedAt: now.subtract(const Duration(days: 6)),
      isRead: true,
    ),
  ];

  final newOnes = notifications.where((n) => !existingIds.contains(n.id));
  // Newest-first, matching `NotificationLocalDatasource.addNotification`.
  final combined = [...newOnes.map((n) => n.toJson()), ...existing];
  await notificationsBox.put(HiveKeys.notificationItems, combined);
  await notificationsBox.put(
    HiveKeys.notificationSeedVersion,
    _kActivitySeedVersion,
  );
  debugPrint('DemoActivitySeeder: seeded ${newOnes.length} notifications.');
}

bool _isSimulationMode() {
  try {
    return isFirebasePlaceholder(fb.FirebaseAuth.instance.app);
  } catch (e) {
    return true;
  }
}

/// Keeps the demo orders "fresh": the seed stamps its newest orders with the
/// install-time `now`, so a day later Today's Orders/Revenue read zero. Each
/// launch shifts every `demo_order_*` forward by the whole days since the
/// anchor (the newest demo order's date, or the last shift), preserving every
/// order's offset from "today".
Future<void> redateDemoOrders(Box ordersBox) async {
  if (!_isSimulationMode()) return;
  final List<dynamic> existing = ordersBox.get(
    HiveKeys.simulatedOrders,
    defaultValue: [],
  );
  bool isDemo(dynamic e) =>
      ((e as Map)['id'] as String).startsWith('demo_order_');
  DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
  final demo = existing.where(isDemo).toList();
  if (demo.isEmpty) return;

  final today = day(DateTime.now());
  final stored = ordersBox.get('demo_orders_anchor') as String?;
  final anchor = stored != null
      ? day(DateTime.parse(stored))
      : day(
          demo
              .map((e) => parseFirestoreDate((e as Map)['createdAt']))
              .reduce((a, b) => a.isAfter(b) ? a : b),
        );
  final shift = today.difference(anchor);
  if (shift.inDays > 0) {
    final shifted = existing.map((e) {
      if (!isDemo(e)) return e;
      final m = Map<String, dynamic>.from(e as Map);
      m['createdAt'] = parseFirestoreDate(m['createdAt']).add(shift);
      return m;
    }).toList();
    await ordersBox.put(HiveKeys.simulatedOrders, shifted);
  }
  await ordersBox.put('demo_orders_anchor', today.toIso8601String());
}
