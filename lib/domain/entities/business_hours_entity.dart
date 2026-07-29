import 'package:equatable/equatable.dart';

/// A retailer's storefront operating hours. Times are stored as "HH:mm"
/// (24-hour, zero-padded) rather than `TimeOfDay` so this entity stays
/// plain-Dart and JSON-serializable without a UI dependency.
class BusinessHoursEntity extends Equatable {
  final String openTime;
  final String closeTime;
  final bool is24x7;

  const BusinessHoursEntity({
    required this.openTime,
    required this.closeTime,
    this.is24x7 = false,
  });

  static const BusinessHoursEntity defaults = BusinessHoursEntity(openTime: '09:00', closeTime: '21:00');

  BusinessHoursEntity copyWith({
    String? openTime,
    String? closeTime,
    bool? is24x7,
  }) {
    return BusinessHoursEntity(
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      is24x7: is24x7 ?? this.is24x7,
    );
  }

  @override
  List<Object?> get props => [openTime, closeTime, is24x7];
}
