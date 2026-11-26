import '../../../data/models/user_model.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthenticatedAdmin extends AuthState {
  final UserModel user;
  const AuthenticatedAdmin(this.user);
}

class AuthenticatedCustomer extends AuthState {
  final UserModel user;
  const AuthenticatedCustomer(this.user);
}

class PendingApproval extends AuthState {
  final UserModel user;
  const PendingApproval(this.user);
}

class AuthError extends AuthState {
  final String message;

  /// Firebase Auth error code (e.g. `invalid-credential`) when the error came
  /// from Firebase — the screen turns it into a translated message.
  final String? code;
  const AuthError(this.message, {this.code});
}
