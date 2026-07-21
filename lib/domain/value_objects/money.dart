import 'package:equatable/equatable.dart';
import '../../core/utils/currency_formatter.dart';

/// Wraps a ₹ amount, guaranteeing it can never be negative.
class Money extends Equatable {
  final double amount;

  Money(this.amount) {
    if (amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'Money amount cannot be negative');
    }
  }

  static final Money zero = Money(0);

  String get formatted => formatRupees(amount);

  Money operator +(Money other) => Money(amount + other.amount);
  Money operator -(Money other) => Money(amount - other.amount);
  bool operator >=(Money other) => amount >= other.amount;
  bool operator <(Money other) => amount < other.amount;

  @override
  List<Object?> get props => [amount];

  @override
  String toString() => formatted;
}
