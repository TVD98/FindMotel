import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_motel/common/models/user.dart' as fm;

/// Contract for authentication related operations.
///
/// Keeping the authentication layer behind an interface makes it easier to
/// swap out the underlying auth provider (e.g. Firebase, Supabase, mock
/// implementation for tests) without touching the rest of the codebase.
abstract class IAuthentication {
  /// Stream that emits the current [User] whenever the authentication state
  /// changes (e.g. user signs in, signs out, verifies email, etc.).
  Stream<User?> authStateChange();

  /// Sign in a user using their [email] and [password].
  ///
  /// Returns the resulting [UserCredential] if sign-in succeeds or throws a
  /// [FirebaseAuthException] if it fails.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });



  Future<({fm.User? user, String? error})> getCurrentUser();

  Future<String?> signOut();
}
