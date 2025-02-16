import 'package:accident_hotspot/Functions/auth_func.dart';
import 'package:accident_hotspot/Settings_Page_web/helper_web.dart';
import 'package:accident_hotspot/Settings_Page_web/notification_web_page.dart';
import 'package:accident_hotspot/Settings_Page_web/profile_page_web.dart';
import 'package:accident_hotspot/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Animation Package (install: `flutter pub add animate_do`)
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPageWeb extends StatefulWidget {
  const SettingsPageWeb({super.key});

  @override
  _SettingsPageWebState createState() => _SettingsPageWebState();
}

class _SettingsPageWebState extends State<SettingsPageWeb> {
  final Color themeColor =
      const Color.fromARGB(255, 1, 107, 121); // Darker teal color
  final Color accentColor = const Color.fromARGB(255, 1, 79, 79);

  void logout() async {
    AuthFunc auth = AuthFunc();
    await auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthPage()),
      (route) => false, // This removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200; // Example breakpoint for web

    // Adjust padding based on screen size
    final horizontalPadding = isLargeScreen ? screenWidth * 0.15 : 32.0;
    final verticalPadding = isLargeScreen ? 48.0 : 32.0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        title: FadeInDown(
          child: Text(
            'Settings',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: accentColor,
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeColor.withOpacity(0.2),
              Colors.white.withOpacity(0.9),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              children: [
                FadeInLeft(
                  child: _buildSection(
                    context,
                    title: 'Account',
                    sectionTitleFontSize: 14,
                    children: [
                      _buildListTile(
                        context,
                        icon: Icons.person_outline,
                        title: 'Profile Settings',
                        listItemFontSize: 16,
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
                    sectionTitleFontSize: 14,
                    children: [
                      _buildListTile(
                        context,
                        icon: Icons.notifications_outlined,
                        title: 'Notification Settings',
                        listItemFontSize: 16,
                        onTap: () => _navigateTo(
                          context,
                          NotificationSettingsPageWeb(),
                        ),
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        listItemFontSize: 16,
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
                    padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 40 : 20),
                    child: ElevatedButton(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: isLargeScreen ? 20 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          fontSize: 16,
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: sectionTitleFontSize,
                fontWeight: FontWeight.w600,
                color: accentColor.withOpacity(0.8),
                letterSpacing: 1.2,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: accentColor, size: 24),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: listItemFontSize,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        trailing:
            Icon(Icons.chevron_right, color: accentColor.withOpacity(0.7)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        hoverColor: accentColor.withOpacity(0.05),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _handleLogout(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: 'Logout',
      width: MediaQuery.of(context).size.width * 0.4,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.grey[800],
      ),
      desc: 'Are you sure you want to logout?',
      descTextStyle: GoogleFonts.inter(
        fontSize: 16,
        color: Colors.grey[600],
      ),
      buttonsTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      showCloseIcon: true,
      btnCancelOnPress: () {},
      btnOkText: "Logout",
      btnOkColor: Colors.red.shade600,
      btnOkOnPress: () {
        logout();
      },
    ).show();
  }
}
