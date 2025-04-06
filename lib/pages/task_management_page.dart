import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import des modèles et services nécessaires
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../pages/create_task_page.dart';
import '../services/services_app/task_service.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailPage({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  User? currentUser; // Utilisateur connecté
  bool isChefDeProjet = false;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _listenToAuthState();
  }

  /// Écoute les changements d'état d'authentification Firebase
  void _listenToAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          currentUser = user;
        });
        _checkRoles(user.uid);
      } else {
        setState(() {
          currentUser = null;
          isChefDeProjet = false;
          isAdmin = false;
        });
      }
    });
  }

  /// Vérifie les rôles dans le projet pour l'utilisateur actuel
  Future<void> _checkRoles(String uid) async {
    final project = widget.project;

    // Vérification si l'utilisateur est le créateur du projet
    setState(() {
      isChefDeProjet = (project.createdBy == uid);
    });

    // Vérification si l'utilisateur est un administrateur
    final adminRole = project.roles.firstWhere(
          (role) => role.uid == uid && role.role == "Admin",
      orElse: () => ProjectRole(uid: '', role: ''), // Valeur par défaut
    );
    setState(() {
      isAdmin = (adminRole.role == "Admin");
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: Text(
            widget.project.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Aperçu"),
              Tab(text: "Tâches"),
              Tab(text: "Membres"),
              Tab(text: "Fichiers"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildTasksTab(),
            _buildMembersTab(),
            _buildFilesTab(),
          ],
        ),
      ),
    );
  }

  /// Onglet Aperçu
  Widget _buildOverviewTab() {
    final project = widget.project;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Description",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                project.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                "Statut",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                project.status,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildPriorityTag(project.priority),
            ],
          ),
        ),
      ),
    );
  }

  /// Onglet Tâches
  Widget _buildTasksTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTaskPage(
                projectId: widget.project.id,
                members: widget.project.members,
                projectDeadline: widget.project.endDate,
              ),
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<TaskModel>>(
        future: TaskService().getTasks(widget.project.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune tâche trouvée.'));
          } else if (snapshot.hasData) {
            final tasks = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text('Priorité : ${task.priority}'),
                );
              },
            );
          } else {
            return const Center(child: Text('Aucune donnée.'));
          }
        },
      ),
    );
  }

  /// Onglet Membres
  Widget _buildMembersTab() {
    final project = widget.project;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Membres du Projet", style: TextStyle(fontSize: 18)),
              if (isChefDeProjet || isAdmin)
                ElevatedButton(
                  onPressed: _showAddMembersDialog,
                  child: const Icon(Icons.add),
                ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: project.members.length,
              itemBuilder: (context, index) {
                final memberUid = project.members[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(memberUid)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const ListTile(
                        title: Text("Chargement..."),
                      );
                    }
                    final userData = snapshot.data!.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(userData['name'] ?? 'Nom inconnu'),
                      subtitle: Text(userData['email'] ?? 'Email inconnu'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesTab() {
    return const Center(
      child: Text("Fichiers - À implémenter"),
    );
  }

  void _showAddMembersDialog() {
    // Logique d'ajout de membres
  }

  Widget _buildPriorityTag(String priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(
        "Priorité : $priority",
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "Urgente":
        return Colors.red;
      case "Haute":
        return Colors.orange;
      case "Moyenne":
        return Colors.yellow[700]!;
      case "Basse":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
