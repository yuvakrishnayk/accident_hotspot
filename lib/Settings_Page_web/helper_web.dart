import 'package:accident_hotspot/Helper_Pages/about.dart';
import 'package:accident_hotspot/Helper_Pages/contact.dart';
import 'package:accident_hotspot/Helper_Pages/faq.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Animation Package (install: `flutter pub add animate_do`)
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Icons

class HelpSupportPageWeb extends StatelessWidget {
  final Color themeColor;

  HelpSupportPageWeb({required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: FadeInDown(
          // Animates the App Bar title
          child: const Text(
            'Help & Support',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [themeColor.withOpacity(0.3), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                FadeInLeft(
                  // Animate the About Card
                  child: _buildCard(
                    icon: FontAwesomeIcons
                        .circleInfo, //Replaced Icons.info with FA
                    title: 'About the App',
                    subtitle: 'Learn more about the app and its features.',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AboutPage()));
                    },
                  ),
                ),
                const SizedBox(height: 20),
                FadeInRight(
                  // Animate the Contact Card
                  child: _buildCard(
                    icon: FontAwesomeIcons
                        .headset, //Replaced Icons.contact_support with FA
                    title: 'Contact Support',
                    subtitle: 'Get in touch with our support team.',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContactSupportPage()));
                    },
                  ),
                ),
                const SizedBox(height: 20),
                FadeInLeft(
                  // Animate the FAQ Card
                  child: _buildCard(
                    icon: FontAwesomeIcons
                        .questionCircle, //Replaced Icons.help_outline with FA
                    title: 'FAQ',
                    subtitle: 'Find answers to frequently asked questions.',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => FAQPage()));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.teal, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
