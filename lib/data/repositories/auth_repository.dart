import '../../domain/entities/address_entity.dart';
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

  /// Self-service profile update (shop address, GST number) — distinct from
  /// admin approval/rejection, which lives on `UserRepository` in `domain/`.
  Future<UserModel?> updateProfile({
    required String uid,
    AddressEntity? address,
    String? gstNumber,
  });
}
