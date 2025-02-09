import 'dart:io'; // For File I/O
import 'package:flutter/material.dart';
import 'package:validators/validators.dart'; // Form Validation (install: `flutter pub add validators`)
import 'package:animate_do/animate_do.dart'; // Animation (install: `flutter pub add animate_do`)
import 'package:image_picker/image_picker.dart'; // Image Picking (install: `flutter pub add image_picker`)
import 'package:shared_preferences/shared_preferences.dart'; // Persistent Storage
import 'package:intl/intl.dart'; // Date Formatting
import 'package:awesome_dialog/awesome_dialog.dart'; // Beautifull Dialogs

class ProfileSettingsPageWeb extends StatefulWidget {
  final Color themeColor;
  final Color accentColor;

  const ProfileSettingsPageWeb(
      {Key? key, required this.themeColor, required this.accentColor})
      : super(key: key);

  @override
  _ProfileSettingsPageWebState createState() => _ProfileSettingsPageWebState();
}

class _ProfileSettingsPageWebState extends State<ProfileSettingsPageWeb> {
  bool isLocationOn = true;
  File? _profileImage; // To store the selected profile image
  final _formKey = GlobalKey<FormState>(); // For Form Validation
  final TextEditingController nameController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  int age = 0; // Age calculation

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load profile data from shared preferences
  _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? 'John Doe';
      vehicleTypeController.text = prefs.getString('vehicleType') ?? 'Car';
      dobController.text = prefs.getString('dob') ?? '1990-01-01';
      emailController.text = prefs.getString('email') ?? 'johndoe@gmail.com';
      phoneController.text = prefs.getString('phone') ?? '+91 9876543210';
      isLocationOn = prefs.getBool('location') ?? true;
      if (dobController.text.isNotEmpty) {
        _calculateAge(dobController.text);
      } //Calculate age from the date.
    });
  }

  // Save profile data to shared preferences
  _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', nameController.text);
    prefs.setString('vehicleType', vehicleTypeController.text);
    prefs.setString('dob', dobController.text);
    prefs.setString('email', emailController.text);
    prefs.setString('phone', phoneController.text);
    prefs.setBool('location', isLocationOn);
  }

  // Calculate age from DOB
  void _calculateAge(String dob) {
    DateTime birthDate = DateFormat('yyyy-MM-dd').parse(dob);
    setState(() {
      age = DateTime.now().year - birthDate.year;
      if (birthDate.month > DateTime.now().month ||
          (birthDate.month == DateTime.now().month &&
              birthDate.day > DateTime.now().day)) {
        age--;
      }
    });
  }

  // Select date from date picker
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
        _calculateAge(dobController.text); //Update Age
      });
    }
  }

  // Function to pick an image from gallery
  Future _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image != null) {
        _profileImage = File(image.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Show edit dialog
  void _editField(
      String fieldName,
      TextEditingController controller,
      String hint,
      TextInputType keyboardType,
      String? Function(String?) validator) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $fieldName'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: fieldName,
                hintText: hint,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontSize: 16),
              validator: validator,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveProfileData(); // Save the form
                  Navigator.pop(context);
                  // Awesome Success Dialog
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.success,
                    animType: AnimType.rightSlide,
                    title: 'Success',
                    desc: 'Profile updated successfully!',
                    btnOkOnPress: () {},
                  )..show();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: widget.accentColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FadeInUp(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor:
                                widget.accentColor.withOpacity(0.1),
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? Icon(Icons.person,
                                    size: 60, color: widget.accentColor)
                                : null,
                          ),
                          InkWell(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: widget.accentColor,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        title: const Text(
                          'Name',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        subtitle: Text(
                          nameController.text,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: widget.accentColor),
                          onPressed: () => _editField(
                            'Name',
                            nameController,
                            'Enter your name',
                            TextInputType.name,
                            (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                                return 'Name can only contain letters and spaces';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text(
                          'Vehicle Type',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        subtitle: Text(
                          vehicleTypeController.text,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: widget.accentColor),
                          onPressed: () => _editField(
                            'Vehicle Type',
                            vehicleTypeController,
                            'Enter your vehicle type',
                            TextInputType.text,
                            (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your vehicle type';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text(
                          'Date of Birth (Age)',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        subtitle: Text(
                          '${dobController.text} ($age)',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: widget.accentColor),
                          onPressed: () => _editField(
                            'Date of Birth',
                            dobController,
                            'YYYY-MM-DD',
                            TextInputType.datetime,
                            (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Date of Birth';
                              }
                              return null;
                            },
                          ),
                        ),
                        onTap: () =>
                            _selectDate(context), // Show Date Picker on Tap
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text(
                          'Email ID',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        subtitle: Text(
                          emailController.text,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: widget.accentColor),
                          onPressed: () => _editField(
                            'Email ID',
                            emailController,
                            'Enter your email',
                            TextInputType.emailAddress,
                            (value) {
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
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text(
                          'Phone Number',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        subtitle: Text(
                          phoneController.text,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: widget.accentColor),
                          onPressed: () => _editField(
                            'Phone Number',
                            phoneController,
                            'Enter your phone number',
                            TextInputType.phone,
                            (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                return 'Please enter a valid 10-digit phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text(
                          'Location Services',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          isLocationOn ? 'Enabled' : 'Disabled',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        value: isLocationOn,
                        activeColor: widget.accentColor,
                        onChanged: (value) {
                          setState(() => isLocationOn = value);
                          _saveProfileData(); // Save Location setting
                        },
                      ),
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
