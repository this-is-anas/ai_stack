import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_page.dart';
import '../services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  // Firebase Authentication for Email/Password
  Future<String?> _authUser(LoginData data) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      return null; // Login successful
    } catch (e) {
      return 'Invalid email or password';
    }
  }

  Future<String?> _registerUser(SignupData data) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );
      return null; // Signup successful
    } catch (e) {
      return 'Email already in use or invalid';
    }
  }

  Future<String?> _recoverPassword(String name) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: name);
      return null; // Recovery email sent
    } catch (e) {
      return 'Email not found';
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // FlutterLogin UI
          FlutterLogin(
            title: 'Jobly',
            onLogin: _authUser,
            onSignup: _registerUser,
            onRecoverPassword: _recoverPassword,
            onSubmitAnimationCompleted: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            theme: LoginTheme(
              primaryColor: Theme.of(context).colorScheme.primary, // Use primary color
              accentColor: Theme.of(context).colorScheme.secondary, // Use secondary color
              titleStyle: GoogleFonts.nunito(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              bodyStyle: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.grey[800],
              ),
              textFieldStyle: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
              buttonStyle: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              cardTheme: CardTheme(
                color: Colors.white,
                elevation: 5,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Google Sign-In Button (Positioned at the bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    // Call the AuthService's Google Sign-In method
                    await AuthService().signInWithGoogle();

                    // Navigate to HomePage on success
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  } catch (e) {
                    // Show a SnackBar for any errors during sign-in
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign-In Failed: $e')),
                    );
                  }
                },
                icon: Image.asset(
                  'lib/assets/images/google.png', // Path to the Google logo
                  height: 24,
                ),
                label: const Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
              // icon: Image.asset(
              //   'lib/assets/images/google.png', // Add a Google logo asset
              //   height: 24,
              //   width: 24,
              // ),
              // label: Text(
              //   'Sign in with Google',
              //   style: GoogleFonts.montserrat(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //   ),
            ),
          ),

        ],
      ),
    );
  }
}