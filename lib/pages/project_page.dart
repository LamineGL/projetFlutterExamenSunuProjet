import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart'; // Import de la page MyHomePage

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate; // Champ pour la sélection de date de début
  DateTime? _endDate; // Champ pour la sélection de date de fin
  String _priority = 'Basse'; // Priorité par défaut

  void _selectDate(BuildContext context, Function(DateTime?) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  void _addProject() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Erreur : Aucun utilisateur connecté.");
      return;
    }

    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty || _startDate == null || _endDate == null) {
      print("Erreur : Tous les champs doivent être remplis.");
      return;
    }

    var uuid = Uuid();
    String projectId = uuid.v4();
    List<ProjectRole> roles = [
      ProjectRole(uid: user.uid, role: "Créateur (Chef de projet)")
    ];

    List<String> members = [user.uid];

    ProjectModel project = ProjectModel(
      id: projectId,
      title: title,
      description: description,
      createdBy: user.uid,
      status: 'En attente',
      startDate: _startDate!,
      endDate: _endDate!,
      priority: _priority,
      members: members,
      roles: roles,
      adminId: user.uid,
    );

    try {
      await Provider.of<ProjectProvider>(context, listen: false).addProject(project);
      print("Projet créé avec succès : $title");

      // Efface les champs et réinitialise les valeurs par défaut
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _startDate = null;
        _endDate = null;
        _priority = 'Basse';
      });

      // Redirection vers MyHomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(title: "Mes Projets"),
        ),
      );
    } catch (e) {
      print("Erreur lors de la création du projet : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un projet"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Section : Titre du Projet
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Titre du projet",
                    labelStyle: const TextStyle(fontSize: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section : Description
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: const TextStyle(fontSize: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section : Date de Début
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: const Text("Date de début"),
                  subtitle: Text(
                    _startDate != null
                        ? _startDate!.toLocal().toString().split(' ')[0]
                        : "Sélectionnez une date",
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.edit_calendar, color: Colors.grey),
                  onTap: () => _selectDate(context, (date) {
                    setState(() {
                      _startDate = date;
                    });
                  }),
                ),
                const SizedBox(height: 10),

                // Section : Date de Fin
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined, color: Colors.blue),
                  title: const Text("Date de fin"),
                  subtitle: Text(
                    _endDate != null
                        ? _endDate!.toLocal().toString().split(' ')[0]
                        : "Sélectionnez une date",
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.edit_calendar, color: Colors.grey),
                  onTap: () => _selectDate(context, (date) {
                    setState(() {
                      _endDate = date;
                    });
                  }),
                ),
                const SizedBox(height: 20),

                // Section : Priorité
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: InputDecoration(
                    labelText: "Priorité",
                    labelStyle: const TextStyle(fontSize: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Basse", child: Text("Basse")),
                    DropdownMenuItem(value: "Moyenne", child: Text("Moyenne")),
                    DropdownMenuItem(value: "Haute", child: Text("Haute")),
                    DropdownMenuItem(value: "Urgente", child: Text("Urgente")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _priority = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          // Bouton : Créer le Projet
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _addProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                "Créer le projet",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
