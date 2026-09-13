from datetime import date, datetime, time
from typing import Literal

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    model_validator,
)


# =========================================================
# PATIENT
# =========================================================

class PatientBase(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
        from_attributes=True,
    )

    nom: str
    email: str
    pays: str
    indicatif: str
    telephone: str

    objectif_nutritionnel: str = Field(
        alias="objectifNutritionnel",
    )

    statut: str

    notifications_autorisees: bool = Field(
        alias="notificationsAutorisees",
    )


class PatientCreate(PatientBase):
    pass


class PatientUpdate(PatientBase):
    pass


class PatientResponse(PatientBase):
    id: int

    user_id: int = Field(
        alias="userId",
    )

    created_at: datetime = Field(
        alias="createdAt",
    )

    updated_at: datetime = Field(
        alias="updatedAt",
    )


# =========================================================
# USER
# =========================================================

class UserCreate(BaseModel):
    nom: str
    email: str
    password: str


class UserResponse(BaseModel):
    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
    )

    id: int
    nom: str
    email: str
    role: str

    created_at: datetime = Field(
        alias="createdAt",
    )

    updated_at: datetime = Field(
        alias="updatedAt",
    )


# =========================================================
# AUTH
# =========================================================

class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    user_id: int | None = None


# =========================================================
# PLAN NUTRITIONNEL
# =========================================================

class PlanNutritionnelBase(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
        from_attributes=True,
    )

    patient_id: int = Field(
        alias="patientId",
    )

    titre: str
    objectif: str

    calories_journalieres: int | None = Field(
        default=None,
        alias="caloriesJournalieres",
    )

    date_debut: date = Field(
        alias="dateDebut",
    )

    date_fin: date | None = Field(
        default=None,
        alias="dateFin",
    )

    statut: str = "Actif"

    notes: str | None = None


class PlanNutritionnelCreate(
    PlanNutritionnelBase
):
    pass


class PlanNutritionnelUpdate(
    PlanNutritionnelBase
):
    pass


class PlanNutritionnelResponse(
    PlanNutritionnelBase
):
    id: int

    user_id: int = Field(
        alias="userId",
    )

    created_at: datetime = Field(
        alias="createdAt",
    )

    updated_at: datetime = Field(
        alias="updatedAt",
    )


# =========================================================
# REPAS
# =========================================================

class PlanRepasBase(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
        from_attributes=True,
    )

    type_repas: str = Field(
        alias="typeRepas",
    )

    heure: time | None = None

    contenu: str

    calories: int | None = None

    ordre: int = 1

    notes: str | None = None


class PlanRepasCreate(
    PlanRepasBase
):
    pass


class PlanRepasUpdate(
    PlanRepasBase
):
    pass


class PlanRepasResponse(
    PlanRepasBase
):
    id: int

    jour_id: int = Field(
        alias="jourId",
    )

    created_at: datetime = Field(
        alias="createdAt",
    )

    updated_at: datetime = Field(
        alias="updatedAt",
    )


# =========================================================
# JOUR DU PROGRAMME
# =========================================================

class PlanJourBase(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
        from_attributes=True,
    )

    numero_jour: int = Field(
        alias="numeroJour",
        ge=1,
        le=14,
    )

    date_jour: date | None = Field(
        default=None,
        alias="dateJour",
    )

    objectif_journalier: str | None = Field(
        default=None,
        alias="objectifJournalier",
    )

    hydratation: str | None = None

    activite_physique: str | None = Field(
        default=None,
        alias="activitePhysique",
    )

    recommandations: str | None = None


class PlanJourCreate(
    PlanJourBase
):
    pass


class PlanJourUpdate(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
    )

    objectif_journalier: str | None = Field(
        default=None,
        alias="objectifJournalier",
    )

    hydratation: str | None = None

    activite_physique: str | None = Field(
        default=None,
        alias="activitePhysique",
    )

    recommandations: str | None = None


class PlanJourResponse(
    PlanJourBase
):
    id: int

    plan_id: int = Field(
        alias="planId",
    )

    created_at: datetime = Field(
        alias="createdAt",
    )

    updated_at: datetime = Field(
        alias="updatedAt",
    )


# =========================================================
# PROGRAMME COMPLET
# =========================================================

class PlanJourAvecRepasResponse(
    PlanJourResponse
):
    repas: list[PlanRepasResponse] = Field(
        default_factory=list,
    )


class ProgrammePlanResponse(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
    )

    plan_id: int = Field(
        alias="planId",
    )

    jours: list[
        PlanJourAvecRepasResponse
    ] = Field(
        default_factory=list,
    )


# =========================================================
# RENDEZ-VOUS
# =========================================================

TypeRendezVous = Literal[
    "En cabinet",
    "En ligne",
]

StatutRendezVous = Literal[
    "Planifié",
    "Confirmé",
    "Terminé",
    "Annulé",
    "Absent",
]


