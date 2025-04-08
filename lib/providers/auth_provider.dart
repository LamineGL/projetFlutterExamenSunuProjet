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

    _auth.authStateChanges.listen((User? user) {
      _user = user;

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
  Future<void> createUser(String email, String password, String name, {String role = "membre"}) async {
    await _auth.createUserWithEmailAndPassword(email, password, name: name, role: role);
  }

}
