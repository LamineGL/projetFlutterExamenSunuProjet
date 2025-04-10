import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../pages/create_task_page.dart';
import '../services/services_app/project_service.dart';
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

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? currentUser;
  bool isChefDeProjet = false;
  bool isAdmin = false;
  String projectStatus = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    projectStatus = widget.project.status;

    // Écoute les changements de tab pour redessiner le bouton
    _tabController.addListener(() {
      setState(() {}); // Obligatoire pour redessiner le FloatingActionButton
    });

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
      orElse: () => ProjectRole(uid: '', role: ''),
    );
    setState(() {
      isAdmin = (adminRole.role == "Admin");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text(
          widget.project.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Aperçu"),
            Tab(text: "Tâches"),
            Tab(text: "Membres"),
            Tab(text: "Fichiers"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTasksTab(),
          _buildMembersTab(),
          _buildFilesTab(),
        ],
      ),
      floatingActionButton: (isChefDeProjet || isAdmin) &&
          _tabController.index == 1
          ? FloatingActionButton(
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
          );
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  /// Onglet Aperçu - Nouvelle mise en page
  Widget _buildOverviewTab() {
    final project = widget.project;

    // Conversion des dates (startDate et endDate sont déjà de type DateTime)
    final String startDateString =
    DateFormat('dd/MM/yyyy').format(project.startDate);
    final String endDateString =
    DateFormat('dd/MM/yyyy').format(project.endDate);

    // Exemple de priorité (si présente dans votre modèle)
    final String projectPriority = project.priority ?? "Non définie";

    double projectProgress = widget.project.progress / 100; // Utilise les données du modèle
    String progressLabel = "${widget.project.progress.round()}%";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte des détails du projet
          Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et badge du statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(projectStatus),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          projectStatus,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Priorité
                  Row(
                    children: [
                      const Text(
                        "Priorité : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        projectPriority,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    project.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  // Dates
                  Row(
                    children: [
                      const Text(
                        "Dates : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Début : $startDateString  |  Fin : $endDateString"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Carte d'avancement et changement de statut
          Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avancement du projet
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Avancement du projet",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(progressLabel),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: projectProgress, // 0.0 = 0% ; 1.0 = 100%
                    backgroundColor: Colors.grey[300],
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  // Changer le statut du projet
                  const Text(
                    "Changer le statut du projet",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Ligne des 4 boutons de statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusButton(
                        label: "En attente",
                        color: Colors.orange,
                        onTap: () => _updateProjectStatus("En attente"),
                      ),
                      _buildStatusButton(
                        label: "En cours",
                        color: Colors.blue,
                        onTap: () => _updateProjectStatus("En cours"),
                      ),
                      _buildStatusButton(
                        label: "Terminés",
                        color: Colors.green,
                        onTap: () => _updateProjectStatus("Terminés"),
                      ),
                      _buildStatusButton(
                        label: "Annulé",
                        color: Colors.red,
                        onTap: () => _updateProjectStatus("Annulé"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton statutaire (petit container coloré avec un label)
  Widget _buildStatusButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// Détermine la couleur du badge de statut
  Color _statusColor(String status) {
    switch (status) {
      case "En attente":
        return Colors.orange;
      case "En cours":
        return Colors.blue;
      case "Terminés":
        return Colors.green;
      case "Annulé":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Onglet Tâches
  Widget _buildTasksTab() {
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<TaskModel>>(
      future: TaskService().getUserTasks(widget.project.id, currentUser!.uid),
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
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                child: ListTile(
                  title: Text(task.title),
                  subtitle: Text("Priorité : ${task.priority}"),
                  trailing: task.status != "Terminée"
                      ? IconButton(
                    icon: const Icon(Icons.check_circle,
                        color: Colors.green),
                    onPressed: () => _markTaskAsCompleted(task),
                  )
                      : const Icon(Icons.check_circle, color: Colors.grey),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('Aucune donnée.'));
        }
      },
    );
  }

  void _markTaskAsCompleted(TaskModel task) {
    TaskService()
        .markTaskAsCompleted(widget.project.id, task.id)
        .then((_) {
      setState(() {
        // Remplacer l'instance task par une nouvelle avec le statut mis à jour
        task = task.copyWith(status: 'Terminée');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tâche marquée comme terminée !")),
      );
      _checkIfProjectCompleted(); // Vérifie si toutes les tâches sont terminées
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    });
  }

  void _updateProjectStatus(String newStatus) {
    if (isChefDeProjet || isAdmin) {
      ProjectService()
          .updateProjectStatus(widget.project.id,
          newStatus: newStatus) // Passez le statut comme argument nommé
          .then((_) {
        setState(() {
          projectStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Statut du projet mis à jour : $newStatus")),
        );
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Vous n'avez pas les permissions nécessaires.")),
      );
    }
  }

  /// Onglet Membres - Design amélioré
  Widget _buildMembersTab() {
    final project = widget.project;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entête avec titre et bouton Ajouter (pour chef de projet ou Admin)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Membres du Projet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isChefDeProjet || isAdmin)
                ElevatedButton(
                  onPressed: _showAddMembersDialog,
                  child: const Icon(Icons.add),
                ),
            ],
          ),
          const Divider(),
          // Liste des membres affichés dans une carte avec avatar et rôle
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
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                    final String memberName =
                        userData['name'] ?? 'Nom inconnu';
                    final String memberEmail =
                        userData['email'] ?? 'Email inconnu';

                    // Recherche du rôle associé à ce membre dans le projet
                    final roleData = widget.project.roles.firstWhere(
                          (role) => role.uid == memberUid,
                      orElse: () => ProjectRole(uid: memberUid, role: 'Membre'),
                    );
                    final String memberRole = roleData.role;

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[300],
                          child: Text(
                            memberName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          memberName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(memberEmail),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: memberRole == "Admin"
                                    ? Colors.orange
                                    : Colors.grey[400],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                memberRole,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
    final querySnapshot =
    await FirebaseFirestore.instance.collection('users').get();
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
                // Utilisation d'un StatefulBuilder pour gérer l'état du Dropdown
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
                            DropdownMenuItem(
                                value: "Admin", child: Text("Admin")),
                            DropdownMenuItem(
                                value: "Membre", child: Text("Membre")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                            final existingIndex = selectedUsers.indexWhere(
                                  (selected) =>
                              selected["uid"] == user["uid"],
                            );
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

  Future<void> _addSelectedMembers(
      List<Map<String, String>> selectedUsers) async {
    // Copie des membres et rôles existants pour mise à jour
    final updatedMembers = List<String>.from(widget.project.members);
    final updatedRoles = List<ProjectRole>.from(widget.project.roles);

    for (var user in selectedUsers) {
      final String uid = user["uid"] ?? "";
      final String role = user["role"] ?? "Membre";

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

    // Mise à jour de l'état local
    setState(() {
      widget.project.members = updatedMembers;
      widget.project.roles = updatedRoles;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Membres ajoutés avec succès !")),
    );
  }

  void _checkIfProjectCompleted() async {
    final allTasksCompleted =
    await ProjectService().areAllTasksCompleted(widget.project.id);

    if (allTasksCompleted) {
      ProjectService()
          .updateProjectStatus(widget.project.id,
          newStatus: 'Terminés', newProgress: 100)
          .then((_) {
        setState(() {
          projectStatus = 'Terminés';
          widget.project.progress = 100; // Mise à jour locale
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Le projet est maintenant terminé !")),
        );
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      });
    }
  }

  Future<List<ProjectModel>> _getPendingProjects() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('status', isEqualTo: 'En attente')
        .get();

    return snapshot.docs
        .map((doc) => ProjectModel.fromMap(doc.data(), doc.id))
        .toList();
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
