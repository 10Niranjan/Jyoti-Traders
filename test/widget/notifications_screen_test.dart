import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/constants/app_colors.dart';
import 'package:traders_retailer/data/models/user_model.dart';
import 'package:traders_retailer/data/repositories/auth_repository_provider.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/notification_entity.dart';
import 'package:traders_retailer/domain/repositories/notification_repository.dart';
import 'package:traders_retailer/features/notifications/screens/notifications_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/fake_auth_repository.dart';
import '../helpers/test_viewport.dart';
import '../helpers/theme_builder.dart';

class FakeNotificationRepository implements NotificationRepository {
  final List<NotificationEntity> notifications;
  final List<String> markedAsRead = [];
  bool markedAllAsRead = false;

  FakeNotificationRepository(this.notifications);

  @override
  Stream<List<NotificationEntity>> watchNotifications() =>
      Stream.value(notifications);

  @override
  Future<void> addNotification(NotificationEntity notification) async {}

  @override
  Future<void> markAsRead(String id) async => markedAsRead.add(id);

  @override
  Future<void> markAllAsRead() async => markedAllAsRead = true;
}

NotificationEntity _notification({
  required String id,
  required String title,
  bool isRead = false,
  String? orderId,
}) => NotificationEntity(
  id: id,
  title: title,
  body: 'Body for $id',
  orderId: orderId,
  receivedAt: DateTime.now().subtract(const Duration(minutes: 5)),
  isRead: isRead,
);

final _retailer = UserModel(
  uid: 'u1',
  name: 'Ramesh',
  email: 'ramesh@test.com',
  phone: '9876543210',
  role: UserRole.customer,
  status: UserStatus.approved,
  businessName: 'Ramesh Kirana Store',
  createdAt: DateTime(2026, 1, 1),
);

Widget _wrap(FakeNotificationRepository repo, {ThemeData? theme}) =>
    ProviderScope(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(repo),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(_retailer)),
      ],
      child: MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const NotificationsScreen(),
      ),
    );

