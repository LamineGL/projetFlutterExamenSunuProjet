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

  void _showAddMembersDialog() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    final allUsers = querySnapshot.docs.map((doc) {
      return {
        "uid": doc.id,
        "name": doc["name"] ?? "Nom inconnu",
        "email": doc["email"] ?? "Email inconnu",
      };
    }).toList();

    final availableUsers = allUsers.where((user) {
      return !widget.project.members.contains(user["uid"]);
    }).toList();

    List<Map<String, String>> selectedUsers = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter des membres"),
          content: SingleChildScrollView(
            child: Column(
              children: availableUsers.map((user) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    String selectedRole = "Membre";

                    return Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(user["name"]),
                            subtitle: Text(user["email"]),
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedRole,
                          items: const [
                            DropdownMenuItem(value: "Admin", child: Text("Admin")),
                            DropdownMenuItem(value: "Membre", child: Text("Membre")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });

                            final existingIndex = selectedUsers.indexWhere(
                                    (selected) => selected["uid"] == user["uid"]);
                            if (existingIndex != -1) {
                              selectedUsers[existingIndex]["role"] = selectedRole;
                            } else {
                              selectedUsers.add({
                                "uid": user["uid"],
                                "role": selectedRole,
                              });
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                await _addSelectedMembers(selectedUsers);
                Navigator.pop(context);
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addSelectedMembers(List<Map<String, String?>> selectedUsers) async {
    // Copie des membres et rôles existants pour mise à jour
    final updatedMembers = List<String>.from(widget.project.members);
    final updatedRoles = List<ProjectRole>.from(widget.project.roles);

    for (var user in selectedUsers) {
      // Vérifie que les valeurs ne sont pas nulles
      final String uid = user["uid"] ?? ""; // Retourne une chaîne vide si null
      final String role = user["role"] ?? "Membre"; // Définit un rôle par défaut si null

      // Ajoute uniquement si l'UID est valide
      if (uid.isNotEmpty) {
        updatedMembers.add(uid);
        updatedRoles.add(ProjectRole(uid: uid, role: role));
      }
    }

    // Met à jour le projet dans Firestore
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.project.id)
        .update({
      "members": updatedMembers,
      "roles": updatedRoles.map((role) => role.toMap()).toList(),
    });

    // Met à jour l'état local du projet
    setState(() {
      widget.project.members = updatedMembers;
      widget.project.roles = updatedRoles;
    });

    // Affiche une notification de succès
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Membres ajoutés avec succès !")),
    );
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
