import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/services/location_service.dart';
import '../../../data/repositories/auth_repository_provider.dart';
import '../../../domain/entities/address_entity.dart';
import '../../../domain/entities/delivery_config_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/order_item_entity.dart';
import '../../../domain/usecases/delivery/calculate_delivery_charge_usecase.dart';
import '../../../domain/value_objects/money.dart';
import '../../../shared/widgets/address_form_fields.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/summary_row.dart';
import '../../../l10n/app_localizations.dart';
import '../../admin/controllers/admin_delivery_config_controller.dart';
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
  double? _latitude;
  double? _longitude;
  String? _resolvedAddress;
  bool _isLocating = false;
  PaymentMethod _paymentMethod = PaymentMethod.cod;

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
    _latitude = address.latitude;
    _longitude = address.longitude;
    _resolvedAddress = address.formattedAddress;
    _prefilled = true;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    final position = await ref.read(locationServiceProvider).getCurrentPosition();
    if (!mounted) return;
    if (position == null) {
      setState(() => _isLocating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.checkoutLocationError),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final resolved = await ref.read(geocodingServiceProvider).reverseGeocode(
          latitude: position.latitude,
          longitude: position.longitude,
        );
    if (!mounted) return;
    setState(() {
      _isLocating = false;
      _latitude = position.latitude;
      _longitude = position.longitude;
      if (resolved != null) {
        _resolvedAddress = resolved.formattedAddress;
        if (_streetController.text.trim().isEmpty && resolved.street != null) {
          _streetController.text = resolved.street!;
        }
        if (_cityController.text.trim().isEmpty && resolved.city != null) {
          _cityController.text = resolved.city!;
        }
        if (_pincodeController.text.trim().isEmpty && resolved.pincode != null) {
          _pincodeController.text = resolved.pincode!;
        }
      }
    });
  }

  AddressEntity _currentAddress() => AddressEntity(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        formattedAddress: _resolvedAddress,
      );

  /// Real per-km charge once the address has coordinates and the delivery
  /// config has loaded; otherwise the flat placeholder — rules.md §10
  /// requires a delivery charge is always calculated and shown, never left
  /// blank while waiting on either.
  Money _deliveryChargeFor(AddressEntity address, DeliveryConfigEntity? config) {
    if (config == null) return Money(AppConstants.kStubDeliveryCharge);
    return CalculateDeliveryChargeUseCase()(config: config, address: address) ??
        Money(AppConstants.kStubDeliveryCharge);
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authControllerProvider);
    if (authState is! AuthenticatedCustomer) return;
    final user = authState.user;

    final address = _currentAddress();

    // Persist the address to the profile too, so it's pre-filled next time.
    await ref.read(authRepositoryProvider).updateProfile(uid: user.uid, address: address);

    final config = ref.read(deliveryConfigProvider).valueOrNull;
    final cart = ref.read(cartControllerProvider);
    final order = OrderEntity(
      id: const Uuid().v4(),
      userId: user.uid,
      shopName: user.businessName,
      items: cart.items
          .map((i) => OrderItemEntity(
                productId: i.productId,
                name: i.name,
                qty: i.qty,
                // For a weighed line this is the ₹/kg its band earned, so the
                // invoice shows the rate actually charged.
                unitPrice: i.isWeighed ? Money(i.ratePerKg!) : i.unitPrice,
                unit: i.unit,
                lineTotal: i.totalPrice,
              ))
          .toList(),
      subtotal: cart.subtotal,
      deliveryCharge: _deliveryChargeFor(address, config),
      paymentMethod: _paymentMethod,
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
          if (orderId == null) return;
          // COD goes straight to the success screen; UPI stops at the
          // payment screen first (PRD §7: "Order placed → UPI payment
          // screen shown → ... → Admin confirms order").
          if (_paymentMethod == PaymentMethod.upi) {
            context.pushReplacement(RouteNames.upiPaymentPath(orderId));
          } else {
            context.pushReplacement(RouteNames.orderSuccessPath(orderId));
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString()), backgroundColor: AppColors.error),
          );
        },
      );
    });

    final config = ref.watch(deliveryConfigProvider).valueOrNull;
    final deliveryCharge = _deliveryChargeFor(_currentAddress(), config);
    final grandTotal = cart.subtotal + deliveryCharge;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.checkoutDeliveryAddress, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              AddressFormFields(
                streetController: _streetController,
                cityController: _cityController,
                pincodeController: _pincodeController,
                resolvedAddress: _resolvedAddress,
                isLocating: _isLocating,
                onUseCurrentLocation: _useCurrentLocation,
              ),
              const SizedBox(height: 24),
              Text(l10n.checkoutPaymentMethod, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _PaymentMethodCard(
                value: PaymentMethod.cod,
                groupValue: _paymentMethod,
                icon: Icons.payments_outlined,
                label: l10n.checkoutCod,
                onTap: () => setState(() => _paymentMethod = PaymentMethod.cod),
              ),
              const SizedBox(height: 8),
              _PaymentMethodCard(
                value: PaymentMethod.upi,
                groupValue: _paymentMethod,
                icon: Icons.qr_code_rounded,
                label: l10n.checkoutUpi,
                onTap: () => setState(() => _paymentMethod = PaymentMethod.upi),
              ),
              const SizedBox(height: 24),
              Text(l10n.checkoutOrderSummary, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SummaryRow(label: l10n.checkoutSubtotalItems(cart.items.length), value: cart.subtotal.formatted),
              SummaryRow(
                label: (_latitude != null && _longitude != null)
                    ? l10n.checkoutDeliveryCharge
                    : l10n.checkoutDeliveryChargeEstimated,
                value: deliveryCharge.formatted,
              ),
              const Divider(),
              SummaryRow(label: l10n.checkoutGrandTotal, value: grandTotal.formatted, bold: true),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.checkoutPlaceOrder,
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

/// A selectable payment-method row styled as a bordered card that highlights
/// violet when chosen, matching the Figma reference's selected-state
/// treatment (used everywhere else in the app a choice needs to stand out).
class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod value;
  final PaymentMethod groupValue;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.06) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
            Radio<PaymentMethod>(
              value: value,
              groupValue: groupValue,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
