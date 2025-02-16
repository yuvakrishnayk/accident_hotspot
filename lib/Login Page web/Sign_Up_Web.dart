import 'package:accident_hotspot/Functions/auth_func.dart';
import 'package:accident_hotspot/Maps/Map_Screen_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:animate_do/animate_do.dart'; // Animation (install: `flutter pub add animate_do`)
import 'package:awesome_dialog/awesome_dialog.dart'; //Beautiful Dialogs
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; //Phone Number Formatting (install: `flutter pub add mask_text_input_formatter`)
import 'package:google_fonts/google_fonts.dart'; // Google Fonts (install: `flutter pub add google_fonts`)

class SignUpPageWeb extends StatefulWidget {
  const SignUpPageWeb({super.key});

  @override
  _SignUpPageWebState createState() => _SignUpPageWebState();
}

class _SignUpPageWebState extends State<SignUpPageWeb> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  void Signup(String email, password) async {
    final AuthFunc _auth = AuthFunc();
    UserCredential? user = await _auth.signup(email, password);
    if (user != null) {
      print('User Register Successfully');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registered successfully')));
    } else {
      print('User not Register Successfully');
    }
  }

  int age = 0;
  String? vehicleType;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool _termsChecked = false; // terms and conditions

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Phone number formatter
  final phoneFormatter = MaskTextInputFormatter(
    mask: '(###) ###-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Color(0xFF007B83);

    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Determine if we're on a mobile device
    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Hero Section (Only visible on desktop)
          if (!isMobile)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://source.unsplash.com/random/?safety,road'),
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
                            'Join SAFORA Today',
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
                            'Help us make roads safer by being part of our community.',
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

          // Right Panel - Sign Up Form
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? screenWidth * 0.9 : 800,
                    ),
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Center(
                            child: Column(
                              children: [
                                SizedBox(height: 60),
                                Text(
                                  'Create Your Account',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Join our community of safe drivers',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 48),

                          // Form Fields
                          Wrap(
                            spacing: 24,
                            runSpacing: 24,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildFormField(
                                width: isMobile ? double.infinity : 350,
                                child: _buildNameField(accentColor),
                              ),
                              _buildFormField(
                                width: isMobile ? double.infinity : 350,
                                child: _buildDOBField(accentColor),
                              ),
                              _buildFormField(
                                width: isMobile ? double.infinity : 350,
                                child: _buildEmailField(accentColor),
                              ),
                              _buildFormField(
                                width: isMobile ? double.infinity : 350,
                                child: _buildPhoneField(accentColor),
                              ),
                              _buildFormField(
                                width: isMobile ? double.infinity : 350,
                                child: _buildVehicleTypeField(accentColor),
                              ),
                              _buildFormField(
                                width: isMobile ? double.infinity : 350,
                                child: _buildPasswordField(accentColor),
                              ),
                              _buildFormField(
                                width: isMobile ? double.infinity : 350,
                                child: _buildConfirmPasswordField(accentColor),
                              ),
                            ],
                          ),

                          SizedBox(height: 32),

                          // Terms and Privacy
                          Center(
                            child: _buildTermsAndPrivacy(accentColor),
                          ),

                          SizedBox(height: 32),

                          // Sign Up Button
                          Center(
                            child: _buildSignUpButton(accentColor),
                          ),

                          SizedBox(height: 24),

                          // Login Link
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Already have an account? Sign in',
                                style: GoogleFonts.inter(
                                  color: accentColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({required double width, required Widget child}) {
    return SizedBox(
      width: width,
      child: child,
    );
  }

  Widget _buildNameField(Color accentColor) {
    return TextFormField(
      controller: nameController,
      decoration: _inputDecoration(
          'Name', 'Enter your name', Icons.person, accentColor),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
          return 'Name can only contain letters and spaces';
        }
        return null;
      },
    );
  }

  Widget _buildDOBField(Color accentColor) {
    return TextFormField(
      controller: dobController,
      decoration: _inputDecoration(
          'Date of Birth', 'YYYY-MM-DD', Icons.calendar_today, accentColor),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your date of birth';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(Color accentColor) {
    return TextFormField(
      controller: emailController,
      decoration: _inputDecoration(
          'Email', 'e.g., xxx@gmail.com', Icons.email, accentColor),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!isEmail(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(Color accentColor) {
    return TextFormField(
      controller: phoneController,
      decoration: _inputDecoration(
          'Phone Number', '(123) 456-7890', Icons.phone, accentColor),
      keyboardType: TextInputType.phone,
      inputFormatters: [phoneFormatter],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        if (value.length < 14) {
          return 'Please enter a valid 10-digit phone number';
        }
        return null;
      },
    );
  }

  Widget _buildVehicleTypeField(Color accentColor) {
    return DropdownButtonFormField<String>(
      value: vehicleType,
      onChanged: (value) {
        setState(() {
          vehicleType = value;
        });
      },
      items: ['Car', 'Bike', 'Truck']
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
          .toList(),
      decoration: _inputDecoration(
          'Vehicle Type', null, Icons.directions_car, accentColor),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a vehicle type';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(Color accentColor) {
    return TextFormField(
      controller: passwordController,
      decoration: _passwordDecoration(
          'Password', 'Enter a strong password', accentColor, isPasswordVisible,
          () {
        setState(() {
          isPasswordVisible = !isPasswordVisible;
        });
      }),
      obscureText: !isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }

        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(Color accentColor) {
    return TextFormField(
      controller: confirmPasswordController,
      decoration: _passwordDecoration('Confirm Password',
          'Re-enter your password', accentColor, isConfirmPasswordVisible, () {
        setState(() {
          isConfirmPasswordVisible = !isConfirmPasswordVisible;
        });
      }),
      obscureText: !isConfirmPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildTermsAndPrivacy(Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: _termsChecked,
          activeColor: accentColor,
          onChanged: (bool? value) {
            setState(() {
              _termsChecked = value!;
            });
          },
        ),
        GestureDetector(
          onTap: () => _showTermsDialog(context),
          child: Text(
            'I agree to the Terms and Conditions',
            style: GoogleFonts.inter(color: accentColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(Color accentColor) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton(
        onPressed: () {
          Signup(emailController.text, passwordController.text);
          _handleSubmit();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[400], // Disabled button color
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          child: Text(
            'Register',
            style: GoogleFonts.inter(fontSize: 18),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label, String? hint, IconData icon, Color accentColor) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: accentColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accentColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  InputDecoration _passwordDecoration(String label, String hint,
      Color accentColor, bool isVisible, VoidCallback onToggle) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(Icons.lock, color: accentColor),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility_off : Icons.visibility,
          color: accentColor,
        ),
        onPressed: onToggle,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accentColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        age = DateTime.now().year - pickedDate.year;
        if (pickedDate.month > DateTime.now().month ||
            (pickedDate.month == DateTime.now().month &&
                pickedDate.day > DateTime.now().day)) {
          age--;
        }
      });
    }
  }

  Future<void> _showTermsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terms and Conditions'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Please read and agree to our terms and conditions:'),
                Text(
                    '1. You agree to provide accurate and complete information during registration.\n2. You are responsible for maintaining the confidentiality of your account.\n3. ... (Add more terms here)'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Disagree'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _termsChecked = false;
                });
              },
            ),
            TextButton(
              child: const Text('Agree'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _termsChecked = true;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Here you would typically send the data to your backend

      //Simulate Signup process
      Future.delayed(Duration(seconds: 2), () {
        // Show Awesome Success Dialog
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Success',
          desc: 'Registration completed successfully!',
          width: MediaQuery.of(context).size.width * 0.4,
          btnOkOnPress: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => MapScreenWeb()));
          },
        ).show();
      });
    } else {
      //Show Flushbar error
      Flushbar(
        message: "Please correct the errors in the form.",
        duration: Duration(seconds: 3),
        icon: Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
        backgroundColor: Colors.grey[800]!,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }
}
