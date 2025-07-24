import 'package:accident_hotspot/Functions/auth_func.dart';
import 'package:accident_hotspot/Login%20Page%20web/Forgot_web.dart';
import 'package:accident_hotspot/Login%20Page%20web/Sign_Up_Web.dart';
import 'package:accident_hotspot/Maps/map_screen_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class LoginPageWeb extends StatefulWidget {
  const LoginPageWeb({super.key});

  @override
  _LoginPageWebState createState() => _LoginPageWebState();
}

class _LoginPageWebState extends State<LoginPageWeb> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;

  void login(String email, String password, BuildContext context) async {
    setState(() {
      errorMessage = null; // Clear any previous error
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Please enter email and password.";
      });
      return; // Exit the function if fields are empty
    }

    setState(() {
      isLoading = true; // Start loading indicator
    });

    try {
      final AuthFunc auth = AuthFunc();
      UserCredential? user = await auth.signin(
        email.trim(),
        password,
      );

      if (user != null) {
        print("Login successfully");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MapScreenWeb()),
        );
      } else {
        print("Login Failed: Incorrect email or password");
        setState(() {
          errorMessage = "Login Failed: Incorrect email or password";
        });
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code}");
      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is badly formatted.';
        } else if (e.code == 'user-disabled') {
          errorMessage = 'This user has been disabled.';
        } else {
          errorMessage = "Login Failed.";
        }
      });
    } catch (e) {
      print("An unexpected error occurred: $e");
      setState(() {
        errorMessage = "An unexpected error occurred.";
      });
    } finally {
      setState(() {
        isLoading = false; // Stop loading indicator regardless of result
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Color(0xFF007B83);
    final screenSize = MediaQuery.of(context).size;
    bool isMobile = screenSize.width < 960;

    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Hero Section (Only visible on desktop)
          if (!isMobile)
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://source.unsplash.com/random/?road,safety'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      accentColor.withOpacity(0.7),
                      BlendMode.overlay,
                    ),
                  ),
                ),
                child: Center(
                  child: FadeIn(
                    duration: Duration(milliseconds: 1000),
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome to SAFORA',
                            style: GoogleFonts.inter(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Your trusted companion for safer roads and accident prevention.',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Right Panel - Login Form
          Expanded(
            flex: isMobile ? 1 : 4,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 400),
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 40),
                        FadeInDown(
                          duration: Duration(milliseconds: 1000),
                          child: Text(
                            'Sign in to your account',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        FadeInDown(
                          duration: Duration(milliseconds: 1000),
                          child: Text(
                            'Welcome back! Please enter your details',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        SizedBox(height: 32),

                        // Email Field
                        FadeInUp(
                          duration: Duration(milliseconds: 1000),
                          child: _buildTextField(
                            controller: emailController,
                            label: 'Email',
                            hint: 'Ex : test@gmail.com',
                            icon: Icons.email_outlined,
                            accentColor: accentColor,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Password Field
                        FadeInUp(
                          duration: Duration(milliseconds: 1200),
                          child: _buildPasswordField(accentColor),
                        ),
                        SizedBox(height: 8),
                        // Display Error Message
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        SizedBox(height: 8),

                        // Forgot Password
                        FadeInUp(
                          duration: Duration(milliseconds: 1400),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgottenPasswordPageWeb()),
                                );
                              },
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.inter(
                                  color: accentColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Login Button
                        FadeInUp(
                          duration: Duration(milliseconds: 1600),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                login(emailController.text,
                                    passwordController.text, context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Sign in',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Sign Up Link
                        FadeInUp(
                          duration: Duration(milliseconds: 1800),
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpPageWeb()),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: GoogleFonts.inter(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Sign up',
                                      style: GoogleFonts.inter(
                                        color: accentColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color accentColor,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField(Color accentColor) {
    return TextFormField(
      controller: passwordController,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Ex : 123456',
        prefixIcon: Icon(Icons.lock_outline, color: accentColor),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: accentColor,
          ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
    );
  }
}
