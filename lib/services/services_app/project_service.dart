import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';

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

  Future<void> upProjectStatus(String projectId, String newStatus) async {
    try {
      await _firestore.collection('projects').doc(projectId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour du projet : $e");
    }
  }

  Future<List<ProjectModel>> getCreatedProjects(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('createdBy', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => ProjectModel.fromMap(doc.data(), doc.id)).toList();
  }
  Future<bool> areAllTasksCompleted(String projectId) async {
    final querySnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .get();

    return querySnapshot.docs.every((doc) {
      final status = doc['status'] ?? '';
      return status == 'Terminée';
    });
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

  Future<void> updateProjectStatus(String projectId, {String? newStatus, double? newProgress}) async {
    final updateData = <String, dynamic>{};
    if (newStatus != null) updateData['status'] = newStatus;
    if (newProgress != null) updateData['progress'] = newProgress;

    try {
      await _firestore.collection('projects').doc(projectId).update(updateData);
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour du projet : $e");
    }
  }


// Future<void> updateProjectStatus(String projectId) async {
  //   final tasksSnapshot = await FirebaseFirestore.instance.collection('projects').doc(projectId).collection('tasks').get();
  //
  //   final allTasks = tasksSnapshot.docs.map((doc) => TaskModel.fromMap(doc.data(), doc.id)).toList();
  //   final allCompleted = allTasks.every((task) => task.status == 'Terminée');
  //   final isOverdue = DateTime.now().isAfter(allTasks.map((task) => task.deadline).reduce((a, b) => a.isAfter(b) ? a : b));
  //
  //   if (allCompleted || isOverdue) {
  //     await FirebaseFirestore.instance.collection('projects').doc(projectId).update({'status': 'Terminé'});
  //   }
  // }



}
