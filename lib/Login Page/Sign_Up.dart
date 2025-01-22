import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  int age = 0;
  String vehicleType = '';

  @override
  Widget build(BuildContext context) {
    final Color themeColor = Color(0xFFA1E6E7); // Light gradient theme color
    final Color accentColor = Color(0xFF007B83); // Accent for icons and focused borders

    return Scaffold(
      body: Container(
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
                  Icons.person_add_alt_1,
                  size: 80,
                  color: accentColor,
                ),
                SizedBox(height: 20),
                Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                SizedBox(height: 30),

                // Name Field
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Date of Birth Field
                TextField(
                  controller: dobController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: accentColor),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dobController.text =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        age = DateTime.now().year - pickedDate.year;
                        if (pickedDate.month > DateTime.now().month ||
                            (pickedDate.month == DateTime.now().month &&
                                pickedDate.day > DateTime.now().day)) {
                          age--;
                        }
                      });
                    }
                  },
                ),
                SizedBox(height: 8),
                Text(
                  'Age: $age',
                  style: TextStyle(fontSize: 16, color: accentColor),
                ),
                SizedBox(height: 16),

                // Email Field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'e.g., xxx@gmail.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email, color: accentColor),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),

                // Phone Number Field
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '1234567890',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixText: '+91 ',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),

                // Vehicle Type Dropdown
                DropdownButtonFormField<String>(
                  value: vehicleType.isEmpty ? null : vehicleType,
                  onChanged: (value) {
                    setState(() {
                      vehicleType = value!;
                    });
                  },
                  items: ['Car', 'Bike', 'Truck']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Vehicle Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter a strong password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),

                // Confirm Password Field
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accentColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),

                // Register Button
                ElevatedButton(
                  onPressed: () {
                    if (passwordController.text == confirmPasswordController.text) {
                      print('Registration Successful!');
                      print('Name: ${nameController.text}');
                      print('DOB: ${dobController.text}');
                      print('Age: $age');
                      print('Email: ${emailController.text}');
                      print('Phone: ${phoneController.text}');
                      print('Vehicle Type: $vehicleType');
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
                  },
                  child: Text('Register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}