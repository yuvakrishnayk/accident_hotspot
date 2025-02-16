import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_platform/universal_platform.dart'; // Import for platform detection

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isWeb = UniversalPlatform.isWeb;

    // Define a consistent palette for a cohesive look - MODIFIED
    const Color primaryColor = Color(0xFF00A896); // Teal-ish Blue
    const Color secondaryColor =
        Color(0xFF00A896); // Keep for consistency, could repurpose
    const Color textColorDark =
        Color(0xFF000000); // Almost Black for readability
    const Color textColorLight = Color(0xFF808080); // Medium Gray
    const Color backgroundColor = Color(0xFFD3F0EE); // Light Mint Green
    const Color surfaceColor = Colors.white; // White for cards/surfaces

    // Adjust padding and other values for web view
    final horizontalPadding =
        isWeb ? screenWidth * 0.1 : 16.0; // Add padding on web
    final appBarElevation =
        isWeb ? 0.0 : 4.0; // Remove shadow on web, add on mobile

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        backgroundColor: Colors.teal,
        elevation: appBarElevation, // Control shadow visibility
        iconTheme: IconThemeData(color: textColorDark), // Dark back arrow
        titleTextStyle:
            TextStyle(color: textColorDark, fontSize: 20), // Dark title
      ),
      backgroundColor: backgroundColor,
      body: Center(
        // Centering for larger screens
        child: ConstrainedBox(
          // Limit the width on larger screens
          constraints: BoxConstraints(
              maxWidth: 1200), // Max width for comfortable reading
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated App Title (modified color)
                Center(
                    child: AnimatedAppTitle(
                        primaryColor: primaryColor, isWeb: isWeb)),
                SizedBox(height: 16),

                // Introduction with Emphasis (color change)
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      color: textColorDark,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'Our mission is to proactively '),
                      TextSpan(
                        text: 'eliminate traffic accidents',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: secondaryColor, // Changed emphasis color
                        ),
                      ),
                      const TextSpan(
                          text:
                              '. This app leverages cutting-edge AI to predict accident hotspots, giving you the power to make informed decisions and drive safer.'),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // How it Works - More Engaging (color change)
                SectionTitle(
                    title: 'How It Works: The AI in Action',
                    color: primaryColor),
                SizedBox(height: 12),

                Text(
                  'Our system intelligently processes data from a multitude of sources:',
                  style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 16, color: textColorLight),
                ),
                SizedBox(height: 8),
                DataSourcesList(
                    primaryColor: primaryColor,
                    textColorLight: textColorLight,
                    surfaceColor: surfaceColor, // Pass surface color
                    isWeb: isWeb),

                SizedBox(height: 24),

                // Key Features - Visually Distinct and Engaging (color change)
                SectionTitle(
                    title: 'Key Features: Your Safety Toolkit',
                    color: primaryColor),
                SizedBox(height: 12),
                KeyFeaturesList(
                    primaryColor: primaryColor,
                    textColorLight: textColorLight,
                    surfaceColor: surfaceColor, // Pass surface color
                    isWeb: isWeb),

                SizedBox(height: 24),

                // Innovation Section (color change)
                SectionTitle(
                    title: 'The Innovation Behind Our App',
                    color: primaryColor),
                SizedBox(height: 12),
                InnovationDescription(
                    textColorLight: textColorLight, isWeb: isWeb),

                SizedBox(height: 24),

                // Contact Us - Easier Interaction (color change)
                SectionTitle(
                    title: 'Get in Touch - We Value Your Feedback',
                    color: primaryColor),
                SizedBox(height: 12),
                ContactUsSection(primaryColor: primaryColor, isWeb: isWeb),

                SizedBox(height: 32),
                Footer(textColorLight: textColorLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---  Widgets ---

class AnimatedAppTitle extends StatefulWidget {
  final Color primaryColor;
  final bool isWeb; // Add isWeb property

  const AnimatedAppTitle(
      {super.key, required this.primaryColor, required this.isWeb});

  @override
  State<AnimatedAppTitle> createState() => _AnimatedAppTitleState();
}

class _AnimatedAppTitleState extends State<AnimatedAppTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Text(
        'AI Hotspot Prediction',
        style: TextStyle(
          fontSize: widget.isWeb ? 32 : 28, // Larger font size on web
          fontWeight: FontWeight.w900,
          color: widget.primaryColor,
          shadows: [
            Shadow(
              blurRadius: 5,
              color: Colors.grey.shade300,
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const SectionTitle({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

class DataSourcesList extends StatelessWidget {
  final Color primaryColor;
  final Color textColorLight;
  final Color surfaceColor; // Add surface color
  final bool isWeb; // Add isWeb property

  const DataSourcesList(
      {super.key,
      required this.primaryColor,
      required this.textColorLight,
      required this.surfaceColor,
      required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DataSourceItem(
          title: 'Historical Accident Data',
          description:
              'Comprehensive database of past accidents with location, time, severity, and contributing factors.',
          icon: Icons.history,
          color: primaryColor,
          textColor: textColorLight,
          surfaceColor: surfaceColor, // Pass surface color
          isWeb: isWeb,
        ),
        DataSourceItem(
          title: 'Real-time Traffic Data',
          description:
              'Up-to-the-minute information on traffic flow and congestion from sensors and navigation apps.',
          icon: Icons.traffic,
          color: primaryColor,
          textColor: textColorLight,
          surfaceColor: surfaceColor, // Pass surface color
          isWeb: isWeb,
        ),
        DataSourceItem(
          title: 'Weather Conditions',
          description:
              'Real-time and forecasted weather data, including precipitation, visibility, and temperature.',
          icon: Icons.wb_cloudy,
          color: primaryColor,
          textColor: textColorLight,
          surfaceColor: surfaceColor, // Pass surface color
          isWeb: isWeb,
        ),
        DataSourceItem(
          title: 'Road Infrastructure Data',
          description:
              'Information about road geometry, lane configurations, speed limits, and potential hazards.',
          icon: Icons.map,
          color: primaryColor,
          textColor: textColorLight,
          surfaceColor: surfaceColor, // Pass surface color
          isWeb: isWeb,
        ),
      ],
    );
  }
}

class DataSourceItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color surfaceColor; // Add surface color
  final bool isWeb; // Add isWeb property

  const DataSourceItem(
      {super.key,
      required this.title,
      required this.description,
      required this.icon,
      required this.color,
      required this.textColor,
      required this.surfaceColor,
      required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      // Wrap content
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Add margin
      decoration: BoxDecoration(
        color: surfaceColor, // Use surface color
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.3), // Subtle shadow
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
          const SizedBox(width: 16), //Increased spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 15 : 16,
                    color: textColor, // Apply text color
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: textColor,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KeyFeaturesList extends StatelessWidget {
  final Color primaryColor;
  final Color textColorLight;
  final Color surfaceColor; // Add surface color
  final bool isWeb; // Add isWeb property

  const KeyFeaturesList(
      {super.key,
      required this.primaryColor,
      required this.textColorLight,
      required this.surfaceColor,
      required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeatureItem(
          title: 'Real-time Hotspot Prediction',
          description:
              'Continuously monitors data streams and updates hotspot predictions in real-time for proactive safety measures.',
          icon: Icons.location_on,
          color: primaryColor,
          textColor: textColorLight,
          surfaceColor: surfaceColor, // Pass surface color
          isWeb: isWeb,
        ),
        FeatureItem(
          title: 'Historical Data Visualization',
          description:
              'Provides interactive charts and graphs for analyzing accident trends and patterns over time.',
          icon: Icons.trending_up,
          color: primaryColor,
          textColor: textColorLight,
          surfaceColor: surfaceColor, // Pass surface color
          isWeb: isWeb,
        ),
        FeatureItem(
          title: 'Risk Factor Analysis',
          description:
              'Identifies the key factors contributing to accident risk in specific areas, enabling targeted interventions.',
          icon: Icons.warning,
          color: primaryColor,
          textColor: textColorLight,
          surfaceColor: surfaceColor, // Pass surface color
          isWeb: isWeb,
        ),
        FeatureItem(
          title: 'Customizable Alerts',
          description:
              'Allows users to set up alerts for areas of interest and receive timely notifications about potential hazards.',
          icon: Icons.notifications_active,
          color: primaryColor,
          textColor: textColorLight,
          surfaceColor: surfaceColor, // Pass surface color
          isWeb: isWeb,
        ),
        FeatureItem(
          title: 'Integration with Navigation Apps',
          description:
              'Integrates with popular navigation apps to provide drivers with warnings about potential hazards along their route.',
          icon: Icons.navigation,
          color: primaryColor,
          textColor: textColorLight,
          surfaceColor: surfaceColor, // Pass surface color
          isWeb: isWeb,
        ),
      ],
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color surfaceColor; // Add surface color
  final bool isWeb; // Add isWeb property

  const FeatureItem(
      {super.key,
      required this.title,
      required this.description,
      required this.icon,
      required this.color,
      required this.textColor,
      required this.surfaceColor,
      required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      // Wrap content
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Add margin
      decoration: BoxDecoration(
        color: surfaceColor, // Use surface color
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.3), // Subtle shadow
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
          const SizedBox(width: 16), //Increased spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 15 : 16,
                    color: color, // Apply text color
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: textColor,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InnovationDescription extends StatelessWidget {
  final Color textColorLight;
  final bool isWeb; // Add isWeb property

  const InnovationDescription(
      {super.key, required this.textColorLight, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our AI models are trained on vast datasets and constantly refined. We use:',
          style: TextStyle(
              fontSize: isSmallScreen ? 15 : 16, color: textColorLight),
        ),
        const SizedBox(height: 8),
        Text(
          '- Advanced machine learning algorithms for accurate prediction.',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 15),
        ),
        Text(
          '- Real-time data integration for up-to-the-minute insights.',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 15),
        ),
        Text(
          '- Continuous model retraining for improved performance.',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 14 : 15),
        ),
        const SizedBox(height: 8),
        Text(
          'We are committed to pushing the boundaries of AI to create safer roads for everyone.',
          style: TextStyle(
              fontSize: isSmallScreen ? 15 : 16, color: textColorLight),
        ),
      ],
    );
  }
}

class ContactUsSection extends StatelessWidget {
  final Color primaryColor;
  final bool isWeb; // Add isWeb property

  const ContactUsSection(
      {super.key, required this.primaryColor, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We are always eager to hear from you! Whether you have a question, suggestion, or just want to share your experience, please don\'t hesitate to reach out.',
          style: TextStyle(
              fontSize: isSmallScreen ? 15 : 16, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.email, color: primaryColor),
            const SizedBox(width: 8),
            InkWell(
              child: Text(
                'support@example.com',
                style: TextStyle(
                    color: primaryColor, // Match primary color
                    decoration: TextDecoration.underline,
                    fontSize: isSmallScreen ? 14 : 15),
              ),
              onTap: () => launchUrl(Uri.parse('mailto:support@example.com')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.phone, color: primaryColor),
            const SizedBox(width: 8),
            InkWell(
              child: Text(
                '+1-555-123-4567',
                style: TextStyle(
                    color: primaryColor, // Match primary color
                    decoration: TextDecoration.underline,
                    fontSize: isSmallScreen ? 14 : 15),
              ),
              onTap: () => launchUrl(Uri.parse('tel:+1-555-123-4567')),
            ),
          ],
        ),
      ],
    );
  }
}

class Footer extends StatelessWidget {
  final Color textColorLight;

  const Footer({super.key, required this.textColorLight});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '© 2024 AI Hotspot Prediction. All rights reserved.',
        style: TextStyle(fontSize: 12, color: textColorLight),
      ),
    );
  }
}
