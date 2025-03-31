import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/services_app/task_service.dart';
import 'create_task_page.dart';

class TaskManagementPage extends StatefulWidget {
  final String projectId;
  final List<String> members; // Liste des membres dynamiques du projet
  final DateTime projectDeadline; // Date limite du projet ajoutée

  const TaskManagementPage({
    Key? key,
    required this.projectId,
    required this.members,
    required this.projectDeadline, // Paramètre obligatoire ajouté
  }) : super(key: key);

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Tâches'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<TaskModel>>(
        future: TaskService().getTasks(widget.projectId), // Récupération des tâches via TaskService
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune tâche trouvée.'));
          } else {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text('Statut : ${task.status}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Ajouter une action pour modifier la tâche
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTaskPage(
                projectId: widget.projectId, // ID du projet
                members: widget.members, // Liste des membres dynamiques
                projectDeadline: widget.projectDeadline, // Passe la vraie date limite du projet
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