class RendezVousBase(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
        from_attributes=True,
    )

    patient_id: int = Field(
        alias="patientId",
        gt=0,
    )

    date_rendez_vous: date = Field(
        alias="dateRendezVous",
    )

    heure_debut: time = Field(
        alias="heureDebut",
    )

    heure_fin: time = Field(
        alias="heureFin",
    )

    motif: str = Field(
        min_length=2,
        max_length=200,
    )

    type_rendez_vous: TypeRendezVous = Field(
        default="En cabinet",
        alias="typeRendezVous",
    )

    statut: StatutRendezVous = "Planifié"

    rappel_patient_active: bool = Field(
        default=True,
        alias="rappelPatientActive",
    )

    notes: str | None = Field(
        default=None,
        max_length=2000,
    )

    @model_validator(mode="after")
    def valider_heures(self):
        if self.heure_fin <= self.heure_debut:
            raise ValueError(
                "L'heure de fin doit Ãªtre postérieure à l'heure de début."
            )

        return self


class RendezVousCreate(
    RendezVousBase
):
    pass


class RendezVousUpdate(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
    )

    patient_id: int | None = Field(
        default=None,
        alias="patientId",
        gt=0,
    )

    date_rendez_vous: date | None = Field(
        default=None,
        alias="dateRendezVous",
    )

    heure_debut: time | None = Field(
        default=None,
        alias="heureDebut",
    )

    heure_fin: time | None = Field(
        default=None,
        alias="heureFin",
    )

    motif: str | None = Field(
        default=None,
        min_length=2,
        max_length=200,
    )

    type_rendez_vous: TypeRendezVous | None = Field(
        default=None,
        alias="typeRendezVous",
    )

    statut: StatutRendezVous | None = None

    rappel_patient_active: bool | None = Field(
        default=None,
        alias="rappelPatientActive",
    )

    notes: str | None = Field(
        default=None,
        max_length=2000,
    )

    @model_validator(mode="after")
    def valider_heures(self):
        if (
            self.heure_debut is not None
            and self.heure_fin is not None
            and self.heure_fin <= self.heure_debut
        ):
            raise ValueError(
                "L'heure de fin doit Ãªtre postérieure à l'heure de début."
            )

        return self


class RendezVousResponse(
    RendezVousBase
):
    id: int

    user_id: int = Field(
        alias="userId",
    )

    created_at: datetime = Field(
        alias="createdAt",
    )

    updated_at: datetime = Field(
        alias="updatedAt",
    )


# =========================================================
# NOTIFICATIONS
# =========================================================

TypeNotification = Literal[
    "Rappel rendez-vous",
    "Rendez-vous modifié",
    "Rendez-vous annulé",
    "Information",
]

CanalNotification = Literal[
    "Application",
    "WhatsApp",
    "Email",
]

StatutNotification = Literal[
    "Programmé",
    "Envoyé",
    "Échoué",
]


class NotificationBase(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
        from_attributes=True,
    )

    patient_id: int = Field(
        alias="patientId",
        gt=0,
    )

    rendez_vous_id: int | None = Field(
        default=None,
        alias="rendezVousId",
        gt=0,
    )

    type_notification: TypeNotification = Field(
        default="Rappel rendez-vous",
        alias="typeNotification",
    )

    canal: CanalNotification = "Application"

    titre: str = Field(
        min_length=2,
        max_length=150,
    )

    message: str = Field(
        min_length=2,
        max_length=3000,
    )

    statut: StatutNotification = "Programmé"

    est_lue: bool = Field(
        default=False,
        alias="estLue",
    )

    date_programmee: datetime | None = Field(
        default=None,
        alias="dateProgrammee",
    )

    date_envoi: datetime | None = Field(
        default=None,
        alias="dateEnvoi",
    )

    erreur_envoi: str | None = Field(
        default=None,
        alias="erreurEnvoi",
        max_length=3000,
    )


class NotificationCreate(
    NotificationBase
):
    pass


class NotificationUpdate(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
    )

    patient_id: int | None = Field(
        default=None,
        alias="patientId",
        gt=0,
    )

    rendez_vous_id: int | None = Field(
        default=None,
        alias="rendezVousId",
        gt=0,
    )

    type_notification: TypeNotification | None = Field(
        default=None,
        alias="typeNotification",
    )

    canal: CanalNotification | None = None

    titre: str | None = Field(
        default=None,
        min_length=2,
        max_length=150,
    )

    message: str | None = Field(
        default=None,
        min_length=2,
        max_length=3000,
    )

    statut: StatutNotification | None = None

    est_lue: bool | None = Field(
        default=None,
        alias="estLue",
    )

    date_programmee: datetime | None = Field(
        default=None,
        alias="dateProgrammee",
    )

    date_envoi: datetime | None = Field(
        default=None,
        alias="dateEnvoi",
    )

    erreur_envoi: str | None = Field(
        default=None,
        alias="erreurEnvoi",
        max_length=3000,
    )


class NotificationResponse(
    NotificationBase
):
    id: int

    user_id: int = Field(
        alias="userId",
    )

    created_at: datetime = Field(
        alias="createdAt",
    )

    updated_at: datetime = Field(
        alias="updatedAt",
    )
