import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  final Color themeColor;
  final Color accentColor;

  const NotificationSettingsPage({
    Key? key,
    required this.themeColor,
    required this.accentColor,
  }) : super(key: key);

  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool isNotificationOn = true;
  String selectedStyle = "Badge";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: widget.accentColor,
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.themeColor.withOpacity(0.8), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Enable Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Receive important alerts and updates',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: isNotificationOn,
                    onChanged: (value) =>
                        setState(() => isNotificationOn = value),
                    activeColor: widget.accentColor,
                  ),
                ],
              ),
            ),
            if (!isNotificationOn)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Notifications are currently disabled',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Notification Style',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.accentColor,
                      ),
                    ),
                  ),
                  RadioListTile<String>(
                    title: const Text('Badge'),
                    subtitle: const Text('Show notification count on app icon'),
                    value: "Badge",
                    groupValue: selectedStyle,
                    onChanged: (value) =>
                        setState(() => selectedStyle = value!),
                    activeColor: widget.accentColor,
                  ),
                  RadioListTile<String>(
                    title: const Text('Pop-ups'),
                    subtitle: const Text('Show floating notification alerts'),
                    value: "Pop-ups",
                    groupValue: selectedStyle,
                    onChanged: (value) =>
                        setState(() => selectedStyle = value!),
                    activeColor: widget.accentColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Current Style: $selectedStyle',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
