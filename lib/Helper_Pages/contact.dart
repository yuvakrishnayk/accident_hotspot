import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:validators/validators.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_platform/universal_platform.dart';

class ContactSupportPage extends StatelessWidget {
  const ContactSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isWeb = UniversalPlatform.isWeb;
    final horizontalPadding =
        isWeb ? screenWidth * 0.1 : 16.0; // Add padding on web

    // Define Colors from the screenshot
    const Color appBarColor = Colors.teal; // Teal-ish AppBar color
    const Color tileBackgroundColor =
        Color(0xFFD3F0EE); // Light Teal Background
    // Dark Text Color
    const Color textColorLight = Colors.black54; // Light Text Color

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)),
        title: isWeb ? null : Text('Contact Support'), // Remove title on web
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _shareApp();
            },
          ),
        ],
      ),
      backgroundColor: tileBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200), // max width for web
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Assistance?',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: appBarColor), // Teal
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We are committed to providing exceptional support. Let us know how we can help!',
                    style: TextStyle(
                        fontSize: 16, color: textColorLight), // light Grey
                  ),
                  SizedBox(height: 24),
                  SectionTitle(title: 'Contact Information'),
                  SizedBox(height: 8), // Add gap here
                  ContactInfoTile(
                    icon: Icons.email,
                    title: 'Email Support',
                    subtitle: 'support@accidenthotspotapp.com',
                    onTap: () {
                      _launchURL(
                          'mailto:support@accidenthotspotapp.com', context);
                    },
                    trailing: IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          _copyToClipboard('support@accidenthotspotapp.com',
                              context, "Email Copied!");
                        }),
                  ),
                  SizedBox(height: 8), // Add gap here
                  ContactInfoTile(
                    icon: Icons.phone,
                    title: 'Phone Support',
                    subtitle: '044-450-54367',
                    onTap: () {
                      _launchURL('tel:+044-450-54367', context);
                    },
                    trailing: IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          _copyToClipboard(
                              '044-450-54367', context, "Phone Number Copied!");
                        }),
                  ),
                  SizedBox(height: 24),
                  SectionTitle(title: 'Stay Connected'),
                  SocialMediaRow(),
                  SizedBox(height: 24),
                  SectionTitle(title: 'Send Us a Message'),
                  ContactForm(),
                  SizedBox(height: 32),
                  Center(
                      child: Text(
                    'Accident Hotspot App - v1.0',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  )) // Example app version
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _shareApp() async {
    const String message =
        "Check out this awesome Accident Hotspot App! [Link to app store/play store]";
    await Share.share(message, subject: "Accident Hotspot App");
  }

  _copyToClipboard(String text, BuildContext context, String message) {
    Clipboard.setData(ClipboardData(text: text));
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.check_circle_outline, color: Colors.green),
      backgroundColor: Colors.grey[800]!,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  _launchURL(String url, BuildContext context) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showErrorSnackBar(context, 'Could not launch $url');
    }
  }

  void showErrorSnackBar(BuildContext context, String message) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      icon: Icon(Icons.error_outline, color: Colors.red),
      backgroundColor: Colors.grey[800]!,
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600, color: Colors.grey[800]),
    );
  }
}

class ContactInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const ContactInfoTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Removed White Box
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF16A388)), // Teal Icon
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        onTap: onTap,
        trailing: trailing,
      ),
    );
  }
}

class SocialMediaRow extends StatelessWidget {
  const SocialMediaRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // center social icons
      children: [
        IconButton(
          icon: Icon(
            Icons.facebook,
            color: Colors.blue,
          ), // Facebook Blue
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.camera_alt,
            color: Colors.blue,
          ), // Changed to a more appropriate icon, use twitters blue if you could get that
          onPressed: () {
            // Replace with actual Twitter link
          },
        ),
        IconButton(
          icon: Icon(
            Icons.linked_camera,
            color: Colors.blue,
          ), //Use Icons.linkedin, LinkedIn blue
          onPressed: () {
            // Replace with actual LinkedIn link
          },
        ),
      ],
    );
  }
}

class SocialMediaIconButton extends StatelessWidget {
  final String iconPath;
  final String url;

  const SocialMediaIconButton(
      {super.key, required this.iconPath, required this.url});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: SvgPicture.asset(
        iconPath,
        width: 30,
        height: 30,
        color: Colors.blueGrey,
      ),
      onPressed: () {
        _launchURL(url, context);
      },
    );
  }

  _launchURL(String url, BuildContext context) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Flushbar(
        message: 'Could not launch $url',
        duration: Duration(seconds: 3),
        icon: Icon(Icons.error_outline, color: Colors.red),
        backgroundColor: Colors.grey[800]!,
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }
}

class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _message = '';
  bool _subscribe = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextFormField(
            labelText: 'Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            onSaved: (value) {
              _name = value!;
            },
          ),
          SizedBox(height: 10),
          CustomTextFormField(
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!isEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onSaved: (value) {
              _email = value!;
            },
          ),
          SizedBox(height: 10),
          CustomTextFormField(
            labelText: 'Message',
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your message';
              }
              return null;
            },
            onSaved: (value) {
              _message = value!;
            },
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _subscribe,
                onChanged: (bool? value) {
                  setState(() {
                    _subscribe = value!;
                  });
                },
              ),
              Text('Subscribe to our newsletter'),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF16A388),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              textStyle: TextStyle(fontSize: 18),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Process the form data (e.g., send to a server)
                print(
                    'Name: $_name, Email: $_email, Message: $_message, Subscribe: $_subscribe');

                //Simulate Sending Message (Replace with actual API call)
                Future.delayed(Duration(seconds: 2), () {
                  _formKey.currentState!.reset();
                  setState(() {
                    _subscribe = false; //Reset Subscribe
                  });
                  Flushbar(
                    message: 'Message sent successfully!',
                    duration: Duration(seconds: 3),
                    icon: Icon(Icons.check_circle_outline, color: Colors.green),
                    backgroundColor: Colors.grey[800]!,
                    flushbarPosition: FlushbarPosition.TOP,
                  ).show(context);
                });
              }
            },
            child: Text('Send Message', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextInputType? keyboardType;
  final int? maxLines;

  const CustomTextFormField(
      {super.key,
      required this.labelText,
      this.validator,
      this.onSaved,
      this.keyboardType,
      this.maxLines});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // White Background
        labelText: labelText,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Color(0xFF16A388), width: 2.0), // Teal Border
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
