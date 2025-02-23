import 'package:accident_hotspot/Maps/Map_Screen_web.dart';
import 'package:accident_hotspot/layoutbuilder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return MapScreenWeb();
            } else {
              return LayoutBuilderWidget();
            }
          }),
    );
  }
}
