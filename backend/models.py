from datetime import date, datetime, time

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    Date,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    Time,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column

from database import Base


class PatientModel(Base):
    __tablename__ = "patients"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True,
    )

    user_id: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    nom: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    email: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    pays: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    indicatif: Mapped[str] = mapped_column(
        String(10),
        nullable=False,
    )

    telephone: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
    )

    objectif_nutritionnel: Mapped[str] = mapped_column(
        String(200),
        nullable=False,
    )

    statut: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
    )

    notifications_autorisees: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
        onupdate=datetime.now,
    )


class UserModel(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True,
    )

    nom: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    email: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
        unique=True,
        index=True,
    )

    hashed_password: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )

    role: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        default="dieteticien",
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
        onupdate=datetime.now,
    )


class PlanNutritionnelModel(Base):
    __tablename__ = "plans_nutritionnels"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey(
            "users.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    patient_id: Mapped[int] = mapped_column(
        ForeignKey(
            "patients.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    titre: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    objectif: Mapped[str] = mapped_column(
        String(200),
        nullable=False,
    )

    calories_journalieres: Mapped[int | None] = mapped_column(
        Integer,
        nullable=True,
    )

    date_debut: Mapped[date] = mapped_column(
        Date,
        nullable=False,
    )

    date_fin: Mapped[date | None] = mapped_column(
        Date,
        nullable=True,
    )

    statut: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        default="Actif",
    )

    notes: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
        onupdate=datetime.now,
    )


class PlanJourModel(Base):
    __tablename__ = "plan_jours"

    __table_args__ = (
        UniqueConstraint(
            "plan_id",
            "numero_jour",
            name="uq_plan_jour_numero",
        ),
        CheckConstraint(
            "numero_jour >= 1 AND numero_jour <= 14",
            name="ck_plan_jour_numero",
        ),
    )

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True,
    )

    plan_id: Mapped[int] = mapped_column(
        ForeignKey(
            "plans_nutritionnels.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    numero_jour: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    date_jour: Mapped[date | None] = mapped_column(
        Date,
        nullable=True,
    )

    objectif_journalier: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    hydratation: Mapped[str | None] = mapped_column(
        String(150),
        nullable=True,
    )

    activite_physique: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    recommandations: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
        onupdate=datetime.now,
    )


class PlanRepasModel(Base):
    __tablename__ = "plan_repas"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True,
    )

    jour_id: Mapped[int] = mapped_column(
        ForeignKey(
            "plan_jours.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    type_repas: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
    )

    heure: Mapped[time | None] = mapped_column(
        Time,
        nullable=True,
    )

    contenu: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    calories: Mapped[int | None] = mapped_column(
        Integer,
        nullable=True,
    )

    ordre: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        default=1,
    )

    notes: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
        onupdate=datetime.now,
    )


class RendezVousModel(Base):
    __tablename__ = "rendez_vous"

    __table_args__ = (
        CheckConstraint(
            "heure_fin > heure_debut",
            name="ck_rendez_vous_heures",
        ),
        Index(
            "ix_rendez_vous_user_date",
            "user_id",
            "date_rendez_vous",
        ),
    )

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey(
            "users.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    patient_id: Mapped[int] = mapped_column(
        ForeignKey(
            "patients.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    date_rendez_vous: Mapped[date] = mapped_column(
        Date,
        nullable=False,
        index=True,
    )

    heure_debut: Mapped[time] = mapped_column(
        Time,
        nullable=False,
    )

    heure_fin: Mapped[time] = mapped_column(
        Time,
        nullable=False,
    )

    motif: Mapped[str] = mapped_column(
        String(200),
        nullable=False,
    )

    type_rendez_vous: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        default="En cabinet",
    )

    statut: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        default="Planifié",
    )

    rappel_patient_active: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=True,
    )

    notes: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
        onupdate=datetime.now,
    )


class NotificationModel(Base):
    __tablename__ = "notifications"

    __table_args__ = (
        Index(
            "ix_notifications_user_statut_date",
            "user_id",
            "statut",
            "date_programmee",
        ),
    )

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey(
            "users.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    patient_id: Mapped[int] = mapped_column(
        ForeignKey(
            "patients.id",
            ondelete="CASCADE",
        ),
        nullable=False,
        index=True,
    )

    rendez_vous_id: Mapped[int | None] = mapped_column(
        ForeignKey(
            "rendez_vous.id",
            ondelete="SET NULL",
        ),
        nullable=True,
        index=True,
    )

    type_notification: Mapped[str] = mapped_column(
        String(80),
        nullable=False,
        default="Rappel rendez-vous",
    )

    canal: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
        default="Application",
    )

    titre: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    message: Mapped[str] = mapped_column(
        Text,
        nullable=False,
    )

    statut: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
        default="Programmé",
    )

    est_lue: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False,
        default=False,
    )

    date_programmee: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True,
        index=True,
    )

    date_envoi: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True,
    )

    erreur_envoi: Mapped[str | None] = mapped_column(
        Text,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        default=datetime.now,
        onupdate=datetime.now,
    )