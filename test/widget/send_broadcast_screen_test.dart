import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/data/repositories/repository_providers.dart';
import 'package:traders_retailer/domain/entities/broadcast_entity.dart';
import 'package:traders_retailer/domain/repositories/broadcast_repository.dart';
import 'package:traders_retailer/features/admin/screens/send_broadcast_screen.dart';
import 'package:traders_retailer/l10n/app_localizations.dart';

import '../helpers/test_viewport.dart';

class FakeBroadcastRepository implements BroadcastRepository {
  final List<BroadcastEntity> sent = [];
  final _controller = StreamController<List<BroadcastEntity>>.broadcast();

  @override
  Stream<List<BroadcastEntity>> watchBroadcasts() async* {
    yield sent;
    yield* _controller.stream;
  }

  @override
  Future<void> send({required String title, required String body}) async {
    sent.insert(0, BroadcastEntity(id: 'b${sent.length}', title: title, body: body, sentAt: DateTime(2026, 1, 1)));
    _controller.add(sent);
  }
}

Widget _wrap(FakeBroadcastRepository repo) => ProviderScope(
  overrides: [broadcastRepositoryProvider.overrideWithValue(repo)],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const SendBroadcastScreen(),
  ),
);

void main() {
  useTallTestViewport();

  testWidgets('shows the empty history state when nothing has been sent', (tester) async {
    await tester.pumpWidget(_wrap(FakeBroadcastRepository()));
    await tester.pumpAndSettle();

    expect(find.text('No broadcasts sent yet'), findsOneWidget);
  });

  testWidgets('sending a broadcast clears the form, shows a confirmation and lists it in history', (tester) async {
    final repo = FakeBroadcastRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'New stock arrived');
    await tester.enterText(find.widgetWithText(TextFormField, 'Message'), 'Fresh Basmati Rice is back.');
    await tester.tap(find.text('Send to All Retailers'));
    await tester.pumpAndSettle();

    expect(repo.sent, hasLength(1));
    expect(find.text('Broadcast sent'), findsOneWidget);
    expect(find.text('New stock arrived'), findsOneWidget);
  });

  testWidgets('the form does not submit when title or message is blank', (tester) async {
    final repo = FakeBroadcastRepository();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send to All Retailers'));
    await tester.pump();

    expect(repo.sent, isEmpty);
  });
}
