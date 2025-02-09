import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Animation Package (install: `flutter pub add animate_do`)

class NotificationSettingsPageWeb extends StatefulWidget {
  final Color themeColor;
  final Color accentColor;

  const NotificationSettingsPageWeb({
    Key? key,
    required this.themeColor,
    required this.accentColor,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          // Animate Appbar Title
          child: const Text(
            'Notification Settings',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: widget.accentColor,
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        // Center the content on web
        child: ConstrainedBox(
          // Limit width for better readability on larger screens
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.themeColor.withOpacity(0.8), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              children: [
                FadeInUp(
                  // Wrap Card with FadeInUp Animation
                  child: Card(
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
                ),
                if (!isNotificationOn)
                  FadeInUp(
                    // Wrap Padding with FadeInUp Animation
                    child: Padding(
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
                  ),
                const SizedBox(height: 24),
                FadeInUp(
                  // Wrap Card with FadeInUp Animation
                  child: Card(
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
                          subtitle:
                              const Text('Show notification count on app icon'),
                          value: "Badge",
                          groupValue: selectedStyle,
                          onChanged: (value) =>
                              setState(() => selectedStyle = value!),
                          activeColor: widget.accentColor,
                        ),
                        RadioListTile<String>(
                          title: const Text('Pop-ups'),
                          subtitle:
                              const Text('Show floating notification alerts'),
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
                ),
                const SizedBox(height: 24),

                // New Feature:  Detailed Notification Settings
                FadeInUp(
                  // Wrap Card with FadeInUp Animation
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(children: [
                      ListTile(
                        title: const Text("Detailed Notification Settings"),
                        subtitle: const Text(
                            "Customize which types of notifications you receive."),
                        trailing: Switch(
                          value: showDetailedSettings,
                          onChanged: (value) {
                            setState(() {
                              showDetailedSettings = value;
                            });
                          },
                          activeColor: widget.accentColor,
                        ),
                      ),
                      if (showDetailedSettings)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text("New Messages"),
                                value: newMessages,
                                onChanged: (value) {
                                  setState(() {
                                    newMessages = value;
                                  });
                                },
                                activeColor: widget.accentColor,
                              ),
                              SwitchListTile(
                                title: const Text("Friend Requests"),
                                value: friendRequests,
                                onChanged: (value) {
                                  setState(() {
                                    friendRequests = value;
                                  });
                                },
                                activeColor: widget.accentColor,
                              ),
                              SwitchListTile(
                                title: const Text("App Updates"),
                                value: appUpdates,
                                onChanged: (value) {
                                  setState(() {
                                    appUpdates = value;
                                  });
                                },
                                activeColor: widget.accentColor,
                              ),
                              SwitchListTile(
                                title: const Text("Promotional Offers"),
                                value: promotionalOffers,
                                onChanged: (value) {
                                  setState(() {
                                    promotionalOffers = value;
                                  });
                                },
                                activeColor: widget.accentColor,
                              ),
                            ],
                          ),
                        )
                    ]),
                  ),
                ),
                // New feature:  Notification Sound Settings
                const SizedBox(height: 24),
                FadeInUp(
                  // Wrap Card with FadeInUp Animation
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notification Sound',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: widget.accentColor),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
