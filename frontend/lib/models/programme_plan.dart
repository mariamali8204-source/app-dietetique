class ProgrammePlan {
  final int planId;
  final List<PlanJour> jours;

  const ProgrammePlan({required this.planId, required this.jours});

  factory ProgrammePlan.fromJson(Map<String, dynamic> json) {
    return ProgrammePlan(
      planId: json['planId'] as int,
      jours: (json['jours'] as List<dynamic>)
          .map((item) => PlanJour.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  List<PlanJour> get semaine1 {
    return jours
        .where((jour) => jour.numeroJour >= 1 && jour.numeroJour <= 7)
        .toList();
  }

  List<PlanJour> get semaine2 {
    return jours
        .where((jour) => jour.numeroJour >= 8 && jour.numeroJour <= 14)
        .toList();
  }
}

class PlanJour {
  final int id;
  final int planId;
  final int numeroJour;
  final DateTime? dateJour;

  final String? objectifJournalier;
  final String? hydratation;
  final String? activitePhysique;
  final String? recommandations;

  final DateTime createdAt;
  final DateTime updatedAt;

  final List<PlanRepas> repas;

  const PlanJour({
    required this.id,
    required this.planId,
    required this.numeroJour,
    required this.dateJour,
    required this.objectifJournalier,
    required this.hydratation,
    required this.activitePhysique,
    required this.recommandations,
    required this.createdAt,
    required this.updatedAt,
    required this.repas,
  });

  factory PlanJour.fromJson(Map<String, dynamic> json) {
    return PlanJour(
      id: json['id'] as int,
      planId: json['planId'] as int,
      numeroJour: json['numeroJour'] as int,
      dateJour: json['dateJour'] == null
          ? null
          : DateTime.parse(json['dateJour'] as String),
      objectifJournalier: json['objectifJournalier'] as String?,
      hydratation: json['hydratation'] as String?,
      activitePhysique: json['activitePhysique'] as String?,
      recommandations: json['recommandations'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      repas: (json['repas'] as List<dynamic>)
          .map((item) => PlanRepas.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'objectifJournalier': objectifJournalier,
      'hydratation': hydratation,
      'activitePhysique': activitePhysique,
      'recommandations': recommandations,
    };
  }

  PlanJour copyWith({
    String? objectifJournalier,
    String? hydratation,
    String? activitePhysique,
    String? recommandations,
    List<PlanRepas>? repas,
  }) {
    return PlanJour(
      id: id,
      planId: planId,
      numeroJour: numeroJour,
      dateJour: dateJour,
      objectifJournalier: objectifJournalier ?? this.objectifJournalier,
      hydratation: hydratation ?? this.hydratation,
      activitePhysique: activitePhysique ?? this.activitePhysique,
      recommandations: recommandations ?? this.recommandations,
      createdAt: createdAt,
      updatedAt: updatedAt,
      repas: repas ?? this.repas,
    );
  }
}

class PlanRepas {
  final int id;
  final int jourId;

  final String typeRepas;
  final String? heure;
  final String contenu;
  final int? calories;
  final int ordre;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  const PlanRepas({
    required this.id,
    required this.jourId,
    required this.typeRepas,
    required this.heure,
    required this.contenu,
    required this.calories,
    required this.ordre,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanRepas.fromJson(Map<String, dynamic> json) {
    return PlanRepas(
      id: json['id'] as int,
      jourId: json['jourId'] as int,
      typeRepas: json['typeRepas'] as String,
      heure: json['heure'] as String?,
      contenu: json['contenu'] as String,
      calories: json['calories'] as int?,
      ordre: json['ordre'] as int,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'typeRepas': typeRepas,
      'heure': heure,
      'contenu': contenu,
      'calories': calories,
      'ordre': ordre,
      'notes': notes,
    };
  }

  PlanRepas copyWith({
    String? typeRepas,
    String? heure,
    String? contenu,
    int? calories,
    int? ordre,
    String? notes,
  }) {
    return PlanRepas(
      id: id,
      jourId: jourId,
      typeRepas: typeRepas ?? this.typeRepas,
      heure: heure ?? this.heure,
      contenu: contenu ?? this.contenu,
      calories: calories ?? this.calories,
      ordre: ordre ?? this.ordre,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
