class ProjectModel {
  String id;
  String title;
  String description;
  String createdBy;
  String status;
  DateTime startDate;
  DateTime endDate;
  String priority;
  List<String> members;
  String adminId;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.members,
    required this.adminId,
  });

  // Convertir un projet en Map (pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'priority': priority,
      'members': members,
      'adminId': adminId,
    };
  }

  // Créer un objet `ProjectModel` depuis Firestore
  factory ProjectModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProjectModel(
      id: documentId,
      title: map['title'],
      description: map['description'],
      createdBy: map['createdBy'],
      status: map['status'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      priority: map['priority'],
      members: List<String>.from(map['members']),
      adminId: map['adminId'],
    );
  }
}
