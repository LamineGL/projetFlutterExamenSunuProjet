import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/services_app/task_service.dart';
import '../models/task_model.dart';

class CreateTaskPage extends StatefulWidget {
  final String projectId;
  final List<String> members; // Liste des UID des membres
  final DateTime projectDeadline; // Date limite du projet

  const CreateTaskPage({
    Key? key,
    required this.projectId,
    required this.members,
    required this.projectDeadline,
  }) : super(key: key);

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();

  String? _selectedMember;
  String? _selectedPriority;

  List<Map<String, String>> _memberDetails = []; // Liste contenant les informations des membres

  @override
  void initState() {
    super.initState();
    _loadMemberDetails(); // Charger les détails des membres
  }

  void _loadMemberDetails() async {
    List<Map<String, String>> details = [];
    for (String memberUid in widget.members) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(memberUid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        details.add({
          'uid': memberUid,
          'name': userData['name'] ?? 'Nom inconnu',
          'email': userData['email'] ?? 'Email inconnu',
        });
      }
    }
    setState(() {
      _memberDetails = details; // Met à jour les informations des membres
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une tâche'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre de la tâche'),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer un titre' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Veuillez entrer une description' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedMember,
                items: _memberDetails.map((member) {
                  return DropdownMenuItem(
                    value: member['uid'], // Utilise l'UID pour identifier le membre
                    child: Text('${member['name']} (${member['email']})'), // Affiche nom et email
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedMember = value),
                decoration: const InputDecoration(labelText: 'Assigner à un membre'),
                validator: (value) => value == null ? 'Veuillez sélectionner un membre' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: ['Basse', 'Moyenne', 'Haute', 'Urgente'].map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedPriority = value),
                decoration: const InputDecoration(labelText: 'Priorité'),
                validator: (value) => value == null ? 'Veuillez sélectionner une priorité' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(labelText: 'Date limite (AAAA-MM-JJ)'),
                validator: (value) {
                  if (value!.isEmpty) return 'Veuillez entrer une date limite';
                  try {
                    final date = DateTime.parse(value);
                    if (date.isAfter(widget.projectDeadline)) {
                      return 'La date limite doit être avant le ${widget.projectDeadline.toLocal()}';
                    }
                  } catch (e) {
                    return 'Format de date invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitTask,
                child: const Text('Créer la tâche'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      final taskDeadline = DateTime.parse(_deadlineController.text.trim());

      // Créer la tâche
      final task = TaskModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedTo: _selectedMember!,
        priority: _selectedPriority!,
        status: 'En attente',
        deadline: taskDeadline,
      );

      // Enregistrer la tâche dans Firestore via TaskService
      TaskService().addTask(widget.projectId, task).then((taskId) async {
        // Ajouter une notification pour le membre assigné
        await FirebaseFirestore.instance
            .collection('users')
            .doc(task.assignedTo) // UID du membre
            .collection('notifications')
            .add({
          'title': 'Nouvelle tâche assignée',
          'message': 'Vous avez été assigné à la tâche "${task.title}".',
          'timestamp': FieldValue.serverTimestamp(),
          'projectId': widget.projectId,
          'status': 'unread', // La notification est initialement non lue
        });

        // Notification de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tâche créée et notification envoyée !')),
        );
        Navigator.pop(context); // Retour à la page précédente
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${error.toString()}')),
        );
      });
    }
  }
}
