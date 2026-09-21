import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traders_retailer/core/theme/text_size_controller.dart';
import 'package:traders_retailer/data/datasources/local_storage_service.dart';

/// Overrides only the text-size methods so this never touches a real Hive box.
class FakeLocalStorageService extends LocalStorageService {
  String? stored;
  FakeLocalStorageService([this.stored]);

  @override
  String? getTextSizePreference() => stored;

  @override
  Future<void> saveTextSizePreference(String name) async => stored = name;

  @override
  Future<void> clearTextSizePreference() async => stored = null;
}

void main() {
  group('TextSizeController', () {
    test('defaults to auto when nothing (or junk) is stored', () {
      expect(
        TextSizeController(FakeLocalStorageService()).state,
        TextSize.auto,
      );
      expect(
        TextSizeController(FakeLocalStorageService('huge')).state,
        TextSize.auto,
      );
    });

    test('loads a stored choice', () {
      expect(
        TextSizeController(FakeLocalStorageService('large')).state,
        TextSize.large,
      );
    });

    test('setTextSize persists a fixed size and clears it for auto', () async {
      final storage = FakeLocalStorageService();
      final controller = TextSizeController(storage);

      await controller.setTextSize(TextSize.small);
      expect(controller.state, TextSize.small);
      expect(storage.stored, 'small');

      await controller.setTextSize(TextSize.auto);
      expect(controller.state, TextSize.auto);
      expect(storage.stored, isNull);
    });
  });

  group('resolveTextScaler', () {
    test('auto follows the system scale but clamps it to 1.0–1.3', () {
      expect(
        resolveTextScaler(
          const TextScaler.linear(3.0),
          TextSize.auto,
        ).scale(10),
        13,
      );
      expect(
        resolveTextScaler(
          const TextScaler.linear(0.5),
          TextSize.auto,
        ).scale(10),
        10,
      );
      expect(
        resolveTextScaler(
          const TextScaler.linear(1.15),
          TextSize.auto,
        ).scale(10),
        closeTo(11.5, 1e-9),
      );
    });

    test('a fixed choice overrides the system scale', () {
      expect(
        resolveTextScaler(
          const TextScaler.linear(1.3),
          TextSize.small,
        ).scale(10),
        closeTo(9, 1e-9),
      );
      expect(
        resolveTextScaler(
          const TextScaler.linear(1.0),
          TextSize.large,
        ).scale(10),
        closeTo(12, 1e-9),
      );
    });
  });
}
