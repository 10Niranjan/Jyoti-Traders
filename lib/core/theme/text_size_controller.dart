import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage_service.dart';

/// The retailer's text-size choice. [auto] follows the device's font-size
/// setting; the others pin a fixed scale. All stay at or under 1.3x — the
/// ceiling this app's fixed-height rows/cards were laid out to survive.
enum TextSize {
  auto(null),
  small(0.9),
  medium(1.0),
  large(1.2);

  /// `null` = follow the system scale.
  final double? scale;
  const TextSize(this.scale);
}

/// The scaler the whole app renders with. [auto] respects the device's
/// accessibility setting but clamps it to 1.0–1.3x (an unclamped 3.0x would
/// overflow the fixed-height layouts); any other choice overrides the system.
TextScaler resolveTextScaler(TextScaler system, TextSize size) {
  final fixed = size.scale;
  if (fixed != null) return TextScaler.linear(fixed);
  return system.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3);
}

/// Persisted via `LocalStorageService` — same null-means-system shape as
/// `ThemeModeController`/`LocaleController`.
class TextSizeController extends StateNotifier<TextSize> {
  final LocalStorageService _storage;

  TextSizeController(this._storage)
    : super(_fromPreference(_storage.getTextSizePreference()));

  static TextSize _fromPreference(String? name) => TextSize.values.firstWhere(
    (s) => s.name == name,
    orElse: () => TextSize.auto,
  );

  Future<void> setTextSize(TextSize size) async {
    state = size;
    if (size == TextSize.auto) {
      await _storage.clearTextSizePreference();
    } else {
      await _storage.saveTextSizePreference(size.name);
    }
  }
}

final textSizeProvider = StateNotifierProvider<TextSizeController, TextSize>((
  ref,
) {
  return TextSizeController(ref.watch(localStorageProvider));
});
