import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import 'project_page.dart';

/// Cette page affiche l'interface utilisateur avec les projets classés par statut.
class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.projects;

    // Filtrer les projets par statut
    final enAttente = projects.where((project) => project.status == "En attente").toList();
    final enCours = projects.where((project) => project.status == "En cours").toList();
    final termines = projects.where((project) => project.status == "Terminés").toList();
    final annules = projects.where((project) => project.status == "Annulés").toList();

    return DefaultTabController(
      length: 4, // Nombre d'onglets dans le TabBar
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
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
        body: TabBarView(
          children: [
            // Onglet "En attente"
            _buildProjectList(enAttente),
            // Onglet "En cours"
            _buildProjectList(enCours),
            // Onglet "Terminés"
            _buildProjectList(termines),
            // Onglet "Annulés"
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

  // Méthode pour construire une liste de projets sous forme de cartes
  Widget _buildProjectList(List projects) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.folder, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              "Aucun projet trouvé",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Créez un nouveau projet pour commencer",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text("0% terminé",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Échéance: ${project.endDate.toLocal().toString().split(' ')[0]}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Méthode utilitaire pour les couleurs de priorité
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
