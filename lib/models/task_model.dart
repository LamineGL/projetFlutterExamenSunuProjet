class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String priority;
  final String status;
  final DateTime deadline;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.priority,
    required this.status,
    required this.deadline,
  });

  // Méthode copyWith pour créer une nouvelle instance avec des champs mis à jour
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? priority,
    String? status,
    DateTime? deadline,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'priority': priority,
      'status': status,
      'deadline': deadline.toIso8601String(),
    };
  }

  // Créer une instance depuis Firestore
  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'],
      description: map['description'],
      assignedTo: map['assignedTo'],
      priority: map['priority'],
      status: map['status'],
      deadline: DateTime.parse(map['deadline']),
    );
  }
}
