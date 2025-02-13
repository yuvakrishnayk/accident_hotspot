import 'package:accident_hotspot/Maps/Map_Screen_web.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:animate_do/animate_do.dart'; // Animation (install: `flutter pub add animate_do`)
import 'package:awesome_dialog/awesome_dialog.dart'; //Beautiful Dialogs
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; //Phone Number Formatting (install: `flutter pub add mask_text_input_formatter`)
// Terms and Conditions

class SignUpPageWeb extends StatefulWidget {
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
    final Color themeColor = Color(0xFFA1E6E7);
    final Color accentColor = Color(0xFF007B83);

    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // Determine if we're on a mobile device
    bool isMobile = screenWidth < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themeColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: FadeInUp(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 800),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_add_alt_1,
                              size: 80,
                              color: accentColor,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Create Your Account',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                            SizedBox(height: 30),

                            // Wrap form fields in rows for desktop layout
                            Wrap(
                              spacing: 20,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: [
                                SizedBox(
                                  width: isMobile ? double.infinity : 350,
                                  child: TextFormField(
                                    controller: nameController,
                                    decoration: _inputDecoration(
                                        'Name',
                                        'Enter your name',
                                        Icons.person,
                                        accentColor),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      if (!RegExp(r'^[a-zA-Z\s]+$')
                                          .hasMatch(value)) {
                                        return 'Name can only contain letters and spaces';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: isMobile ? double.infinity : 350,
                                  child: TextFormField(
                                    controller: dobController,
                                    decoration: _inputDecoration(
                                        'Date of Birth',
                                        'YYYY-MM-DD',
                                        Icons.calendar_today,
                                        accentColor),
                                    readOnly: true,
                                    onTap: () => _selectDate(context),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select your date of birth';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: isMobile ? double.infinity : 350,
                                  child: TextFormField(
                                    controller: emailController,
                                    decoration: _inputDecoration(
                                        'Email',
                                        'e.g., xxx@gmail.com',
                                        Icons.email,
                                        accentColor),
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
                                  ),
                                ),
                                SizedBox(
                                  width: isMobile ? double.infinity : 350,
                                  child: TextFormField(
                                    controller: phoneController,
                                    decoration: _inputDecoration(
                                        'Phone Number',
                                        '(123) 456-7890',
                                        Icons.phone,
                                        accentColor),
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
                                  ),
                                ),
                                SizedBox(
                                  width: isMobile ? double.infinity : 350,
                                  child: DropdownButtonFormField<String>(
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
                                        'Vehicle Type',
                                        null,
                                        Icons.directions_car,
                                        accentColor),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a vehicle type';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: isMobile ? double.infinity : 350,
                                  child: TextFormField(
                                    controller: passwordController,
                                    decoration: _passwordDecoration(
                                        'Password',
                                        'Enter a strong password',
                                        accentColor,
                                        isPasswordVisible, () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    }),
                                    obscureText: !isPasswordVisible,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      if (value.length < 8) {
                                        return 'Password must be at least 8 characters';
                                      }
                                      if (!RegExp(
                                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                          .hasMatch(value)) {
                                        return 'Password must contain at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: isMobile ? double.infinity : 350,
                                  child: TextFormField(
                                    controller: confirmPasswordController,
                                    decoration: _passwordDecoration(
                                        'Confirm Password',
                                        'Re-enter your password',
                                        accentColor,
                                        isConfirmPasswordVisible, () {
                                      setState(() {
                                        isConfirmPasswordVisible =
                                            !isConfirmPasswordVisible;
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
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Terms and Conditions Checkbox
                            Row(
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
                                    style: TextStyle(color: accentColor),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 32),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: ElevatedButton(
                                onPressed: _termsChecked ? _handleSubmit : null,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 16),
                                  child: Text(
                                    'Register',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor:
                                      Colors.grey[400], // Disabled button color
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
          btnOkOnPress: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => MapScreenWeb()));
          },
        )..show();
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
