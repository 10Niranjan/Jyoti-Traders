import 'package:equatable/equatable.dart';

/// Payout bank account for a retailer. Used wherever the platform needs to
/// settle funds to the retailer (e.g. refunds, wholesale payouts) — kept as
/// its own entity rather than flat fields on [UserEntity]/`UserModel` so it
/// can be validated, masked, and persisted independently of the rest of the
/// profile.
class BankDetailsEntity extends Equatable {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String? upiId;

  const BankDetailsEntity({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    this.upiId,
  });

  bool get isComplete =>
      accountHolderName.trim().isNotEmpty && accountNumber.trim().isNotEmpty && ifscCode.trim().isNotEmpty && bankName.trim().isNotEmpty;

  /// e.g. "•••• •••• 4521" — the only form this should ever be rendered in
  /// outside of an active edit session.
  String get maskedAccountNumber => maskAccountNumber(accountNumber);

  static String maskAccountNumber(String accountNumber) {
    final digits = accountNumber.trim();
    if (digits.length <= 4) return digits;
    return '•••• •••• ${digits.substring(digits.length - 4)}';
  }

  BankDetailsEntity copyWith({
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? upiId,
  }) {
    return BankDetailsEntity(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      upiId: upiId ?? this.upiId,
    );
  }

  @override
  List<Object?> get props => [accountHolderName, accountNumber, ifscCode, bankName, upiId];
}
