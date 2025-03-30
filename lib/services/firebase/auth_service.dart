import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inscription d'un utilisateur
  Future<User?> registerUser(String name, String email, String password) async {
    try {
      // Création de l'utilisateur dans Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        // Création du modèle UserModel avec le rôle "Chef de Projet" par défaut
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: 'Chef de Projet', // ✅ Rôle par défaut à l'inscription
          isBlocked: false,
          emailVerified: user.emailVerified,
          projectsCreated: [],
          projectsJoined: [],
        );

        // Sauvegarde de l'utilisateur dans Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }

      return user;
    } catch (e) {
      print("Erreur lors de l'inscription: $e");
      return null;
    }
  }

  // Connexion d'un utilisateur
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Erreur de connexion: $e");
      return null;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Récupérer les infos d'un utilisateur
  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
