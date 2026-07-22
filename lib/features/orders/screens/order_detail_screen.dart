import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/order_detail_body.dart';
import '../controllers/order_controller.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const ErrorStateWidget(),
        data: (order) {
          if (order == null) {
            return const ErrorStateWidget(message: 'This order could not be found.');
          }
          return OrderDetailBody(order: order);
        },
      ),
    );
  }
}
