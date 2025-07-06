import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_motel/services/authentication/authentication_service.dart';

/// Concrete implementation of [IAuthentication] using Firebase Authentication.
class FirebaseAuthService implements IAuthentication {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<User?> authStateChange() {
    return _auth.authStateChanges();
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }
}
