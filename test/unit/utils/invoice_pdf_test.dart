import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/utils/invoice_pdf.dart';
import 'package:traders_retailer/domain/entities/address_entity.dart';
import 'package:traders_retailer/domain/entities/order_entity.dart';
import 'package:traders_retailer/domain/entities/order_item_entity.dart';
import 'package:traders_retailer/domain/entities/product_entity.dart';
import 'package:traders_retailer/domain/value_objects/money.dart';

OrderEntity _order({
  String shopName = 'Ramesh Kirana Store',
  List<OrderItemEntity>? items,
  Money? discount,
  String? couponCode,
}) => OrderEntity(
  id: 'abcdef12-3456-7890-abcd-ef1234567890',
  userId: 'u1',
  shopName: shopName,
  items:
      items ??
      [
        OrderItemEntity(
          productId: 'dal',
          name: 'Toor Dal',
          qty: 2500,
          unitPrice: Money(39),
          unit: ProductUnit.kg,
          lineTotal: Money(97.5),
        ),
        OrderItemEntity(
          productId: 'oil',
          name: 'Sunflower Oil 15L',
          qty: 3,
          unitPrice: Money(1800),
          unit: ProductUnit.box,
          lineTotal: Money(5400),
        ),
        // Placed before slab pricing existed: no unit, no frozen total.
        OrderItemEntity(
          productId: 'old',
          name: 'Sugar 50kg',
          qty: 2,
          unitPrice: Money(2100),
        ),
      ],
  subtotal: Money(5497.5 + 4200),
  deliveryCharge: Money(120),
  paymentMethod: PaymentMethod.upi,
  paymentStatus: PaymentStatus.paid,
  orderStatus: OrderStatus.confirmed,
  deliveryAddress: const AddressEntity(
    street: '12 Market Road',
    city: 'Nagpur',
    pincode: '440001',
  ),
  createdAt: DateTime(2026, 9, 19, 10, 30),
  couponCode: couponCode,
  discount: discount,
);

/// Every PDF page dictionary carries `/Type /Page` (the page tree is `/Pages`).
int _pageCount(Uint8List pdf) => RegExp(
  r'/Type\s*/Page(?![a-z])',
).allMatches(latin1.decode(pdf, allowInvalid: true)).length;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'builds a valid PDF for a mixed weighed / per-unit / legacy order',
    () async {
      final pdf = await buildInvoicePdf(
        _order(),
        buyerGstin: '27ABCDE1234F1Z5',
      );

      expect(latin1.decode(pdf.sublist(0, 5)), '%PDF-');
      expect(
        latin1.decode(pdf.sublist(pdf.length - 6), allowInvalid: true),
        contains('%%EOF'),
      );
      expect(_pageCount(pdf), 1);
    },
  );

  test('a Devanagari shop name does not break generation', () async {
    final pdf = await buildInvoicePdf(
      _order(shopName: 'श्री गणेश किराणा स्टोअर'),
    );
    expect(latin1.decode(pdf.sublist(0, 5)), '%PDF-');
  });

  test('a discounted order still builds', () async {
    final pdf = await buildInvoicePdf(
      _order(discount: Money(250), couponCode: 'WELCOME10'),
    );
    expect(latin1.decode(pdf.sublist(0, 5)), '%PDF-');
  });

  test(
    'a long order flows onto more than one page instead of clipping',
    () async {
      final many = [
        for (var i = 0; i < 80; i++)
          OrderItemEntity(
            productId: 'p$i',
            name: 'Product number $i',
            qty: 1,
            unitPrice: Money(100),
          ),
      ];
      final pdf = await buildInvoicePdf(_order(items: many));
      expect(_pageCount(pdf), greaterThan(1));
    },
  );
}
