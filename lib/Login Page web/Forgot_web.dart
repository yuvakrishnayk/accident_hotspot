import 'package:flutter/material.dart';

class ForgottenPasswordPageWeb extends StatefulWidget {
  const ForgottenPasswordPageWeb({super.key});

  @override
  State<ForgottenPasswordPageWeb> createState() =>
      _ForgottenPasswordPageWebState();
}

class _ForgottenPasswordPageWebState extends State<ForgottenPasswordPageWeb> {
  final TextEditingController newPasswordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isPasswordStrong(String password) {
    // Strong password criteria: At least 8 characters, includes letters, numbers, and symbols.
    final strongPasswordPattern =
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%?&])[A-Za-z\d@$!%?&]{8,}$';
    return RegExp(strongPasswordPattern).hasMatch(password);
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      if (newPasswordController.text == confirmPasswordController.text) {
        // Password reset logic here
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Your password has been reset successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Passwords do not match!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = Color(0xFFA1E6E7); // Theme color
    final Color accentColor = Color(0xFF007B83); // Darker accent for text
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
                      SizedBox(height: 60),

                      // Icon or Title
                      Icon(
                        Icons.lock_reset,
                        size: iconSize,
                        color: accentColor,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Reset Your Password',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      SizedBox(height: 40),

                      // Form for password fields
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              width: inputFieldWidth,
                              child: TextFormField(
                                controller: emailcontroller,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'Enter your Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon:
                                      Icon(Icons.lock, color: accentColor),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: accentColor, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // New Password Field
                            SizedBox(
                              width: inputFieldWidth,
                              child: TextFormField(
                                controller: newPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  hintText: 'Enter a strong password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon:
                                      Icon(Icons.lock, color: accentColor),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: accentColor, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a new password';
                                  }
                                  if (!_isPasswordStrong(value)) {
                                    return 'Password must be at least 8 characters and include letters, numbers, and symbols';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 16),

                            // Confirm Password Field
                            SizedBox(
                              width: inputFieldWidth,
                              child: TextFormField(
                                controller: confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  hintText: 'Re-enter your password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon:
                                      Icon(Icons.lock, color: accentColor),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: accentColor, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 30),

                            // Reset Password Button
                            ElevatedButton(
                              onPressed: _resetPassword,
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
                      SizedBox(height: 20),
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
