import 'package:accident_hotspot/Settings_Page_web/helper_web.dart';
import 'package:accident_hotspot/Settings_Page_web/notification_web_page.dart';
import 'package:accident_hotspot/Settings_Page_web/profile_page_web.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Animation Package (install: `flutter pub add animate_do`)
import 'package:awesome_dialog/awesome_dialog.dart'; // Beautiful Dialogs(install: `flutter pub add awesome_dialog`)
// Persistent Storage

class SettingsPageWeb extends StatefulWidget {
  @override
  _SettingsPageWebState createState() => _SettingsPageWebState();
}

class _SettingsPageWebState extends State<SettingsPageWeb> {
  final Color themeColor = const Color(0xFFA1E6E7);
  final Color accentColor = const Color(0xFF007B83);

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800; // Example breakpoint

    // Adjust padding based on screen size
    final horizontalPadding = isLargeScreen ? screenWidth * 0.2 : 20.0;
    final verticalPadding = isLargeScreen ? 40.0 : 24.0;

    // Adjust font sizes based on screen size
    final titleFontSize = isLargeScreen ? 24.0 : 20.0;
    final sectionTitleFontSize = isLargeScreen ? 16.0 : 14.0;
    final listItemFontSize = isLargeScreen ? 18.0 : 16.0;
    final buttonFontSize = isLargeScreen ? 18.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: FadeInDown(
          child: Text('Settings',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: titleFontSize)),
        ),
        backgroundColor: accentColor,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themeColor.withOpacity(0.3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          children: [
            FadeInLeft(
              child: _buildSection(
                context,
                title: 'Account',
                sectionTitleFontSize: sectionTitleFontSize,
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile Settings',
                    listItemFontSize: listItemFontSize,
                    onTap: () => _navigateTo(
                      context,
                      ProfileSettingsPageWeb(
                          themeColor: themeColor, accentColor: accentColor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isLargeScreen ? 30 : 20),
            FadeInRight(
              child: _buildSection(
                context,
                title: 'Preferences',
                sectionTitleFontSize: sectionTitleFontSize,
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notification Settings',
                    listItemFontSize: listItemFontSize,
                    onTap: () => _navigateTo(
                      context,
                      NotificationSettingsPageWeb(
                          themeColor: themeColor, accentColor: accentColor),
                    ),
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    listItemFontSize: listItemFontSize,
                    onTap: () => _navigateTo(
                      context,
                      HelpSupportPageWeb(themeColor: themeColor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isLargeScreen ? 60 : 40),
            FadeInUp(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isLargeScreen ? 40 : 20),
                child: ElevatedButton(
                  onPressed: () => _handleLogout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: isLargeScreen ? 20 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title,
      required List<Widget> children,
      required double sectionTitleFontSize}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.w600,
                color: accentColor.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      required double listItemFontSize}) {
    return ListTile(
      leading: Icon(icon, color: accentColor, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: listItemFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: accentColor.withOpacity(0.7)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  //Function For Handle Logout
  void _handleLogout(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'Logout',
      desc: 'Are you sure you want to logout?',
      buttonsTextStyle: const TextStyle(color: Colors.black),
      showCloseIcon: true,
      btnCancelOnPress: () {},
      btnOkText: "Logout",
      btnOkColor: Colors.red,
      btnOkOnPress: () {
        Navigator.pop(context);
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const Loginpage()));
      },
    ).show();
  }
}
