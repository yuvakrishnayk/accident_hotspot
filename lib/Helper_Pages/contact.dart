import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons
import 'package:validators/validators.dart'; // For more robust email validation (install: `flutter pub add validators`)
import 'package:another_flushbar/flushbar.dart'; // For better snackbar-like messages (install: `flutter pub add another_flushbar`)
import 'package:flutter/services.dart'; // For Clipboard
import 'package:share_plus/share_plus.dart'; // For sharing functionality (install: `flutter pub add share_plus`)

class ContactSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Support'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _shareApp();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                    color: Theme.of(context).primaryColor),
              ),
              SizedBox(height: 8),
              Text(
                'We are committed to providing exceptional support.  Let us know how we can help!',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              SectionTitle(title: 'Contact Information'),
              ContactInfoTile(
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'support@accidenthotspotapp.com',
                onTap: () {
                  _launchURL('mailto:support@accidenthotspotapp.com', context);
                },
                trailing: IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      _copyToClipboard('support@accidenthotspotapp.com',
                          context, "Email Copied!");
                    }),
              ),
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

  const SectionTitle({Key? key, required this.title}) : super(key: key);

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
      {Key? key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: trailing,
    );
  }
}

class SocialMediaRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.facebook),
          onPressed: () {
            
          },
        ),
        IconButton(
          icon: Icon(Icons.camera_alt), // Changed to a more appropriate icon
          onPressed: () {
// Replace with actual Twitter link
          },
        ),
        IconButton(
          icon: Icon(Icons.linked_camera), //Use Icons.linkedin
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
      {Key? key, required this.iconPath, required this.url})
      : super(key: key);

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
            child: Text('Send Message'),
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
      {Key? key,
      required this.labelText,
      this.validator,
      this.onSaved,
      this.keyboardType,
      this.maxLines})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
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
