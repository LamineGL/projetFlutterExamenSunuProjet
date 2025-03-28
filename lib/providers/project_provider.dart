import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

class ProjectProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ProjectModel> _projects = [];

  List<ProjectModel> get projects => _projects;

  // Charger les projets depuis Firestore
  Future<void> fetchProjects() async {
    final querySnapshot = await _firestore.collection('projects').get();
    _projects = querySnapshot.docs
        .map((doc) => ProjectModel.fromMap(doc.id, doc.data()))
        .toList();
    notifyListeners();
  }

  // Ajouter un projet
  Future<void> addProject(ProjectModel project) async {
    final docRef = await _firestore.collection('projects').add(project.toMap());
    _projects.add(ProjectModel(
      id: docRef.id,
      title: project.title,
      description: project.description,
      priority: project.priority,
      status: project.status,
      startDate: project.startDate,
      endDate: project.endDate,
    ));
    notifyListeners();
  }
}
