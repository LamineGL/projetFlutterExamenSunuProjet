class UserModel {
  String uid;
  String name;
  String email;
  String role;
  bool isBlocked;
  bool emailVerified;
  List<String> projectsCreated;
  List<String> projectsJoined;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isBlocked,
    required this.emailVerified,
    required this.projectsCreated,
    required this.projectsJoined,
  });





  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'isBlocked': isBlocked,
      'emailVerified': emailVerified,
      'projectsCreated': projectsCreated,
      'projectsJoined': projectsJoined,
    };
  }

  // Convertir un document Firestore en `UserModel`
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'Membre',
      isBlocked: map['isBlocked'] ?? false,
      emailVerified: map['emailVerified'] ?? false,
      projectsCreated: List<String>.from(map['projectsCreated'] ?? []),
      projectsJoined: List<String>.from(map['projectsJoined'] ?? []),
    );
  }
}
