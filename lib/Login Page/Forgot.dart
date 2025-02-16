import 'package:flutter/material.dart';

class ForgottenPasswordPage extends StatefulWidget {
  @override
  _ForgottenPasswordPageState createState() => _ForgottenPasswordPageState();
}

class _ForgottenPasswordPageState extends State<ForgottenPasswordPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 60),

                  // Icon or Title
                  Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: accentColor,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Reset Your Password',
                    style: TextStyle(
                      fontSize: 22,
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
                        TextFormField(
                          controller: emailcontroller,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.lock, color: accentColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: accentColor, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // New Password Field
                        TextFormField(
                          controller: newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            hintText: 'Enter a strong password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.lock, color: accentColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: accentColor, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Confirm Password Field
                        TextFormField(
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: 'Re-enter your password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.lock, color: accentColor),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: accentColor, width: 2),
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
                        SizedBox(height: 30),

                        // Reset Password Button
                        ElevatedButton(
                          onPressed: _resetPassword,
                          child: Text(
                            'Reset Password',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
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
    );
  }
}
