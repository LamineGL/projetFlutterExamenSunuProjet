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
      _projects = projects;
      notifyListeners();
    });
  }

  // Ajouter un projet
  Future<void> addProject(ProjectModel project) async {
    await _projectService.addProject(project);
    fetchUserProjects(project.createdBy);
  }

  // Modifier un projet (ex: statut)
  Future<void> updateProject(String projectId, Map<String, dynamic> data) async {
    await _projectService.updateProject(projectId, data);
    notifyListeners();
  }
}
