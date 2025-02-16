import 'dart:io'; // For File I/O
import 'package:flutter/material.dart';
import 'package:validators/validators.dart'; // Form Validation (install: `flutter pub add validators`)
// Animation (install: `flutter pub add animate_do`)
import 'package:image_picker/image_picker.dart'; // Image Picking (install: `flutter pub add image_picker`)
import 'package:shared_preferences/shared_preferences.dart'; // Persistent Storage
import 'package:intl/intl.dart'; // Date Formatting
import 'package:awesome_dialog/awesome_dialog.dart'; // Beautiful Dialogs
import 'package:google_fonts/google_fonts.dart'; // Google Fonts

class ProfileSettingsPageWeb extends StatefulWidget {
  final Color themeColor;
  final Color accentColor;

  const ProfileSettingsPageWeb({
    super.key,
    required this.themeColor,
    required this.accentColor,
  });

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
  Future<void> _loadProfileData() async {
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
      }
    });
  }

  // Save profile data to shared preferences
  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('vehicleType', vehicleTypeController.text);
    await prefs.setString('dob', dobController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('phone', phoneController.text);
    await prefs.setBool('location', isLocationOn);
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
        _calculateAge(dobController.text); // Update Age
      });
    }
  }

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
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
    String? Function(String?) validator,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit $fieldName',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: InputDecoration(
                      labelText: fieldName,
                      hintText: hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: widget.accentColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.all(16),
                      labelStyle:
                          GoogleFonts.inter(color: Colors.grey.shade600),
                      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                    validator: validator,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveProfileData();
                          Navigator.pop(context);
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            animType: AnimType.scale,
                            title: 'Success',
                            titleTextStyle: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            desc: 'Profile updated successfully!',
                            descTextStyle: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                            btnOkText: 'OK',
                            btnOkColor: widget.accentColor,
                            buttonsTextStyle: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            width: 400,
                          ).show();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.accentColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile Settings',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: widget.accentColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              // Left Sidebar with Profile Picture
              Expanded(
                flex: 1,
                child: Card(
                  margin: const EdgeInsets.all(24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildProfilePicture(),
                        const SizedBox(height: 24),
                        Text(
                          nameController.text,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          emailController.text,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildProfileStats(),
                      ],
                    ),
                  ),
                ),
              ),
              // Right side with Profile Details
              Expanded(
                flex: 2,
                child: Card(
                  margin: const EdgeInsets.all(24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ..._buildProfileFields(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.accentColor.withOpacity(0.2),
              width: 4,
            ),
          ),
          child: CircleAvatar(
            radius: 73,
            backgroundColor: widget.accentColor.withOpacity(0.1),
            backgroundImage:
                _profileImage != null ? FileImage(_profileImage!) : null,
            child: _profileImage == null
                ? Icon(Icons.person, size: 64, color: widget.accentColor)
                : null,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildStatItem(
            icon: Icons.calendar_today,
            label: 'Member Since',
            value: '2024',
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            icon: Icons.directions_car,
            label: 'Vehicle Type',
            value: vehicleTypeController.text,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: widget.accentColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildProfileFields() {
    return [
      _buildProfileField(
        context,
        title: 'Name',
        controller: nameController,
        hint: 'Enter your name',
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
            return 'Name can only contain letters and spaces';
          }
          return null;
        },
      ),
      const Divider(height: 32),
      _buildProfileField(
        context,
        title: 'Vehicle Type',
        controller: vehicleTypeController,
        hint: 'Enter your vehicle type',
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your vehicle type';
          }
          return null;
        },
      ),
      const Divider(height: 32),
      _buildProfileField(
        context,
        title: 'Date of Birth (Age)',
        controller: dobController,
        hint: 'YYYY-MM-DD',
        keyboardType: TextInputType.datetime,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your Date of Birth';
          }
          return null;
        },
        onTap: () => _selectDate(context),
      ),
      const Divider(height: 32),
      _buildProfileField(
        context,
        title: 'Email ID',
        controller: emailController,
        hint: 'Enter your email',
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
      const Divider(height: 32),
      _buildProfileField(
        context,
        title: 'Phone Number',
        controller: phoneController,
        hint: 'Enter your phone number',
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your phone number';
          }
          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
            return 'Please enter a valid 10-digit phone number';
          }
          return null;
        },
      ),
      const Divider(height: 32),
      SwitchListTile(
        title: Text(
          'Location Services',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          isLocationOn ? 'Enabled' : 'Disabled',
          style: GoogleFonts.inter(color: Colors.grey[600]),
        ),
        value: isLocationOn,
        activeColor: widget.accentColor,
        onChanged: (value) {
          setState(() => isLocationOn = value);
          _saveProfileData(); // Save Location setting
        },
      ),
    ];
  }

  Widget _buildProfileField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            controller.text,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ),
        trailing: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.edit_outlined,
                  color: widget.accentColor, size: 20),
              onPressed: () => _editField(
                title,
                controller,
                hint,
                keyboardType,
                validator,
              ),
              tooltip: 'Edit $title',
            ),
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: widget.accentColor.withOpacity(0.05),
      ),
    );
  }
}
