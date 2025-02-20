import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Google sign-in
  Future<void> signInWithGoogle() async {
    // Begin sign-in process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if (gUser == null) {
      throw Exception('Google Sign-In canceled.');
    }

    // Obtain authentication credentials from the request
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    // Create a new credential for the user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Finally, sign in to Firebase
    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}