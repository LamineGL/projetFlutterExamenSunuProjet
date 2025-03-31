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

}





