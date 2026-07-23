class User {
  final int? id;
  final String nom;
  final String email;
  final String hashedPassword;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    required this.nom,
    required this.email,
    required this.hashedPassword,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      hashedPassword: json['hashedPassword'],
      role: json['role'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'hashedPassword': hashedPassword,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}