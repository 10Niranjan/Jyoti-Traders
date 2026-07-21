import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/firestore_date_parser.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/value_objects/money.dart';

class OrderItemModel {
  final String productId;
  final String name;
  final int qty;
  final double unitPrice;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      qty: json['qty'] as int? ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'qty': qty,
      'unitPrice': unitPrice,
      'totalPrice': unitPrice * qty,
    };
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(productId: productId, name: name, qty: qty, unitPrice: Money(unitPrice));
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      productId: entity.productId,
      name: entity.name,
      qty: entity.qty,
      unitPrice: entity.unitPrice.amount,
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String shopName;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryCharge;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final AddressEntity deliveryAddress;
  final String? notes;
  final DateTime createdAt;

  OrderModel({
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
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return OrderModel._fromJson(doc.id, doc.data() ?? {});
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel._fromJson(json['id'] as String? ?? '', json);
  }

  static OrderModel _fromJson(String id, Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>? ?? []);
    final addressMap = Map<String, dynamic>.from(json['deliveryAddress'] as Map? ?? {});

    return OrderModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      shopName: json['shopName'] as String? ?? '',
      items: itemsJson
          .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? 'cod',
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      orderStatus: json['orderStatus'] as String? ?? 'pending',
      deliveryAddress: AddressEntity(
        street: addressMap['street'] as String? ?? '',
        city: addressMap['city'] as String? ?? '',
        pincode: addressMap['pincode'] as String? ?? '',
      ),
      notes: json['notes'] as String?,
      createdAt: parseFirestoreDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'shopName': shopName,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryCharge': deliveryCharge,
      'grandTotal': subtotal + deliveryCharge,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'deliveryAddress': {
        'street': deliveryAddress.street,
        'city': deliveryAddress.city,
        'pincode': deliveryAddress.pincode,
      },
      'notes': notes,
      // Plain DateTime, not Timestamp.fromDate() — see note in user_model.dart.
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() => {'id': id, ...toFirestore()};

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      userId: userId,
      shopName: shopName,
      items: items.map((e) => e.toEntity()).toList(),
      subtotal: Money(subtotal),
      deliveryCharge: Money(deliveryCharge),
      paymentMethod: PaymentMethod.fromString(paymentMethod),
      paymentStatus: PaymentStatus.fromString(paymentStatus),
      orderStatus: OrderStatus.fromString(orderStatus),
      deliveryAddress: deliveryAddress,
      notes: notes,
      createdAt: createdAt,
    );
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      shopName: entity.shopName,
      items: entity.items.map((e) => OrderItemModel.fromEntity(e)).toList(),
      subtotal: entity.subtotal.amount,
      deliveryCharge: entity.deliveryCharge.amount,
      paymentMethod: entity.paymentMethod.value,
      paymentStatus: entity.paymentStatus.value,
      orderStatus: entity.orderStatus.value,
      deliveryAddress: entity.deliveryAddress,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}