void main() {
  testWidgets('shows an empty state when there are no notifications', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(FakeNotificationRepository([])));
    await tester.pumpAndSettle();

    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('lists notifications with title and body', (tester) async {
    await tester.pumpWidget(
      _wrap(
        FakeNotificationRepository([
          _notification(id: 'n1', title: 'Order confirmed'),
          _notification(id: 'n2', title: 'Order delivered', isRead: true),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order confirmed'), findsOneWidget);
    expect(find.text('Body for n1'), findsOneWidget);
    expect(find.text('Order delivered'), findsOneWidget);
  });

  testWidgets('shows "Mark all read" only when something is unread', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        FakeNotificationRepository([
          _notification(id: 'n1', title: 'Order confirmed', isRead: true),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets('tapping a notification marks it as read', (tester) async {
    final repo = FakeNotificationRepository([
      _notification(id: 'n1', title: 'Order confirmed'),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Order confirmed'));
    await tester.pumpAndSettle();

    expect(repo.markedAsRead, ['n1']);
  });

  testWidgets('"Mark all read" calls markAllAsRead', (tester) async {
    final repo = FakeNotificationRepository([
      _notification(id: 'n1', title: 'Order confirmed'),
    ]);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();

    expect(repo.markedAllAsRead, isTrue);
  });

  // Regression: tiles were flat 8%-primary outlines with muted titles — no
  // visible card in either theme.
  for (final dark in [false, true]) {
    final label = dark ? 'dark' : 'light';
    testWidgets(
      'tiles are bordered cards with a full-strength title ($label)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            FakeNotificationRepository([
              _notification(id: 'n1', title: 'Order confirmed'),
              _notification(id: 'n2', title: 'Order delivered', isRead: true),
            ]),
            theme: buildTheme(dark: dark),
          ),
        );
        await tester.pumpAndSettle();

        final title = tester.widget<Text>(find.text('Order confirmed'));
        expect(
          title.style!.color,
          dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        );

        BoxDecoration cardOf(String text) {
          final card = find.ancestor(
            of: find.text(text),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is Container &&
                  w.decoration is BoxDecoration &&
                  (w.decoration! as BoxDecoration).border != null,
            ),
          );
          expect(card, findsOneWidget);
          return tester.widget<Container>(card).decoration! as BoxDecoration;
        }

        // Unread is tinted; read is the plain surface. Both have a border.
        expect(
          cardOf('Order confirmed').color,
          isNot(cardOf('Order delivered').color),
        );
      },
    );
  }

  group('inbox layout', () {
    useTallTestViewport(); // a list this tall builds only what fits on screen

    NotificationEntity at(
      String id,
      String title, {
      required Duration age,
      bool isRead = false,
      String? orderId,
      NotificationKind kind = NotificationKind.general,
    }) => NotificationEntity(
      id: id,
      title: title,
      body: 'Body for $id',
      orderId: orderId,
      receivedAt: DateTime.now().subtract(age),
      isRead: isRead,
      kind: kind,
    );

    testWidgets('the hero counts the unread and offers Mark all read', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FakeNotificationRepository([
            at('a', 'First', age: const Duration(minutes: 5)),
            at('b', 'Second', age: const Duration(minutes: 9)),
            at('c', 'Third', age: const Duration(minutes: 20), isRead: true),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 new'), findsOneWidget);
      expect(find.text('3 in your inbox'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);
    });

    testWidgets('the hero says all caught up when nothing is unread', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FakeNotificationRepository([
            at('a', 'First', age: const Duration(minutes: 5), isRead: true),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All caught up'), findsOneWidget);
      expect(find.text('Mark all read'), findsNothing);
    });

    testWidgets('notifications are grouped under day headings', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FakeNotificationRepository([
            at('a', 'Recent', age: const Duration(minutes: 5)),
            at('b', 'Midweek', age: const Duration(days: 3)),
            at('c', 'Old news', age: const Duration(days: 30)),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Earlier this week'), findsOneWidget);
      expect(find.text('Earlier'), findsOneWidget);
      expect(find.text('Yesterday'), findsNothing); // empty buckets are dropped
    });

    testWidgets('the Unread filter hides read notifications', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FakeNotificationRepository([
            at('a', 'Fresh one', age: const Duration(minutes: 5)),
            at('b', 'Seen one', age: const Duration(minutes: 9), isRead: true),
          ]),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Seen one'), findsOneWidget);

      await tester.tap(find.text('Unread (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Fresh one'), findsOneWidget);
      expect(find.text('Seen one'), findsNothing);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('Seen one'), findsOneWidget);
    });

    testWidgets('the Unread filter has its own empty state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FakeNotificationRepository([
            at('a', 'Seen one', age: const Duration(minutes: 9), isRead: true),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unread (0)'));
      await tester.pumpAndSettle();

      expect(find.text("You're all caught up"), findsOneWidget);
      expect(find.text('Seen one'), findsNothing);
    });

    testWidgets('only order updates carry a View order cue', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FakeNotificationRepository([
            at(
              'a',
              'Order shipped',
              age: const Duration(minutes: 5),
              orderId: 'o1',
            ),
            at('b', 'Big sale', age: const Duration(minutes: 9)),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('View order'), findsOneWidget);
    });

    testWidgets('each kind gets its own icon', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FakeNotificationRepository([
            at('a', 'Order', age: const Duration(minutes: 1), orderId: 'o1'),
            at(
              'b',
              'Stock',
              age: const Duration(minutes: 2),
              kind: NotificationKind.stock,
            ),
            at(
              'c',
              'Promo',
              age: const Duration(minutes: 3),
              kind: NotificationKind.broadcast,
            ),
            at('d', 'Hello', age: const Duration(minutes: 4)),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
      expect(find.byIcon(Icons.campaign_rounded), findsOneWidget);
      // The general tile's bell — the hero's bell is a different icon.
      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
    });
  });
}
