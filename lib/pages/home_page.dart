import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sunuprojetl3gl/pages/login_page.dart';
import 'package:sunuprojetl3gl/pages/project_detail_page.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../services/firebase/auth_service.dart';
import '../services/services_app/project_service.dart';
import 'project_page.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  List<ProjectModel> _createdProjects = [];
  List<ProjectModel> _administeredProjects = [];
  List<ProjectModel> _memberProjects = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserProjects();
  }

  // Charger les informations de l'utilisateur connecté
  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      UserModel? userData = await _authService.getUserData(user.uid);
      if (mounted) {
        setState(() {
          _userModel = userData;
        });
      }
    }
  }

  // Charger les projets de l'utilisateur
  void _loadUserProjects() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final createdProjects = await ProjectService().getCreatedProjects(user.uid);
      final administeredProjects = await ProjectService().getAdministeredProjects(user.uid);
      final memberProjects = await ProjectService().getMemberProjects(user.uid);

      if (mounted) {
        setState(() {
          _createdProjects = createdProjects;
          _administeredProjects = administeredProjects;
          _memberProjects = memberProjects;
        });
      }
    }
  }

  // Combine les projets en éliminant les doublons (on se base sur l'id)
  List<ProjectModel> get _allProjects {
    final Map<String, ProjectModel> mapProjects = {};
    for (var p in _createdProjects) {
      mapProjects[p.id] = p;
    }
    for (var p in _administeredProjects) {
      mapProjects[p.id] = p;
    }
    for (var p in _memberProjects) {
      mapProjects[p.id] = p;
    }
    return mapProjects.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    // Filtrer les projets selon leur statut à partir de la liste combinée
    final allProjects = _allProjects;
    final enAttente = allProjects.where((project) => project.status == "En attente").toList();
    final enCours = allProjects.where((project) => project.status == "En cours").toList();
    final termines = allProjects.where((project) => project.status == "Terminés").toList();
    final annules = allProjects.where((project) => project.status == "Annulés").toList();

    return DefaultTabController(
      length: 4, // Quatre onglets selon le statut
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.blue,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "En attente"),
              Tab(text: "En cours"),
              Tab(text: "Terminés"),
              Tab(text: "Annulés"),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _userModel != null ? _userModel!.name : "Chargement...",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Voir Profil"),
                onTap: () {
                  // Navigation vers le profil
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text("Notifications"),
                onTap: () {
                  // Navigation vers les notifications
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Se déconnecter"),
                onTap: () async {
                  await _authService.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage(title: "Connexion")),
                  );
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProjectList(enAttente),
            _buildProjectList(enCours),
            _buildProjectList(termines),
            _buildProjectList(annules),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProjectPage()),
            );
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // Méthode d'affichage de la liste des projets
  Widget _buildProjectList(List<ProjectModel> projects) {
    if (projects.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              "Aucun projet trouvé",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Créez un nouveau projet pour commencer",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailPage(project: project),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    project.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(project.priority),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          project.priority,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("0% terminé",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Échéance: ${project.endDate.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Urgente':
        return Colors.red;
      case 'Haute':
        return Colors.orange;
      case 'Moyenne':
        return Colors.yellow;
      case 'Basse':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
