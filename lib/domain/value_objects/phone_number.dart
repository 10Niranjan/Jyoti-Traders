import 'package:equatable/equatable.dart';

/// Wraps a phone number, guaranteeing it's a valid 10-digit Indian mobile number.
class PhoneNumber extends Equatable {
  final String value;

  static final RegExp _indianMobile = RegExp(r'^[6-9]\d{9}$');

  PhoneNumber(this.value) {
    if (!_indianMobile.hasMatch(value)) {
      throw ArgumentError.value(value, 'value', 'Must be a valid 10-digit Indian mobile number');
    }
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
