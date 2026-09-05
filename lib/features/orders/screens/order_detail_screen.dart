import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/order_share_formatter.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/order_detail_body.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/order_controller.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isReordering = false;
  bool _isCancelling = false;

  Future<void> _shareOrder(OrderEntity order) async {
    // Wrapped defensively like every other platform-plugin call in this
    // codebase (FcmService, LocationService, ImageUploadService) — the share
    // sheet isn't available on every platform or in a test environment.
    try {
      await Share.share(
        buildOrderShareText(order),
        subject: AppLocalizations.of(context)!.orderNumber(order.id.shortId),
      );
    } catch (e) {
      logWarning('OrderDetailScreen: share sheet unavailable', e);
    }
  }

  Future<void> _buyAgain(OrderEntity order) async {
    setState(() => _isReordering = true);

    final productRepo = ref.read(productRepositoryProvider);
    final cart = ref.read(cartControllerProvider.notifier);
    var added = 0;
    var unavailable = 0;

    for (final item in order.items) {
      // Re-priced off the live product, never the order's frozen price —
      // a reorder is a new cart line, not a copy of an old invoice.
      final product = await productRepo.getProductById(item.productId);
      if (product == null || !product.isActive || !product.isInStock) {
        unavailable++;
        continue;
      }
      final qty = item.qty > product.maxQty ? product.maxQty : item.qty;
      await cart.addItem(
        CartItemEntity(
          productId: product.id,
          name: product.name,
          imageUrl: product.imageUrl,
          unitPrice: product.price,
          unit: product.unit,
          qty: qty,
          rateSlabs: product.rateSlabs,
        ),
      );
      added++;
    }

    if (!mounted) return;
    setState(() => _isReordering = false);

    final l10n = AppLocalizations.of(context)!;
    final message = unavailable == 0
        ? '${l10n.buyAgainAddedCount(added)}.'
        : '${l10n.buyAgainAddedCount(added)}${l10n.buyAgainUnavailableSuffix(unavailable)}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: added > 0
            ? SnackBarAction(
                label: l10n.productViewCartAction,
                onPressed: () => context.push(RouteNames.viewCart),
              )
            : null,
      ),
    );
  }

  Future<void> _cancelOrder(OrderEntity order) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.orderCancelDialogTitle),
        content: Text(l10n.orderCancelDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.yesCancel),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isCancelling = true);
    final success = await ref
        .read(retailerOrderControllerProvider.notifier)
        .cancelOrder(order.id);
    if (!mounted) return;
    setState(() => _isCancelling = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.orderCancelledMessage
              : l10n.orderCancelFailedMessage,
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderByIdProvider(widget.orderId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderDetailsTitle),
        actions: [
          orderAsync.maybeWhen(
            data: (order) => order == null
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.ios_share_rounded),
                    tooltip: l10n.orderShareTooltip,
                    onPressed: () => _shareOrder(order),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const ErrorStateWidget(),
        data: (order) {
          if (order == null) {
            return ErrorStateWidget(
              message: l10n.upiOrderNotFound,
            );
          }
          return Column(
            children: [
              Expanded(child: OrderDetailBody(order: order)),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isReordering
                              ? null
                              : () => _buyAgain(order),
                          icon: const Icon(Icons.replay_rounded, size: 18),
                          label: Text(l10n.homeBuyAgain),
                        ),
                      ),
                      if (order.isCancellable) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isCancelling
                                ? null
                                : () => _cancelOrder(order),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: Text(l10n.cancelButton),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
