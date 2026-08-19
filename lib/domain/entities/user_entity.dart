import 'package:equatable/equatable.dart';
import 'address_entity.dart';
import 'bank_details_entity.dart';
import 'business_hours_entity.dart';
import 'notification_preferences_entity.dart';

enum UserRole {
  admin,
  customer;

  String get value => name;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == role.toLowerCase(),
      orElse: () => UserRole.customer,
    );
  }
}

/// A retailer's approval status. Replaces the old binary `isApproved` flag
/// so admins can distinguish "not yet reviewed" from "explicitly rejected".
enum UserStatus {
  pending,
  approved,
  rejected;

  String get value => name;

  static UserStatus fromString(String status) {
    return UserStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => UserStatus.pending,
    );
  }
}

/// Business object for a Jyoti Traders user — Admin or Retailer.
class UserEntity extends Equatable {
  final String uid;
  final String fullName;
  final String shopName;
  final String email;
  final String phone;
  final UserRole role;
  final UserStatus status;
  final AddressEntity? address;
  final String? gstNumber;
  final String? fcmToken;
  final String? photoUrl;
  final DateTime createdAt;
  final BankDetailsEntity? bankDetails;
  final BusinessHoursEntity? businessHours;
  final NotificationPreferencesEntity notificationPreferences;

  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.shopName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.address,
    this.gstNumber,
    this.fcmToken,
    this.photoUrl,
    required this.createdAt,
    this.bankDetails,
    this.businessHours,
    this.notificationPreferences = NotificationPreferencesEntity.defaults,
  });

  bool get isApproved => status == UserStatus.approved;

  @override
  List<Object?> get props => [
    uid,
    fullName,
    shopName,
    email,
    phone,
    role,
    status,
    address,
    gstNumber,
    fcmToken,
    photoUrl,
    createdAt,
    bankDetails,
    businessHours,
    notificationPreferences,
  ];
}
