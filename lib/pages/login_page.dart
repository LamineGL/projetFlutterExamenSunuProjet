import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sunuprojetl3gl/pages/home_page.dart';
import 'package:sunuprojetl3gl/services/firebase/auth.dart';
import '../services/firebase/auth_service.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String selectedRole = "Chef de Projet";

  List<String> roles = ["Chef de Projet"];


  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      var user = await _authService.registerUser(name, email, password);
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inscription réussie !")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage(title: "Page d Acceuil")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'inscription")),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await Auth().loginWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage(title: "Page d acceuil")),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Erreur lors de la connexion"), backgroundColor: Colors.red),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text(_isLogin ? "Connexion" : "Inscription"),
        leading: _isLogin
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _isLogin = true),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                _isLogin ? "SunuProjet" : "Créer un compte",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
              ),
              Text(
                _isLogin ? "Connectez-vous pour continuer" : "Rejoignez SunuProjet pour gérer vos projets",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 30),

              if (!_isLogin)
                Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "Nom complet",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? "Le nom est requis" : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: "Role par defaut ",
                        border: OutlineInputBorder(),
                      ),
                      items: roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                      onChanged: (newValue) => setState(() => selectedRole = newValue!),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: "Adresse Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? "L'email est requis" : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: "Mot de Passe",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? "Le mot de passe est requis" : null,
              ),

              if (!_isLogin)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: "Confirmer le Mot de Passe",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Veuillez confirmer le mot de passe" : (value != _passwordController.text ? "Les mots de passe ne correspondent pas" : null),
                    ),
                  ],
                ),

              const SizedBox(height: 30),

              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage())),
                    child: const Text("Mot de passe oublié ?"),
                  ),
                ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : (_isLogin ? _login : _register),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isLogin ? "Se connecter" : "S'inscrire", style: const TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLogin ? "Vous n'avez pas de compte?  " : "Vous avez déjà un compte?  "),
                  GestureDetector(
                    onTap: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? "S'inscrire" : "Se connecter",
                      style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
