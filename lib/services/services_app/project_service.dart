import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter un projet
  Future<void> addProject(Map<String, dynamic> projectData) async {
    await FirebaseFirestore.instance.collection('projects').add(projectData);
  }

  // Récupérer tous les projets d'un utilisateur
  Stream<List<ProjectModel>> getUserProjects(String userId) {
    return _firestore
        .collection('projects')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProjectModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Modifier un projet (ex: changer le statut)
  Future<void> updateProject(String projectId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('projects').doc(projectId).update(data);
  }

  Future<List<ProjectModel>> getCreatedProjects(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('createdBy', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => ProjectModel.fromMap(doc.data(), doc.id)).toList();
  }


  Future<List<ProjectModel>> getAdministeredProjects(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('roles', arrayContains: {'uid': userId, 'role': 'Admin'})
        .get();

    return snapshot.docs.map((doc) => ProjectModel.fromMap(doc.data(), doc.id)).toList();
  }


  Future<List<ProjectModel>> getMemberProjects(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('members', arrayContains: userId)
        .get();

    return snapshot.docs.map((doc) => ProjectModel.fromMap(doc.data(), doc.id)).toList();
  }

}
