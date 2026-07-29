import '../../core/utils/firestore_date_parser.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/business_hours_entity.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/entities/user_entity.dart';

export '../../domain/entities/user_entity.dart' show UserRole, UserStatus;

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final UserStatus status;
  final String businessName;
  final AddressEntity? address;
  final String? gstNumber;
  final String? fcmToken;
  final DateTime createdAt;
  final BankDetailsEntity? bankDetails;
  final BusinessHoursEntity? businessHours;
  final NotificationPreferencesEntity notificationPreferences;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.businessName,
    this.address,
    this.gstNumber,
    this.fcmToken,
    required this.createdAt,
    this.bankDetails,
    this.businessHours,
    this.notificationPreferences = NotificationPreferencesEntity.defaults,
  });

  /// Backward-compatible view of [status] for existing call sites
  /// (`AuthController`, screens) that only care about the binary check.
  bool get isApproved => status == UserStatus.approved;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'customer'),
      status: _statusFromJson(json),
      businessName: json['businessName'] as String? ?? '',
      address: _addressFromJson(json['address']),
      gstNumber: json['gstNumber'] as String?,
      fcmToken: json['fcmToken'] as String?,
      createdAt: parseFirestoreDate(json['createdAt']),
      bankDetails: _bankDetailsFromJson(json['bankDetails']),
      businessHours: _businessHoursFromJson(json['businessHours']),
      notificationPreferences: _notificationPreferencesFromJson(json['notificationPreferences']),
    );
  }

  /// Older docs only have `isApproved: bool`; new docs have `status: String`.
  static UserStatus _statusFromJson(Map<String, dynamic> json) {
    if (json['status'] != null) {
      return UserStatus.fromString(json['status'] as String);
    }
    final legacyApproved = json['isApproved'] as bool? ?? false;
    return legacyApproved ? UserStatus.approved : UserStatus.pending;
  }

  static AddressEntity? _addressFromJson(dynamic value) {
    if (value == null) return null;
    final map = Map<String, dynamic>.from(value as Map);
    return AddressEntity(
      street: map['street'] as String? ?? '',
      city: map['city'] as String? ?? '',
      pincode: map['pincode'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      formattedAddress: map['formattedAddress'] as String?,
    );
  }

  static BankDetailsEntity? _bankDetailsFromJson(dynamic value) {
    if (value == null) return null;
    final map = Map<String, dynamic>.from(value as Map);
    return BankDetailsEntity(
      accountHolderName: map['accountHolderName'] as String? ?? '',
      accountNumber: map['accountNumber'] as String? ?? '',
      ifscCode: map['ifscCode'] as String? ?? '',
      bankName: map['bankName'] as String? ?? '',
      upiId: map['upiId'] as String?,
    );
  }

  static BusinessHoursEntity? _businessHoursFromJson(dynamic value) {
    if (value == null) return null;
    final map = Map<String, dynamic>.from(value as Map);
    return BusinessHoursEntity(
      openTime: map['openTime'] as String? ?? BusinessHoursEntity.defaults.openTime,
      closeTime: map['closeTime'] as String? ?? BusinessHoursEntity.defaults.closeTime,
      is24x7: map['is24x7'] as bool? ?? false,
    );
  }

  /// Missing/partial map = every flag defaults to `true` (see
  /// [NotificationPreferencesEntity] doc) so accounts created before this
  /// feature existed keep receiving everything they already got.
  static NotificationPreferencesEntity _notificationPreferencesFromJson(dynamic value) {
    if (value == null) return NotificationPreferencesEntity.defaults;
    final map = Map<String, dynamic>.from(value as Map);
    return NotificationPreferencesEntity(
      orderUpdates: map['orderUpdates'] as bool? ?? true,
      promotions: map['promotions'] as bool? ?? true,
      lowStockAlerts: map['lowStockAlerts'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.value,
      'status': status.value,
      'isApproved': isApproved,
      'businessName': businessName,
      if (address != null)
        'address': {
          'street': address!.street,
          'city': address!.city,
          'pincode': address!.pincode,
          'latitude': address!.latitude,
          'longitude': address!.longitude,
          'formattedAddress': address!.formattedAddress,
        },
      'gstNumber': gstNumber,
      'fcmToken': fcmToken,
      // Plain DateTime, not Timestamp.fromDate() — this map is written to
      // both real Firestore (which auto-converts DateTime -> Timestamp on
      // write) and to Hive for simulation mode, which cannot serialize
      // Timestamp directly.
      'createdAt': createdAt,
      if (bankDetails != null)
        'bankDetails': {
          'accountHolderName': bankDetails!.accountHolderName,
          'accountNumber': bankDetails!.accountNumber,
          'ifscCode': bankDetails!.ifscCode,
          'bankName': bankDetails!.bankName,
          'upiId': bankDetails!.upiId,
        },
      if (businessHours != null)
        'businessHours': {
          'openTime': businessHours!.openTime,
          'closeTime': businessHours!.closeTime,
          'is24x7': businessHours!.is24x7,
        },
      'notificationPreferences': {
        'orderUpdates': notificationPreferences.orderUpdates,
        'promotions': notificationPreferences.promotions,
        'lowStockAlerts': notificationPreferences.lowStockAlerts,
      },
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      fullName: name,
      shopName: businessName,
      email: email,
      phone: phone,
      role: role,
      status: status,
      address: address,
      gstNumber: gstNumber,
      fcmToken: fcmToken,
      createdAt: createdAt,
      bankDetails: bankDetails,
      businessHours: businessHours,
      notificationPreferences: notificationPreferences,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    UserStatus? status,
    String? businessName,
    AddressEntity? address,
    String? gstNumber,
    String? fcmToken,
    DateTime? createdAt,
    BankDetailsEntity? bankDetails,
    BusinessHoursEntity? businessHours,
    NotificationPreferencesEntity? notificationPreferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      bankDetails: bankDetails ?? this.bankDetails,
      businessHours: businessHours ?? this.businessHours,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
    );
  }
}
