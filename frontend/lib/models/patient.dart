class Patient {
  final int? id;
  final int? userId;
  final String nom;
  final String email;
  final String pays;
  final String indicatif;
  final String telephone;
  final String objectifNutritionnel;
  final String statut;
  final bool notificationsAutorisees;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Patient({
    this.id,
    this.userId,
    required this.nom,
    required this.email,
    required this.pays,
    required this.indicatif,
    required this.telephone,
    required this.objectifNutritionnel,
    required this.statut,
    required this.notificationsAutorisees,
    this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      userId: json['userId'],
      nom: json['nom'],
      email: json['email'],
      pays: json['pays'],
      indicatif: json['indicatif'],
      telephone: json['telephone'],
      objectifNutritionnel: json['objectifNutritionnel'],
      statut: json['statut'],
      notificationsAutorisees: json['notificationsAutorisees'],
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
      'userId': userId,
      'nom': nom,
      'email': email,
      'pays': pays,
      'indicatif': indicatif,
      'telephone': telephone,
      'objectifNutritionnel': objectifNutritionnel,
      'statut': statut,
      'notificationsAutorisees': notificationsAutorisees,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}