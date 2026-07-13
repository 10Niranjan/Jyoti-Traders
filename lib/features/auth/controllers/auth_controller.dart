import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/auth_repository_provider.dart';
import '../../../data/models/user_model.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<UserModel?>? _authSubscription;

  AuthController(this._authRepository) : super(const AuthInitial()) {
    _init();
  }

  void _init() {
    state = const AuthLoading();
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges.listen(
      (user) {
        _handleUserChange(user);
      },
      onError: (err) {
        state = AuthError(err.toString());
      },
    );
  }

  void _handleUserChange(UserModel? user) {
    if (user == null) {
      state = const Unauthenticated();
    } else {
      if (user.role == UserRole.admin) {
        state = AuthenticatedAdmin(user);
      } else {
        if (user.isApproved) {
          state = AuthenticatedCustomer(user);
        } else {
          state = PendingApproval(user);
        }
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.signIn(email: email, password: password);
      _handleUserChange(user);
    } catch (e) {
      state = AuthError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    required String businessName,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        businessName: businessName,
      );
      _handleUserChange(user);
    } catch (e) {
      state = AuthError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await _authRepository.signOut();
      state = const Unauthenticated();
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> checkApprovalStatus() async {
    final currentState = state;
    if (currentState is PendingApproval) {
      final user = await _authRepository.refreshUserStatus(currentState.user.uid);
      _handleUserChange(user);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
