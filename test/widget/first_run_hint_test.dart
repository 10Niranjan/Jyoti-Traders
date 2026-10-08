import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/datasources/local_storage_service.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';
import 'package:traders_retailer/shared/widgets/first_run_hint.dart';

class FakeLocalStorageService extends LocalStorageService {
  Set<String> stored;
  FakeLocalStorageService([this.stored = const {}]);

  @override
  Set<String> getSeenFirstRunHints() => stored;

  @override
  Future<void> markFirstRunHintSeen(String hintId) async =>
      stored = {...stored, hintId};
}

Widget _wrap(Widget child, LocalStorageService storage) {
  return ProviderScope(
    overrides: [localStorageProvider.overrideWithValue(storage)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('shows the tip bubble and the child when unseen', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const FirstRunHint(
          hintId: 'floating_cart_bar',
          message: 'Tap here',
          child: Text('Child content'),
        ),
        FakeLocalStorageService(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tap here'), findsOneWidget);
    expect(find.text('Child content'), findsOneWidget);
  });

  testWidgets('renders bare child once the hint was already seen', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const FirstRunHint(
          hintId: 'floating_cart_bar',
          message: 'Tap here',
          child: Text('Child content'),
        ),
        FakeLocalStorageService({'floating_cart_bar'}),
      ),
    );

    expect(find.text('Tap here'), findsNothing);
    expect(find.text('Child content'), findsOneWidget);
  });

  testWidgets('dismissing the bubble persists it and hides the bubble', (
    tester,
  ) async {
    final storage = FakeLocalStorageService();
    await tester.pumpWidget(
      _wrap(
        const FirstRunHint(
          hintId: 'floating_cart_bar',
          message: 'Tap here',
          child: Text('Child content'),
        ),
        storage,
      ),
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Tap here'), findsNothing);
    expect(find.text('Child content'), findsOneWidget);
    expect(storage.stored, {'floating_cart_bar'});
  });
}
