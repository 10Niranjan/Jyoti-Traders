import 'package:equatable/equatable.dart';
import 'address_entity.dart';
import 'order_item_entity.dart';
import '../../core/constants/app_constants.dart';
import '../value_objects/money.dart';

enum PaymentMethod {
  cod,
  upi;

  String get value => name;

  static PaymentMethod fromString(String method) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name.toLowerCase() == method.toLowerCase(),
      orElse: () => PaymentMethod.cod,
    );
  }
}

enum PaymentStatus {
  pending,

  /// The retailer tapped "I have paid" on the UPI screen — awaiting the
  /// admin's manual confirmation. Never set for COD orders.
  paymentClaimed,
  paid;

  String get value =>
      this == PaymentStatus.paymentClaimed ? 'payment_claimed' : name;

  static PaymentStatus fromString(String status) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum OrderStatus {
  pending,
  confirmed,
  outForDelivery,
  delivered,

  /// Retailer self-cancelled within the cancellation window — see
  /// [OrderEntity.isCancellable]. Never set for an order past that window.
  cancelled;

  /// Matches the exact Firestore schema strings from `ARCHITECTURE.md` §5
  /// (snake_case), not the Dart enum identifier.
  String get value =>
      this == OrderStatus.outForDelivery ? 'out_for_delivery' : name;

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => OrderStatus.pending,
    );
  }
}

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final String shopName;
  final List<OrderItemEntity> items;
  final Money subtotal;
  final Money deliveryCharge;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final OrderStatus orderStatus;
  final AddressEntity deliveryAddress;
  final String? notes;
  final String? paymentScreenshotUrl;
  final DateTime createdAt;

  /// Absent on every order placed before the coupon feature shipped, and on
  /// any order with no coupon applied.
  final String? couponCode;
  final Money? discount;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.shopName,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.deliveryAddress,
    this.notes,
    this.paymentScreenshotUrl,
    required this.createdAt,
    this.couponCode,
    this.discount,
  });

  Money get grandTotal => subtotal - (discount ?? Money.zero) + deliveryCharge;

  /// True while the retailer can still self-cancel: still `pending` (the
  /// admin hasn't acted on it yet) and within the cancellation window.
  bool get isCancellable =>
      orderStatus == OrderStatus.pending &&
      DateTime.now().difference(createdAt) <
          const Duration(minutes: AppConstants.kOrderCancellationWindowMinutes);

  @override
  List<Object?> get props => [
    id,
    userId,
    shopName,
    items,
    subtotal,
    deliveryCharge,
    paymentMethod,
    paymentStatus,
    orderStatus,
    deliveryAddress,
    notes,
    paymentScreenshotUrl,
    createdAt,
    couponCode,
    discount,
  ];
}
