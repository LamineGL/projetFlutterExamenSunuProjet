import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  String id;
  String title;
  String description;
  String priority;
  String status;
  DateTime startDate;
  DateTime endDate;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  // Convertir en JSON pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  // Convertir depuis Firestore
  factory ProjectModel.fromMap(String id, Map<String, dynamic> map) {
    return ProjectModel(
      id: id,
      title: map['title'],
      description: map['description'],
      priority: map['priority'],
      status: map['status'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
    );
  }
}
