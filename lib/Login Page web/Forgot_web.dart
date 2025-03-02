import 'package:accident_hotspot/Functions/auth_func.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class ForgottenPasswordPageWeb extends StatefulWidget {
  const ForgottenPasswordPageWeb({Key? key}) : super(key: key);

  @override
  State<ForgottenPasswordPageWeb> createState() =>
      _ForgottenPasswordPageWebState();
}

class _ForgottenPasswordPageWebState extends State<ForgottenPasswordPageWeb> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  void resetPassword(String email) async {
    final AuthFunc _auth = AuthFunc();
    await _auth.resetPassword(email);
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      // Password reset logic here using emailController.text
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success, // Or any other type you prefer
        animType: AnimType.rightSlide,
        title: 'Password Reset Email Sent', // Improved title
        desc:
            'A password reset link has been sent to ${emailController.text}. Please check your inbox and follow the instructions to reset your password.',
        width:
            MediaQuery.of(context).size.width * 0.4, // More informative message
        btnOkOnPress: () {
          // Optional: Navigate to a different screen (e.g., login page)
          Navigator.of(context).pop(); // Dismiss the dialog
        },
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = const Color(0xFFA1E6E7); // Theme color
    final Color accentColor = const Color(0xFF007B83); // Darker accent for text
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive variables
    double iconSize = screenWidth < 600 ? 60 : 80;
    double titleFontSize = screenWidth < 600 ? 18 : 22;
    double buttonFontSize = screenWidth < 600 ? 16 : 18;
    double paddingHorizontal = screenWidth < 600
        ? 16
        : screenWidth * 0.2; // Adjust padding for wider screens
    double inputFieldWidth = screenWidth < 600
        ? double.infinity
        : 400; // Limit input field width on larger screens

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
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: paddingHorizontal, vertical: 16.0),
            child: Center(
              // Center content for larger screens
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  // Constrain width to prevent overly stretched content
                  constraints: BoxConstraints(
                      maxWidth: 600), //  Adjust max width as needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),

                      // Icon or Title
                      Icon(
                        Icons.lock_reset,
                        size: iconSize,
                        color: accentColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Forgot Your Password?',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enter your email to reset your password.',
                        style: TextStyle(
                          fontSize: titleFontSize - 6,
                          fontWeight: FontWeight.w500,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Form for email field and Reset Password button
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              width: inputFieldWidth,
                              child: TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Enter your email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon:
                                      Icon(Icons.email, color: accentColor),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: accentColor, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Reset Password Button
                            ElevatedButton(
                              onPressed: () {
                                resetPassword(emailController.text);
                                _resetPassword();
                              },
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
                              child: Text(
                                'Reset Password',
                                style: TextStyle(
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
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
