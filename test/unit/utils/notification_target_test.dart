import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/domain/entities/notification_entity.dart';
import 'package:traders_retailer/features/auth/controllers/auth_state.dart';
import 'package:traders_retailer/features/notifications/utils/notification_target.dart';

NotificationEntity _notification({String? orderId}) => NotificationEntity(
  id: 'n1',
  title: 'Order confirmed',
  body: 'Body',
  orderId: orderId,
  receivedAt: DateTime(2026, 1, 1),
  isRead: false,
);

final _admin = UserModel(
  uid: 'a1',
  name: 'Admin',
  email: 'admin@test.com',
  phone: '9876543210',
  role: UserRole.admin,
  status: UserStatus.approved,
  businessName: 'Jyoti Traders',
  createdAt: DateTime(2026, 1, 1),
);

final _retailer = UserModel(
  uid: 'u1',
  name: 'Ramesh',
  email: 'ramesh@test.com',
  phone: '9876543211',
  role: UserRole.customer,
  status: UserStatus.approved,
  businessName: 'Ramesh Kirana Store',
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  test('returns null when the notification has no linked order', () {
    expect(
      notificationTargetRoute(
        _notification(),
        AuthenticatedCustomer(_retailer),
      ),
      isNull,
    );
  });

  test(
    'routes to the retailer read-only order screen for a signed-in retailer',
    () {
      final route = notificationTargetRoute(
        _notification(orderId: 'o1'),
        AuthenticatedCustomer(_retailer),
      );
      expect(route, '/order/o1');
    },
  );

  test('routes to the admin editable order screen for a signed-in admin', () {
    final route = notificationTargetRoute(
      _notification(orderId: 'o1'),
      AuthenticatedAdmin(_admin),
    );
    expect(route, '/admin/orders/o1');
  });

  test('defaults to the retailer route for any other auth state', () {
    // Unreachable in practice (this screen is only opened once signed in),
    // but the function shouldn't throw for it — it just isn't AuthenticatedAdmin.
    final route = notificationTargetRoute(
      _notification(orderId: 'o1'),
      const Unauthenticated(),
    );
    expect(route, '/order/o1');
  });
}
