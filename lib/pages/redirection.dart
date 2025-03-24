import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'login_page.dart';
import '../providers/auth_provider.dart';

/// Cette page redirige l’utilisateur en fonction de son état d’authentification.
/// - Si l'utilisateur est connecté, on affiche [MyHomePage].
/// - Sinon, on affiche la page de connexion [LoginPage].
class RedirectionPage extends StatelessWidget {
  const RedirectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // On utilise un Consumer pour écouter les changements d'état de l'authentification.
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user != null) {
          return const MyHomePage(title: "Home Page");
        } else {
          return const LoginPage(title: "Login Page");
        }
      },
    );
  }
}
