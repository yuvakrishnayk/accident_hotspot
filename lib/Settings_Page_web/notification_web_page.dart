import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Animation Package (install: `flutter pub add animate_do`)
import 'package:google_fonts/google_fonts.dart'; // Google Fonts Package (install: `flutter pub add google_fonts`)

class NotificationSettingsPageWeb extends StatefulWidget {
  final Color themeColor;
  final Color accentColor;

  const NotificationSettingsPageWeb({
    Key? key,
    this.themeColor = const Color.fromARGB(255, 1, 100, 90), // Default color
    this.accentColor = Colors.teal, // Default accent
  }) : super(key: key);

  @override
  _NotificationSettingsPageWebState createState() =>
      _NotificationSettingsPageWebState();
}

class _NotificationSettingsPageWebState
    extends State<NotificationSettingsPageWeb> {
  bool isNotificationOn = true;
  String selectedStyle = "Badge";
  bool showDetailedSettings = false; // New feature: detailed settings

  // New features:  Individual notification toggles
  bool newMessages = true;
  bool friendRequests = true;
  bool appUpdates = true;
  bool promotionalOffers = true;

  TextStyle get headerStyle => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: widget.themeColor,
      );

  TextStyle get titleStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  TextStyle get subtitleStyle => GoogleFonts.inter(
        fontSize: 14,
        color: Colors.grey[600],
      );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: FadeInDown(
          // Animate Appbar Title
          child: Text(
            'Notification Settings',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: widget.themeColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Row(
        children: [
          if (!isMobile)
            // Left Panel - Hero Section
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.themeColor,
                      widget.accentColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_active,
                          size: 80,
                          color: Colors.white,
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Stay Connected',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Customize your notification preferences to stay updated with what matters most to you.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Right Panel - Settings Content
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: ListView(
                    padding: EdgeInsets.all(32),
                    children: [
                      _buildMainToggle(),
                      SizedBox(height: 24),
                      _buildNotificationStyle(),
                      SizedBox(height: 24),
                      _buildDetailedSettings(),
                      SizedBox(height: 24),
                      _buildSoundSettings(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainToggle() {
    return FadeInUp(
      duration: Duration(milliseconds: 500),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('General Settings', style: headerStyle),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Enable Notifications', style: titleStyle),
                subtitle: Text(
                  'Receive important alerts and updates',
                  style: subtitleStyle,
                ),
                value: isNotificationOn,
                onChanged: (value) => setState(() => isNotificationOn = value),
                activeColor: widget.themeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationStyle() {
    return FadeInUp(
      duration: Duration(milliseconds: 500),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Notification Style',
                style: headerStyle,
              ),
            ),
            RadioListTile<String>(
              title: Text('Badge', style: titleStyle),
              subtitle: Text(
                'Show notification count on app icon',
                style: subtitleStyle,
              ),
              value: "Badge",
              groupValue: selectedStyle,
              onChanged: (value) => setState(() => selectedStyle = value!),
              activeColor: widget.themeColor,
            ),
            RadioListTile<String>(
              title: Text('Pop-ups', style: titleStyle),
              subtitle: Text(
                'Show floating notification alerts',
                style: subtitleStyle,
              ),
              value: "Pop-ups",
              groupValue: selectedStyle,
              onChanged: (value) => setState(() => selectedStyle = value!),
              activeColor: widget.themeColor,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
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
    );
  }

  Widget _buildDetailedSettings() {
    return FadeInUp(
      duration: Duration(milliseconds: 500),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            ListTile(
              title: Text("Detailed Notification Settings", style: titleStyle),
              subtitle: Text(
                "Customize which types of notifications you receive.",
                style: subtitleStyle,
              ),
              trailing: Switch(
                value: showDetailedSettings,
                onChanged: (value) {
                  setState(() {
                    showDetailedSettings = value;
                  });
                },
                activeColor: widget.themeColor,
              ),
            ),
            if (showDetailedSettings)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text("New Messages", style: titleStyle),
                      value: newMessages,
                      onChanged: (value) {
                        setState(() {
                          newMessages = value;
                        });
                      },
                      activeColor: widget.themeColor,
                    ),
                    SwitchListTile(
                      title: Text("Friend Requests", style: titleStyle),
                      value: friendRequests,
                      onChanged: (value) {
                        setState(() {
                          friendRequests = value;
                        });
                      },
                      activeColor: widget.themeColor,
                    ),
                    SwitchListTile(
                      title: Text("App Updates", style: titleStyle),
                      value: appUpdates,
                      onChanged: (value) {
                        setState(() {
                          appUpdates = value;
                        });
                      },
                      activeColor: widget.themeColor,
                    ),
                    SwitchListTile(
                      title: Text("Promotional Offers", style: titleStyle),
                      value: promotionalOffers,
                      onChanged: (value) {
                        setState(() {
                          promotionalOffers = value;
                        });
                      },
                      activeColor: widget.themeColor,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundSettings() {
    return FadeInUp(
      duration: Duration(milliseconds: 500),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification Sound',
                style: headerStyle,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select Sound',
                ),
                value: 'Default',
                items: <String>['Default', 'Chime', 'Alert', 'None']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    // soundSetting = newValue!;  // Assuming you'll add a soundSetting variable.
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
