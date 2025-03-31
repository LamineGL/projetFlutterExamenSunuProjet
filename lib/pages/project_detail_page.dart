import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sunuprojetl3gl/pages/task_management_page.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';

class ProjectDetailPage extends StatefulWidget {
  final ProjectModel project;
  const ProjectDetailPage({super.key, required this.project});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.title),
          bottom: const TabBar(
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskManagementPage(
                      projectId: widget.project.id,
                      members: widget.project.members,
                      projectDeadline: widget.project.endDate,
                    ),
                  ),
                );
              },
              child: const Text('Gérer les tâches'),
            ),


            _buildMembersTab(),
            Center(child: const Text("Fichiers - À implémenter")),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final project = widget.project;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Statut : ${project.status}"),
          Text("Description : ${project.description}"),
          const SizedBox(height: 10),
          _buildPriorityTag(project.priority),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    final project = widget.project;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Membres du projet",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              IconButton(
                onPressed: _showAddMembersDialog,
                icon: const Icon(Icons.add, color: Colors.blue),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: project.members.length,
              itemBuilder: (context, index) {
                final memberUid = project.members[index];
                final bool isCreator = project.createdBy == memberUid;
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(memberUid).get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                        title: Text("Chargement..."),
                      );
                    }

                    final userData = snapshot.data!.data() as Map<String, dynamic>;
                    final userName = userData['name'] ?? 'Nom inconnu';
                    final userEmail = userData['email'] ?? 'Email inconnu';

                    // Récupérer le rôle depuis Firestore
                    String userRole = "Membre";
                    if (widget.project.roles.isNotEmpty) {
                      // Trouver le rôle correspondant à l'utilisateur
                      final roleEntry = widget.project.roles.firstWhere(
                            (role) => role.uid == memberUid, // Vérifiez si l'UID correspond
                        orElse: () => ProjectRole(uid: memberUid, role: "Membre"), // Retourne "Membre" si aucun rôle trouvé
                      );
                      userRole = roleEntry.role; // Accéder à la propriété `role` de `ProjectRole`
                    }


                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: isCreator ? Colors.green : Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                        title: Text(userName),
                        subtitle: Text(userEmail),
                        trailing: Text(
                          isCreator ? "Créateur (Chef de projet)" : userRole,
                          style: TextStyle(color: isCreator ? Colors.green : Colors.black),
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

  // **Formulaire pour ajouter des membres**
  void _showAddMembersDialog() async {
    final allUsers = await _fetchAllUsersFromFirestore();
    final availableUsers = allUsers
        .where((user) => !widget.project.members.contains(user.uid))
        .toList();

    List<Map<String, dynamic>> selectedUsers = []; // uid + role

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter des membres"),
          content: SingleChildScrollView(
            child: Column(
              children: availableUsers.map((user) {
                String selectedRole = "Membre"; // Rôle par défaut

                return Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.email),
                      ),
                    ),
                    DropdownButton<String>(
                      value: selectedRole,
                      items: const [
                        DropdownMenuItem(
                          value: "Admin",
                          child: Text("Admin"),
                        ),
                        DropdownMenuItem(
                          value: "Membre",
                          child: Text("Membre"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });

                        final existingUserIndex = selectedUsers.indexWhere(
                                (selectedUser) => selectedUser['uid'] == user.uid);

                        if (existingUserIndex != -1) {
                          selectedUsers[existingUserIndex]['role'] =
                              selectedRole;
                        } else {
                          selectedUsers.add({
                            'uid': user.uid,
                            'role': selectedRole,
                          });
                        }
                      },
                    ),
                  ],
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
              onPressed: () {
                _addSelectedMembers(selectedUsers);
                Navigator.pop(context);
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  void _addSelectedMembers(List<Map<String, dynamic>> selectedUsers) async {
    // Mettre à jour la liste des membres
    final updatedMembers = List<String>.from(widget.project.members);

    // Mettre à jour la liste des rôles
    final updatedRoles = List<ProjectRole>.from(widget.project.roles);

    // Ajouter les nouveaux membres et leurs rôles
    for (var user in selectedUsers) {
      updatedMembers.add(user['uid']);
      updatedRoles.add(ProjectRole(uid: user['uid'], role: user['role']));
    }

    // Sauvegarder dans Firestore
    await FirebaseFirestore.instance.collection('projects').doc(widget.project.id).update({
      'members': updatedMembers,
      'roles': updatedRoles.map((role) => role.toMap()).toList(),
    });

    // Mettre à jour l'état local
    setState(() {
      widget.project.updateMembers = updatedMembers;
      widget.project.updateRoles = updatedRoles;
    });
  }



  }

  Future<List<UserModel>> _fetchAllUsersFromFirestore() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs.map((doc) {
      return UserModel(
        uid: doc.id,
        name: doc['name'],
        email: doc['email'],
        role: doc['role'] ?? 'Membre',
        isBlocked: doc['isBlocked'] ?? false,
        emailVerified: doc['emailVerified'] ?? false,
        projectsCreated: List<String>.from(doc['projectsCreated'] ?? []),
        projectsJoined: List<String>.from(doc['projectsJoined'] ?? []),
      );
    }).toList();
  }

  Widget _buildPriorityTag(String priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text("Priorité: $priority", style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "Urgente": return Colors.red;
      case "Haute": return Colors.orange;
      case "Moyenne": return Colors.yellow;
      case "Basse": return Colors.green;
      default: return Colors.grey;
    }
  }

