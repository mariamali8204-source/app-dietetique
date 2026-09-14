class PlanNutritionnel {
  final int id;
  final int userId;
  final int patientId;

  final String titre;
  final String objectif;

  final int? caloriesJournalieres;

  final DateTime dateDebut;
  final DateTime? dateFin;

  final String statut;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  const PlanNutritionnel({
    required this.id,
    required this.userId,
    required this.patientId,
    required this.titre,
    required this.objectif,
    required this.caloriesJournalieres,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanNutritionnel.fromJson(Map<String, dynamic> json) {
    return PlanNutritionnel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      patientId: json['patientId'] as int,
      titre: json['titre'] as String,
      objectif: json['objectif'] as String,
      caloriesJournalieres: json['caloriesJournalieres'] as int?,
      dateDebut: DateTime.parse(json['dateDebut'] as String),
      dateFin: json['dateFin'] == null
          ? null
          : DateTime.parse(json['dateFin'] as String),
      statut: json['statut'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'patientId': patientId,
      'titre': titre,
      'objectif': objectif,
      'caloriesJournalieres': caloriesJournalieres,
      'dateDebut': _formatDate(dateDebut),
      'dateFin': dateFin == null ? null : _formatDate(dateFin!),
      'statut': statut,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');

    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
