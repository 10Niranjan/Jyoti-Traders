import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:traders_retailer/main.dart';

void main() {
  setUp(() async {
    // Initialize Hive with a temporary path for testing
    Hive.init('temp_hive');
    await Hive.openBox('settings_cache');
    await Hive.openBox('user_cache');
    await Hive.openBox('notifications_cache');
  });

  tearDown(() async {
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JyotiKiranaApp(),
      ),
    );

    expect(find.byType(JyotiKiranaApp), findsOneWidget);

    // Settle the splash screen redirect timer
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
