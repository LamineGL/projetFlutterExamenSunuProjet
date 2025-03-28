// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../models/project_model.dart';
//
//
// class ProjectService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final CollectionReference _projectsRef =
//   FirebaseFirestore.instance.collection('projects');
//
//   // Ajouter un projet
//   Future<void> addProject(Project project) async {
//     await _projectsRef.add(project.toMap());
//   }
//
//   // Récupérer les projets
//   Stream<List<Project>> getProjects() {
//     return _firestore.collection('projects').snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList();
//     });
//   }
//
//   // Mettre à jour un projet
//   Future<void> updateProject(String projectId, Map<String, dynamic> data) async {
//     await _projectsRef.doc(projectId).update(data);
//   }
//
//   // Supprimer un projet
//   Future<void> deleteProject(String projectId) async {
//     await _projectsRef.doc(projectId).delete();
//   }
// }
