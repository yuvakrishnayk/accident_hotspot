import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600; // Adjust breakpoint as needed

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text(
          'About AI Hotspot Prediction',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated App Title
              const Center(child: AnimatedAppTitle()),
              const SizedBox(height: 16),

              // Introduction with Emphasis
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    color: Colors.black87,
                    height: 1.4, // Improved readability
                  ),
                  children: [
                    const TextSpan(
                        text:
                            'Our mission is to proactively '), // Changed to a mission statement
                    TextSpan(
                      text: 'eliminate traffic accidents',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700, // Emphasize key phrase
                      ),
                    ),
                    const TextSpan(
                        text:
                            '. This app leverages cutting-edge AI to predict accident hotspots, giving you the power to make informed decisions and drive safer.'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // How it Works - More Engaging
              const SectionTitle(title: 'How It Works: The AI in Action'),
              const SizedBox(height: 12),

              Text(
                'Our system intelligently processes data from a multitude of sources:',
                style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 16, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const DataSourcesList(),

              const SizedBox(height: 24),

              // Key Features - Visually Distinct and Engaging
              const SectionTitle(title: 'Key Features: Your Safety Toolkit'),
              const SizedBox(height: 12),
              const KeyFeaturesList(),

              const SizedBox(height: 24),

              // Innovation Section
              const SectionTitle(title: 'The Innovation Behind Our App'),
              const SizedBox(height: 12),
              const InnovationDescription(),

              const SizedBox(height: 24),

              // Contact Us - Easier Interaction
              const SectionTitle(
                  title: 'Get in Touch - We Value Your Feedback'),
              const SizedBox(height: 12),
              const ContactUsSection(),

              const SizedBox(height: 32), // More space at the bottom
              const Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---  Widgets ---

class AnimatedAppTitle extends StatefulWidget {
  const AnimatedAppTitle({super.key});

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
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.redAccent, // Modern Color
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

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.indigo.shade700,
      ),
    );
  }
}

class NeumorphicContainer extends StatelessWidget {
  final Widget child;

  const NeumorphicContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(4, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class DataSourcesList extends StatelessWidget {
  const DataSourcesList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DataSourceItem(
          title: 'Historical Accident Data',
          description:
              'Comprehensive database of past accidents with location, time, severity, and contributing factors.',
        ),
        DataSourceItem(
          title: 'Real-time Traffic Data',
          description:
              'Up-to-the-minute information on traffic flow and congestion from sensors and navigation apps.',
        ),
        DataSourceItem(
          title: 'Weather Conditions',
          description:
              'Real-time and forecasted weather data, including precipitation, visibility, and temperature.',
        ),
        DataSourceItem(
          title: 'Road Infrastructure Data',
          description:
              'Information about road geometry, lane configurations, speed limits, and potential hazards.',
        ),
      ],
    );
  }
}

class DataSourceItem extends StatelessWidget {
  final String title;
  final String description;

  const DataSourceItem(
      {Key? key, required this.title, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.data_usage,
              color: Colors.indigo.shade400, size: isSmallScreen ? 20 : 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 15 : 16),
                ),
                Text(
                  description,
                  style: TextStyle(
                      color: Colors.black54, fontSize: isSmallScreen ? 13 : 14),
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
  const KeyFeaturesList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeatureItem(
          title: 'Real-time Hotspot Prediction',
          description:
              'Continuously monitors data streams and updates hotspot predictions in real-time for proactive safety measures.',
          icon: Icons.location_on,
        ),
        FeatureItem(
          title: 'Historical Data Visualization',
          description:
              'Provides interactive charts and graphs for analyzing accident trends and patterns over time.',
          icon: Icons.trending_up,
        ),
        FeatureItem(
          title: 'Risk Factor Analysis',
          description:
              'Identifies the key factors contributing to accident risk in specific areas, enabling targeted interventions.',
          icon: Icons.warning,
        ),
        FeatureItem(
          title: 'Customizable Alerts',
          description:
              'Allows users to set up alerts for areas of interest and receive timely notifications about potential hazards.',
          icon: Icons.notifications_active,
        ),
        FeatureItem(
          title: 'Integration with Navigation Apps',
          description:
              'Integrates with popular navigation apps to provide drivers with warnings about potential hazards along their route.',
          icon: Icons.navigation,
        ),
      ],
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const FeatureItem(
      {Key? key,
      required this.title,
      required this.description,
      required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: Colors.indigo.shade400, size: isSmallScreen ? 20 : 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 15 : 16),
                ),
                Text(
                  description,
                  style: TextStyle(
                      color: Colors.black54, fontSize: isSmallScreen ? 13 : 14),
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
  const InnovationDescription({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our AI models are trained on vast datasets and constantly refined. We use:',
          style: TextStyle(
              fontSize: isSmallScreen ? 15 : 16, color: Colors.black54),
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
              fontSize: isSmallScreen ? 15 : 16, color: Colors.black54),
        ),
      ],
    );
  }
}

class ContactUsSection extends StatelessWidget {
  const ContactUsSection({super.key});

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
            Icon(Icons.email, color: Colors.indigo.shade400),
            const SizedBox(width: 8),
            InkWell(
              child: Text(
                'support@example.com',
                style: TextStyle(
                    color: Colors.blue,
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
            Icon(Icons.phone, color: Colors.indigo.shade400),
            const SizedBox(width: 8),
            InkWell(
              child: Text(
                '+1-555-123-4567',
                style: TextStyle(
                    color: Colors.blue,
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
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '© 2024 AI Hotspot Prediction. All rights reserved.',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
    );
  }
}
