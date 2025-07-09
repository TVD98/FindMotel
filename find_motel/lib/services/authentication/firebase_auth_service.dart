import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_motel/services/authentication/authentication_service.dart';
import 'package:find_motel/common/models/user.dart' as fm;

/// Concrete implementation of [IAuthentication] using Firebase Authentication.
class FirebaseAuthService implements IAuthentication {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

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

  @override
  Future<({fm.User? user, String? error})> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return (user: fm.User(id: user.uid, email: user.email!), error: null);
    }
    return (user: null, error: 'User not found');
  }

  @override
  Future<String?> signOut() async {
    try {
      await _auth.signOut();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
