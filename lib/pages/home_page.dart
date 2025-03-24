import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Cette page affiche l’email de l’utilisateur connecté et propose un bouton pour se déconnecter.
class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // On récupère le provider pour accéder à l'utilisateur courant.
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(user?.email ?? 'Email non disponible'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authProvider.logout();
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
