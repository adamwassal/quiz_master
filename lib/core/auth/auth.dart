import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseAuthError(e));
    }
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    if (password != passwordConfirm) {
      throw Exception('Passwords do not match');
    }
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseAuthError(e));
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseAuthError(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseAuthError(e));
    }
  }

  Future<User?> getCurrentUser() async {
    
    return _auth.currentUser;
  }


  Future<bool> isUserLoggedIn() async {
    User? user = await getCurrentUser();
    return user != null;
  }

  Future<void> deleteUser() async {
    User? user = await getCurrentUser();
    if (user != null) {
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        throw Exception(_handleFirebaseAuthError(e));
      }
    } else {
      throw Exception('No user is currently logged in');
    }
  }

  Future<void> updateUserEmail(String newEmail) async {
    User? user = await getCurrentUser();
    if (user != null) {
      try {
        await user.updateEmail(newEmail);
      } on FirebaseAuthException catch (e) {
        throw Exception(_handleFirebaseAuthError(e));
      }
    } else {
      throw Exception('No user is currently logged in');
    }
  }

  Future<void> updateUserPassword(String newPassword) async {
    User? user = await getCurrentUser();
    if (user != null) {
      try {
        await user.updatePassword(newPassword);
      } on FirebaseAuthException catch (e) {
        throw Exception(_handleFirebaseAuthError(e));
      }
    } else {
      throw Exception('No user is currently logged in');
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'email-already-in-use':
        return 'The email address is already in use.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-credential':
        return 'The supplied auth credential is incorrect, malformed, or has expired.';
      default:
        return 'Authentication error: ${e.message ?? "An unexpected error occurred"}';
    }
  }
}
