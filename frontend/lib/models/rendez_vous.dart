class RendezVous {
  const RendezVous({
    required this.id,
    required this.userId,
    required this.patientId,
    required this.dateRendezVous,
    required this.heureDebut,
    required this.heureFin,
    required this.motif,
    required this.typeRendezVous,
    required this.statut,
    required this.rappelPatientActive,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final int patientId;

  final DateTime dateRendezVous;

  final String heureDebut;
  final String heureFin;

  final String motif;
  final String typeRendezVous;
  final String statut;

  final bool rappelPatientActive;

  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory RendezVous.fromJson(Map<String, dynamic> json) {
    return RendezVous(
      id: json['id'] as int,
      userId: json['userId'] as int,
      patientId: json['patientId'] as int,
      dateRendezVous: DateTime.parse(json['dateRendezVous'] as String),
      heureDebut: json['heureDebut'] as String,
      heureFin: json['heureFin'] as String,
      motif: json['motif'] as String,
      typeRendezVous: json['typeRendezVous'] as String,
      statut: json['statut'] as String,
      rappelPatientActive: json['rappelPatientActive'] as bool,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'patientId': patientId,
      'dateRendezVous': _formatDateApi(dateRendezVous),
      'heureDebut': heureDebut,
      'heureFin': heureFin,
      'motif': motif,
      'typeRendezVous': typeRendezVous,
      'statut': statut,
      'rappelPatientActive': rappelPatientActive,
      'notes': notes,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'patientId': patientId,
      'dateRendezVous': _formatDateApi(dateRendezVous),
      'heureDebut': heureDebut,
      'heureFin': heureFin,
      'motif': motif,
      'typeRendezVous': typeRendezVous,
      'statut': statut,
      'rappelPatientActive': rappelPatientActive,
      'notes': notes,
    };
  }

  DateTime get dateHeureDebut {
    final morceaux = heureDebut.split(':');

    return DateTime(
      dateRendezVous.year,
      dateRendezVous.month,
      dateRendezVous.day,
      int.parse(morceaux[0]),
      int.parse(morceaux[1]),
    );
  }

  DateTime get dateHeureFin {
    final morceaux = heureFin.split(':');

    return DateTime(
      dateRendezVous.year,
      dateRendezVous.month,
      dateRendezVous.day,
      int.parse(morceaux[0]),
      int.parse(morceaux[1]),
    );
  }

  Duration get duree {
    return dateHeureFin.difference(dateHeureDebut);
  }

  bool get estAnnule {
    return statut == 'Annulé';
  }

  bool get estTermine {
    return statut == 'Terminé';
  }

  bool get estAbsent {
    return statut == 'Absent';
  }

  static String _formatDateApi(DateTime date) {
    final mois = date.month.toString().padLeft(2, '0');

    final jour = date.day.toString().padLeft(2, '0');

    return '${date.year}-$mois-$jour';
  }
}
