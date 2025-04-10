import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Login avec email-password
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }
// Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

// //Creer user avec email et password
//   Future<void> createUserWithEmailAndPassword(String email, String password) async {
//     await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
//   }

  /// Création d’un utilisateur avec email et mot de passe, en envoyant un email de vérification
  Future<User?> createUserWithEmailAndPassword(String email, String password, {String role = "membre",  required String name,}) async {
    try {
      // Création de l’utilisateur dans Firebase Auth
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Envoi de l'email de vérification
        await user.sendEmailVerification();

        // Sauvegarder le rôle et autres infos dans Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': user.emailVerified,
        });

        return user;
      }
    } on FirebaseAuthException catch (e) {
      throw e;
    }
    return null;
  }

  // Methode pour la renitialisation
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {

      throw e;
    }
  }


}