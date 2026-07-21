import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository_provider.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/order_item_entity.dart';
import '../../../domain/value_objects/money.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/auth_state.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _prefillAddress(AddressEntity? address) {
    if (_prefilled || address == null) return;
    _streetController.text = address.street;
    _cityController.text = address.city;
    _pincodeController.text = address.pincode;
    _prefilled = true;
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authControllerProvider);
    if (authState is! AuthenticatedCustomer) return;
    final user = authState.user;

    final address = AddressEntity(
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      pincode: _pincodeController.text.trim(),
    );

    // Persist the address to the profile too, so it's pre-filled next time.
    await ref.read(authRepositoryProvider).updateProfile(uid: user.uid, address: address);

    final cart = ref.read(cartControllerProvider);
    final order = OrderEntity(
      id: const Uuid().v4(),
      userId: user.uid,
      shopName: user.businessName,
      items: cart.items
          .map((i) => OrderItemEntity(productId: i.productId, name: i.name, qty: i.qty, unitPrice: i.unitPrice))
          .toList(),
      subtotal: cart.subtotal,
      deliveryCharge: Money(AppConstants.kStubDeliveryCharge),
      paymentMethod: PaymentMethod.cod,
      paymentStatus: PaymentStatus.pending,
      orderStatus: OrderStatus.pending,
      deliveryAddress: address,
      createdAt: DateTime.now(),
    );

    await ref.read(checkoutControllerProvider.notifier).placeOrder(order);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final cart = ref.watch(cartControllerProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);

    if (authState is AuthenticatedCustomer) {
      _prefillAddress(authState.user.address);
    }

    ref.listen<AsyncValue<String?>>(checkoutControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (orderId) {
          if (orderId != null) context.pushReplacement(RouteNames.orderSuccessPath(orderId));
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString()), backgroundColor: AppColors.error),
          );
        },
      );
    });

    final grandTotal = cart.subtotal + Money(AppConstants.kStubDeliveryCharge);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery Address', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Street / Shop Address'),
                validator: Validators.address,
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (v) => Validators.required(v, fieldName: 'City'),
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                validator: (v) => Validators.required(v, fieldName: 'Pincode'),
              ),
              const SizedBox(height: 24),
              Text('Payment Method', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.payments_outlined, color: AppColors.primary),
                title: Text('Cash on Delivery (COD)'),
                trailing: Icon(Icons.check_circle, color: AppColors.success),
              ),
              const SizedBox(height: 24),
              Text('Order Summary', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _SummaryRow(label: 'Subtotal (${cart.items.length} items)', value: cart.subtotal.formatted),
              _SummaryRow(
                label: 'Delivery Charge (estimated)',
                value: Money(AppConstants.kStubDeliveryCharge).formatted,
              ),
              const Divider(),
              _SummaryRow(label: 'Grand Total', value: grandTotal.formatted, bold: true),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Place Order',
                icon: Icons.check_circle_outline_rounded,
                isLoading: checkoutState.isLoading,
                onPressed: _placeOrder,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(fontSize: bold ? 15 : 13, fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
