import 'package:accident_hotspot/Login%20Page%20web/login_web.dart';
import 'package:accident_hotspot/Login%20Page/Login.dart';
import 'package:flutter/material.dart';

class LayoutBuilderWidget extends StatelessWidget {
  const LayoutBuilderWidget(
      {super.key, });
  

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return LoginPage();
      } else {
        return LoginPageWeb();
      }
    });
  }
}
