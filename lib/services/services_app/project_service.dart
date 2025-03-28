import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter un projet
  Future<void> addProject(ProjectModel project) async {
    await _firestore.collection('projects').doc(project.id).set(project.toMap());
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
    await _firestore.collection('projects').doc(projectId).update(data);
  }
}
