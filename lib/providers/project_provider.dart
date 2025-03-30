import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/services_app/project_service.dart';



class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  List<ProjectModel> _projects = [];

  List<ProjectModel> get projects => _projects;

  // Charger les projets de l'utilisateur
  void fetchUserProjects(String userId) {
    _projectService.getUserProjects(userId).listen((projects) {
      // Mettez à jour la liste locale `_projects` avec les projets récupérés
      _projects = projects; // Directement des instances de ProjectModel
      notifyListeners(); // Informe l'interface utilisateur que les projets ont été modifiés
    });
  }





  // Ajouter un projet
  Future<void> addProject(ProjectModel project) async {
    await _projectService.addProject(project.toMap()); // Utilisez la méthode toMap() pour inclure les rôles
    fetchUserProjects(project.createdBy);
  }


  // Modifier un projet (ex: statut)
  Future<void> updateMemberRole(String projectId, ProjectRole updatedRole) async {
    final projectIndex = _projects.indexWhere((project) => project.id == projectId);
    if (projectIndex != -1) {
      final updatedRoles = _projects[projectIndex].roles.map((role) {
        if (role.uid == updatedRole.uid) {
          return updatedRole;
        }
        return role;
      }).toList();

      await _projectService.updateProject(projectId, {'roles': updatedRoles.map((role) => role.toMap()).toList()});

      _projects[projectIndex].updateRoles = updatedRoles;
      notifyListeners();
    }
  }

}
