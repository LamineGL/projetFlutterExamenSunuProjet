import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firebase/auth.dart';

/// Ce provider gère l’état de l’authentification.
/// Il utilise la classe [Auth] pour interagir avec Firebase et expose :
/// - La propriété [user] qui représente l’utilisateur courant.

class AuthProvider extends ChangeNotifier {
  final Auth _auth = Auth();
  User? _user;

  AuthProvider() {
    // On s'abonne aux changements d'état de Firebase.
    _auth.authStateChanges.listen((User? user) {
      _user = user;
      // On notifie l'UI pour qu'elle se mette à jour en cas de changement.
      notifyListeners();
    });
  }

  /// Retourne l'utilisateur courant (null si non connecté).
  User? get user => _user;

  /// Méthode pour se connecter avec email et mot de passe.
  Future<void> login(String email, String password) async {
    await _auth.loginWithEmailAndPassword(email, password);
  }

  /// Méthode pour se déconnecter.
  Future<void> logout() async {
    await _auth.logout();
  }

  /// Méthode pour créer un nouvel utilisateur.
  Future<void> createUser(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email, password);
  }
}
