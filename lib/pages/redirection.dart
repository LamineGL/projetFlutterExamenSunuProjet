import 'package:flutter/material.dart';
import 'package:sunuprojetl3gl/services/firebase/auth.dart';
import 'package:sunuprojetl3gl/pages/login_page.dart';
import 'package:sunuprojetl3gl/pages/home_page.dart';
import 'home_page.dart';

class RedirectionPage extends StatefulWidget {
  const RedirectionPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RedirectionPageState();
  }
}

class _RedirectionPageState extends State<RedirectionPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return const MyHomePage(title: "Home page");
        } else {
          return const LoginPage (title: "Login Page");;
        }
      },
    );
  }
}

