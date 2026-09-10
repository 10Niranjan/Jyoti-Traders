import '../../domain/entities/address_entity.dart';
import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/business_hours_entity.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    required String businessName,
  });

  Future<UserModel?> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<UserModel?> refreshUserStatus(String uid);

  /// Self-service profile update (basic info, shop address, GST number,
  /// payout/business details, notification preferences) — distinct from admin
  /// approval/rejection, which lives on `UserRepository` in `domain/`.
  Future<UserModel?> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? businessName,
    String? photoUrl,
    AddressEntity? address,
    List<AddressEntity>? savedAddresses,
    String? gstNumber,
    BankDetailsEntity? bankDetails,
    BusinessHoursEntity? businessHours,
    NotificationPreferencesEntity? notificationPreferences,
  });

  /// Persists this device's current FCM token on the user's profile, called
  /// on login and again whenever the token rotates (phases.md §5).
  Future<void> updateFcmToken({required String uid, required String fcmToken});

  /// Sends a password-reset email via Firebase Auth (self-service "Change
  /// Password" from Settings) — no-op success in simulation mode, where
  /// there's no real inbox to deliver to.
  Future<void> sendPasswordResetEmail(String email);
}
