class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.patientId,
    required this.rendezVousId,
    required this.typeNotification,
    required this.canal,
    required this.titre,
    required this.message,
    required this.statut,
    required this.estLue,
    required this.dateProgrammee,
    required this.dateEnvoi,
    required this.erreurEnvoi,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final int patientId;
  final int? rendezVousId;

  final String typeNotification;
  final String canal;
  final String titre;
  final String message;
  final String statut;

  final bool estLue;

  final DateTime? dateProgrammee;
  final DateTime? dateEnvoi;

  final String? erreurEnvoi;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      userId: json['userId'] as int,
      patientId: json['patientId'] as int,
      rendezVousId: json['rendezVousId'] as int?,
      typeNotification: json['typeNotification'] as String,
      canal: json['canal'] as String,
      titre: json['titre'] as String,
      message: json['message'] as String,
      statut: json['statut'] as String,
      estLue: json['estLue'] as bool,
      dateProgrammee: json['dateProgrammee'] == null
          ? null
          : DateTime.parse(json['dateProgrammee'] as String),
      dateEnvoi: json['dateEnvoi'] == null
          ? null
          : DateTime.parse(json['dateEnvoi'] as String),
      erreurEnvoi: json['erreurEnvoi'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get estProgrammee {
    return statut == 'Programmé';
  }

  bool get estEnvoyee {
    return statut == 'Envoyé';
  }

  bool get estEchouee {
    return statut == 'Échoué';
  }

  bool get estWhatsApp {
    return canal == 'WhatsApp';
  }

  AppNotification copyWith({
    int? id,
    int? userId,
    int? patientId,
    int? rendezVousId,
    String? typeNotification,
    String? canal,
    String? titre,
    String? message,
    String? statut,
    bool? estLue,
    DateTime? dateProgrammee,
    DateTime? dateEnvoi,
    String? erreurEnvoi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      patientId: patientId ?? this.patientId,
      rendezVousId: rendezVousId ?? this.rendezVousId,
      typeNotification: typeNotification ?? this.typeNotification,
      canal: canal ?? this.canal,
      titre: titre ?? this.titre,
      message: message ?? this.message,
      statut: statut ?? this.statut,
      estLue: estLue ?? this.estLue,
      dateProgrammee: dateProgrammee ?? this.dateProgrammee,
      dateEnvoi: dateEnvoi ?? this.dateEnvoi,
      erreurEnvoi: erreurEnvoi ?? this.erreurEnvoi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
