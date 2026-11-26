import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traders_retailer/core/services/analytics_service.dart';
import 'package:traders_retailer/data/repositories/auth_repository.dart';
import 'package:traders_retailer/features/auth/controllers/auth_controller.dart';
import 'package:traders_retailer/features/auth/controllers/auth_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockAnalytics extends Mock implements AnalyticsService {}

void main() {
  test(
    'a Firebase sign-in error keeps its code so the screen can translate it',
    () async {
      final repo = _MockAuthRepository();
      when(() => repo.authStateChanges).thenAnswer((_) => const Stream.empty());
      when(
        () => repo.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        FirebaseAuthException(code: 'invalid-credential', message: 'raw'),
      );

      final controller = AuthController(repo, _MockAnalytics());
      await controller.signIn('a@b.com', 'wrong');

      final state = controller.state as AuthError;
      expect(state.code, 'invalid-credential');
      controller.dispose();
    },
  );
}
