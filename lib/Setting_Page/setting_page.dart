import 'package:accident_hotspot/Setting_Page/helper_page.dart';
import 'package:accident_hotspot/Setting_Page/notification_page.dart';
import 'package:accident_hotspot/Setting_Page/profile_page.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final Color themeColor = const Color(0xFFA1E6E7);
  final Color accentColor = const Color(0xFF007B83);

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          children: [
            _buildSection(
              context,
              title: 'Account',
              children: [
                _buildListTile(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile Settings',
                  onTap: () => _navigateTo(
                      context,
                      ProfileSettingsPage(
                          themeColor: themeColor, accentColor: accentColor)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: 'Preferences',
              children: [
                _buildListTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notification Settings',
                  onTap: () => _navigateTo(
                      context,
                      NotificationSettingsPage(
                          themeColor: themeColor, accentColor: accentColor)),
                ),
                _buildListTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => _navigateTo(
                      context, HelpSupportPage(themeColor: themeColor)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: accentColor.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: accentColor, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
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
}
