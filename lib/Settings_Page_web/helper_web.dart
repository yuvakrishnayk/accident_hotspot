import 'package:accident_hotspot/Helper_Pages/about.dart';
import 'package:accident_hotspot/Helper_Pages/contact.dart';
import 'package:accident_hotspot/Helper_Pages/faq.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // Animation Package (install: `flutter pub add animate_do`)
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Icons

class HelpSupportPageWeb extends StatelessWidget {
  final Color themeColor;

  const HelpSupportPageWeb({super.key, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.handHoldingHeart, size: 24),
              const SizedBox(width: 12),
              Text(
                'Help & Support Center',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeColor.withOpacity(0.1),
              Colors.white,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      'Select a category to find the help you need',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      children: [
                        _buildEnhancedCard(
                          icon: FontAwesomeIcons.circleInfo,
                          title: 'About the App',
                          subtitle:
                              'Learn more about the app and its features.',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutPage()),
                          ),
                          delay: 400,
                        ),
                        _buildEnhancedCard(
                          icon: FontAwesomeIcons.headset,
                          title: 'Contact Support',
                          subtitle: 'Get in touch with our support team.',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ContactSupportPage()),
                          ),
                          delay: 600,
                        ),
                        _buildEnhancedCard(
                          icon: FontAwesomeIcons.questionCircle,
                          title: 'FAQ',
                          subtitle:
                              'Find answers to frequently asked questions.',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FAQPage()),
                          ),
                          delay: 800,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int delay,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: Duration(milliseconds: delay),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.teal.shade700,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade700,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Learn More',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
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
