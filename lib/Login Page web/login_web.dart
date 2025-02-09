import 'package:accident_hotspot/Login%20Page%20web/Forgot_web.dart';
import 'package:accident_hotspot/Login%20Page%20web/Sign_Up_Web.dart';
import 'package:accident_hotspot/Maps/Map_Screen_web.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Animation Package (install: `flutter pub add animate_do`)
import 'package:validators/validators.dart'; // Form Validation (install: `flutter pub add validators`)
import 'package:another_flushbar/flushbar.dart'; // Better Snackbars(install: `flutter pub add another_flushbar`)

class LoginPageWeb extends StatefulWidget {
  @override
  _LoginPageWebState createState() => _LoginPageWebState();
}

class _LoginPageWebState extends State<LoginPageWeb> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true; // For password visibility toggle
  final _formKey = GlobalKey<FormState>(); //Key For Validating Form
  bool _isLoading = false; // For indicating loading state

  @override
  Widget build(BuildContext context) {
    final Color themeColor = Color(0xFFA1E6E7); // Theme color
    final Color accentColor =
        Color(0xFF007B83); // Darker accent for links and text

    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [themeColor, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: screenWidth > 600 ? 500 : screenWidth * 0.9,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey, // Set the Form Key
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FadeInDown(
                        duration: Duration(milliseconds: 1100),
                        child: Image.network(
                          'https://i.ibb.co/dwBJ16GL/iconn-removebg-preview.png',
                          scale: 2,
                        ),
                      ),
                      SizedBox(height: 20),
                      FadeIn(
                        delay: Duration(milliseconds: 500),
                        child: Text(
                          'SAFORA',
                          style: TextStyle(
                            fontSize: screenWidth > 600 ? 24 : 22,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 40),

                      // Email TextField (With Validation)
                      FadeInLeft(
                        duration: Duration(milliseconds: 600),
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.email, color: accentColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: accentColor, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!isEmail(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16),

                      // Password TextField (With Validation & Visibility Toggle)
                      FadeInRight(
                        duration: Duration(milliseconds: 600),
                        child: TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.lock, color: accentColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: accentColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: accentColor, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16),

                      // Forgot Password Link (Animated)
                      FadeIn(
                        delay: Duration(milliseconds: 700),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ForgottenPasswordPageWeb()),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // Login Button (Animated, with Loading State)
                      FadeInUp(
                        duration: Duration(milliseconds: 600),
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null // Disable button when loading
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    // Form is valid
                                    setState(() {
                                      _isLoading = true; //Show Loading state
                                    });
                                    // Simulate login process
                                    Future.delayed(Duration(seconds: 2), () {
                                      setState(() {
                                        _isLoading = false; // Hide loading
                                      });
                                      Navigator.of(context).pushReplacement(
                                        // Prevents back button
                                        MaterialPageRoute(
                                          builder: (context) => MapScreenWeb(),
                                        ),
                                      );
                                    });
                                  } else {
                                    // Form is invalid
                                    Flushbar(
                                      message:
                                          "Please correct the errors in the form.",
                                      duration: Duration(seconds: 3),
                                      icon: Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      ),
                                      backgroundColor: Colors.grey[800]!,
                                      flushbarPosition: FlushbarPosition.TOP,
                                    ).show(context);
                                  }
                                },
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Sign Up Link (Animated)
                      FadeIn(
                        delay: Duration(milliseconds: 800),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPageWeb()),
                            );
                          },
                          child: Text(
                            'Don\'t have an account? Sign Up',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      //Animated decoration
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
