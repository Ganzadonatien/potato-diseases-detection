import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:irish_potato_app/models/user_profile.dart';
import 'package:irish_potato_app/services/firestore_service.dart';

class AuthService {
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      scopes: ['email'],
    ).signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    final user = userCredential.user;
    if (user != null) {
      await _ensureUserProfile(user);
    }

    return userCredential;
  }

  Future<void> _ensureUserProfile(User user) async {
    final existing = await FirestoreService().getUserProfile(user.uid);
    if (existing != null) return;

    final profile = UserProfile(
      uid: user.uid,
      fullName:
          user.displayName ?? user.email?.split('@').first ?? 'Google User',
      email: user.email ?? '',
      role: 'farmer',
      approved: true,
      province: '',
      district: '',
      sector: '',
      createdAt: DateTime.now().toUtc(),
    );

    await FirestoreService().saveUserProfile(profile);
  }
}
