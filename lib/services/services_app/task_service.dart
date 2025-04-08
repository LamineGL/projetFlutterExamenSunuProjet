import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/task_model.dart';


class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  Future<void> addTask(String projectId, TaskModel task) async {
    await _firestore.collection('projects').doc(projectId).collection('tasks').add(task.toMap());
  }

  Future<List<TaskModel>> getTasks(String projectId) async {
    final snapshot = await _firestore.collection('projects').doc(projectId).collection('tasks').get();


    return snapshot.docs.map((doc) => TaskModel.fromMap(doc.data(), doc.id)).toList();
  }


  Future<void> updateTask(String projectId, String taskId, Map<String, dynamic> updates) async {
    await _firestore.collection('projects').doc(projectId).collection('tasks').doc(taskId).update(updates);
  }

  Future<void> markTaskAsCompleted(String projectId, String taskId) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .doc(taskId)
          .update({'status': 'Terminée'});

      // Recalculer la progression du projet
      final tasksSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .get();

      final totalTasks = tasksSnapshot.docs.length;
      final completedTasks = tasksSnapshot.docs
          .where((doc) => doc['status'] == 'Terminée')
          .length;

      final newProgress = (completedTasks / totalTasks) * 100;

      // Mettre à jour la progression du projet
      await _firestore.collection('projects').doc(projectId).update({
        'progress': newProgress,
      });
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour de la tâche : $e");
    }
  }


  Future<List<TaskModel>> getUserTasks(String projectId, String userId) async {
    final querySnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .where('assignedTo', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      return TaskModel.fromMap(doc.data(), doc.id);
    }).toList();
  }



}





