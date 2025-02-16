import 'package:flutter/material.dart';

class ProfileSettingsPage extends StatefulWidget {
  final Color themeColor;
  final Color accentColor;

  const ProfileSettingsPage({
    super.key,
    required this.themeColor,
    required this.accentColor,
  });

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool isLocationOn = true;
  final Map<String, String> profileFields = {
    'Name': 'John Doe',
    'Vehicle Type': 'Car',
    'Date of Birth (Age)': '01/01/1990 (33)',
    'Email ID': 'johndoe@gmail.com',
    'Phone Number': '+91 9876543210',
  };

  void _editField(String fieldName, String currentValue) {
    final TextEditingController controller =
        TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Edit $fieldName'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: fieldName,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => profileFields[fieldName] = controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.themeColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                        backgroundColor: widget.accentColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: widget.accentColor,
                        ),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: widget.accentColor,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...profileFields.entries.map((entry) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          subtitle: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: widget.accentColor),
                            onPressed: () => _editField(entry.key, entry.value),
                          ),
                        ),
                      )),
                  const Divider(),
                  SwitchListTile(
                    title: const Text(
                      'Location Services',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      isLocationOn ? 'Enabled' : 'Disabled',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    value: isLocationOn,
                    activeColor: widget.accentColor,
                    onChanged: (value) => setState(() => isLocationOn = value),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
