from datetime import date, time, timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session

from models import (
    PatientModel,
    PlanJourModel,
    PlanNutritionnelModel,
    PlanRepasModel,
    RendezVousModel,
    NotificationModel,
    UserModel,
)
from schemas import (
    PatientCreate,
    PatientUpdate,
    PlanJourUpdate,
    PlanNutritionnelCreate,
    PlanNutritionnelUpdate,
    PlanRepasUpdate,
    RendezVousCreate,
    RendezVousUpdate,
    NotificationCreate,
    NotificationUpdate,
    UserCreate,
)
from security import get_password_hash


# =========================================================
# RENDEZ-VOUS EXCEPTIONS
# =========================================================

class RendezVousConflictError(Exception):
    pass


class RendezVousTimeError(Exception):
    pass


# =========================================================
# PATIENTS
# =========================================================

def get_patients(
    db: Session,
    user_id: int,
) -> list[PatientModel]:
    statement = (
        select(PatientModel)
        .where(
            PatientModel.user_id == user_id,
        )
        .order_by(PatientModel.id)
    )

    return list(
        db.scalars(statement).all()
    )


def get_patient(
    db: Session,
    patient_id: int,
    user_id: int,
) -> PatientModel | None:
    statement = select(
        PatientModel
    ).where(
        PatientModel.id == patient_id,
        PatientModel.user_id == user_id,
    )

    return db.scalars(
        statement
    ).first()


def create_patient(
    db: Session,
    patient: PatientCreate,
    user_id: int,
) -> PatientModel:
    patient_data = patient.model_dump(
        by_alias=False,
    )

    patient_data["user_id"] = user_id

    db_patient = PatientModel(
        **patient_data
    )

    db.add(db_patient)
    db.commit()
    db.refresh(db_patient)

    return db_patient


def update_patient(
    db: Session,
    patient_id: int,
    patient: PatientUpdate,
    user_id: int,
) -> PatientModel | None:
    db_patient = get_patient(
        db,
        patient_id,
        user_id,
    )

    if db_patient is None:
        return None

    patient_data = patient.model_dump(
        by_alias=False,
    )

    patient_data.pop(
        "user_id",
        None,
    )

    for field, value in patient_data.items():
        setattr(
            db_patient,
            field,
            value,
        )

    db.commit()
    db.refresh(db_patient)

    return db_patient


def delete_patient(
    db: Session,
    patient_id: int,
    user_id: int,
) -> PatientModel | None:
    db_patient = get_patient(
        db,
        patient_id,
        user_id,
    )

    if db_patient is None:
        return None

    db.delete(db_patient)
    db.commit()

    return db_patient


# =========================================================
# USERS
# =========================================================

def get_user(
    db: Session,
    user_id: int,
) -> UserModel | None:
    return db.get(
        UserModel,
        user_id,
    )


def get_user_by_email(
    db: Session,
    email: str,
) -> UserModel | None:
    statement = select(
        UserModel
    ).where(
        UserModel.email == email
    )

    return db.scalars(
        statement
    ).first()


def create_user(
    db: Session,
    user: UserCreate,
) -> UserModel:
    hashed_password = get_password_hash(
        user.password
    )

    db_user = UserModel(
        nom=user.nom,
        email=user.email,
        hashed_password=hashed_password,
        role="dieteticien",
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return db_user


# =========================================================
# PLANS NUTRITIONNELS
# =========================================================

def get_plans(
    db: Session,
    user_id: int,
) -> list[PlanNutritionnelModel]:
    statement = (
        select(
            PlanNutritionnelModel
        )
        .where(
            PlanNutritionnelModel.user_id
            == user_id
        )
        .order_by(
            PlanNutritionnelModel.id.desc()
        )
    )

    return list(
        db.scalars(statement).all()
    )


def get_plan(
    db: Session,
    plan_id: int,
    user_id: int,
) -> PlanNutritionnelModel | None:
    statement = select(
        PlanNutritionnelModel
    ).where(
        PlanNutritionnelModel.id
        == plan_id,
        PlanNutritionnelModel.user_id
        == user_id,
    )

    return db.scalars(
        statement
    ).first()


def create_plan(
    db: Session,
    plan: PlanNutritionnelCreate,
    user_id: int,
) -> PlanNutritionnelModel | None:
    patient = get_patient(
        db,
        plan.patient_id,
        user_id,
    )

    if patient is None:
        return None

    plan_data = plan.model_dump(
        by_alias=False,
    )

    plan_data["user_id"] = user_id

    plan_data["date_fin"] = (
        plan.date_debut
        + timedelta(days=13)
    )

    db_plan = PlanNutritionnelModel(
        **plan_data
    )

    db.add(db_plan)
    db.flush()

    types_repas = [
        (
            "Petit-déjeuner",
            1,
        ),
        (
            "Déjeuner",
            2,
        ),
        (
            "Collation",
            3,
        ),
        (
            "Dîner",
            4,
        ),
    ]

    for numero_jour in range(
        1,
        15,
    ):
        date_jour = (
            plan.date_debut
            + timedelta(
                days=numero_jour - 1
            )
        )

        db_jour = PlanJourModel(
            plan_id=db_plan.id,
            numero_jour=numero_jour,
            date_jour=date_jour,
            objectif_journalier=None,
            hydratation=None,
            activite_physique=None,
            recommandations=None,
        )

        db.add(db_jour)
        db.flush()

        for (
            type_repas,
            ordre,
        ) in types_repas:
            db_repas = PlanRepasModel(
                jour_id=db_jour.id,
                type_repas=type_repas,
                heure=None,
                contenu="",
                calories=None,
                ordre=ordre,
                notes=None,
            )

            db.add(db_repas)

    db.commit()
    db.refresh(db_plan)

    return db_plan


def update_plan(
    db: Session,
    plan_id: int,
    plan: PlanNutritionnelUpdate,
    user_id: int,
) -> PlanNutritionnelModel | None:
    db_plan = get_plan(
        db,
        plan_id,
        user_id,
    )

    if db_plan is None:
        return None

    patient = get_patient(
        db,
        plan.patient_id,
        user_id,
    )

    if patient is None:
        return None

    plan_data = plan.model_dump(
        by_alias=False,
    )

    plan_data["date_fin"] = (
        plan.date_debut
        + timedelta(days=13)
    )

    for field, value in plan_data.items():
        setattr(
            db_plan,
            field,
            value,
        )

    statement = (
        select(PlanJourModel)
        .where(
            PlanJourModel.plan_id
            == plan_id
        )
        .order_by(
            PlanJourModel.numero_jour
        )
    )

    jours = list(
        db.scalars(statement).all()
    )

    for jour in jours:
        jour.date_jour = (
            plan.date_debut
            + timedelta(
                days=jour.numero_jour - 1
            )
        )

    db.commit()
    db.refresh(db_plan)

    return db_plan


def delete_plan(
    db: Session,
    plan_id: int,
    user_id: int,
) -> PlanNutritionnelModel | None:
    db_plan = get_plan(
        db,
        plan_id,
        user_id,
    )

    if db_plan is None:
        return None

    db.delete(db_plan)
    db.commit()

    return db_plan


# =========================================================
# PROGRAMME SUR 14 JOURS
# =========================================================

def get_plan_days(
    db: Session,
    plan_id: int,
    user_id: int,
) -> list[PlanJourModel] | None:
    plan = get_plan(
        db,
        plan_id,
        user_id,
    )

    if plan is None:
        return None

    statement = (
        select(PlanJourModel)
        .where(
            PlanJourModel.plan_id
            == plan_id
        )
        .order_by(
            PlanJourModel.numero_jour
        )
    )

    return list(
        db.scalars(statement).all()
    )


def get_day_meals(
    db: Session,
    jour_id: int,
) -> list[PlanRepasModel]:
    statement = (
        select(PlanRepasModel)
        .where(
            PlanRepasModel.jour_id
            == jour_id
        )
        .order_by(
            PlanRepasModel.ordre
        )
    )

    return list(
        db.scalars(statement).all()
    )


def get_plan_programme(
    db: Session,
    plan_id: int,
    user_id: int,
) -> dict | None:
    jours = get_plan_days(
        db,
        plan_id,
        user_id,
    )

    if jours is None:
        return None

    programme_jours = []

    for jour in jours:
        repas = get_day_meals(
            db,
            jour.id,
        )

        programme_jours.append(
            {
                "id": jour.id,
                "planId": jour.plan_id,
                "numeroJour":
                    jour.numero_jour,
                "dateJour":
                    jour.date_jour,
                "objectifJournalier":
                    jour.objectif_journalier,
                "hydratation":
                    jour.hydratation,
                "activitePhysique":
                    jour.activite_physique,
                "recommandations":
                    jour.recommandations,
                "createdAt":
                    jour.created_at,
                "updatedAt":
                    jour.updated_at,
                "repas": repas,
            }
        )

    return {
        "planId": plan_id,
        "jours": programme_jours,
    }


def update_plan_day(
    db: Session,
    plan_id: int,
    jour_id: int,
    jour: PlanJourUpdate,
    user_id: int,
) -> PlanJourModel | None:
    plan = get_plan(
        db,
        plan_id,
        user_id,
    )

    if plan is None:
        return None

    statement = select(
        PlanJourModel
    ).where(
        PlanJourModel.id == jour_id,
        PlanJourModel.plan_id
        == plan_id,
    )

    db_jour = db.scalars(
        statement
    ).first()

    if db_jour is None:
        return None

    jour_data = jour.model_dump(
        by_alias=False,
    )

    for field, value in jour_data.items():
        setattr(
            db_jour,
            field,
            value,
        )

    db.commit()
    db.refresh(db_jour)

    return db_jour


def update_plan_meal(
    db: Session,
    plan_id: int,
    repas_id: int,
    repas: PlanRepasUpdate,
    user_id: int,
) -> PlanRepasModel | None:
    plan = get_plan(
        db,
        plan_id,
        user_id,
    )

    if plan is None:
        return None

    statement = (
        select(PlanRepasModel)
        .join(
            PlanJourModel,
            PlanRepasModel.jour_id
            == PlanJourModel.id,
        )
        .where(
            PlanRepasModel.id
            == repas_id,
            PlanJourModel.plan_id
            == plan_id,
        )
    )

    db_repas = db.scalars(
        statement
    ).first()

    if db_repas is None:
        return None

    repas_data = repas.model_dump(
        by_alias=False,
    )

    for field, value in repas_data.items():
        setattr(
            db_repas,
            field,
            value,
        )

    db.commit()
    db.refresh(db_repas)

    return db_repas


# =========================================================
# RENDEZ-VOUS
# =========================================================

def get_rendez_vous(
    db: Session,
    user_id: int,
    date_debut: date | None = None,
    date_fin: date | None = None,
) -> list[RendezVousModel]:
    statement = select(
        RendezVousModel
    ).where(
        RendezVousModel.user_id
        == user_id,
    )

    if date_debut is not None:
        statement = statement.where(
            RendezVousModel.date_rendez_vous
            >= date_debut
        )

    if date_fin is not None:
        statement = statement.where(
            RendezVousModel.date_rendez_vous
            <= date_fin
        )

    statement = statement.order_by(
        RendezVousModel.date_rendez_vous,
        RendezVousModel.heure_debut,
        RendezVousModel.id,
    )

    return list(
        db.scalars(statement).all()
    )


def get_rendez_vous_du_jour(
    db: Session,
    user_id: int,
    jour: date,
) -> list[RendezVousModel]:
    statement = (
        select(RendezVousModel)
        .where(
            RendezVousModel.user_id
            == user_id,
            RendezVousModel.date_rendez_vous
            == jour,
        )
        .order_by(
            RendezVousModel.heure_debut,
            RendezVousModel.id,
        )
    )

    return list(
        db.scalars(statement).all()
    )


def get_rendez_vous_by_id(
    db: Session,
    rendez_vous_id: int,
    user_id: int,
) -> RendezVousModel | None:
    statement = select(
        RendezVousModel
    ).where(
        RendezVousModel.id
        == rendez_vous_id,
        RendezVousModel.user_id
        == user_id,
    )

    return db.scalars(
        statement
    ).first()


def rendez_vous_en_conflit(
    db: Session,
    user_id: int,
    date_rendez_vous: date,
    heure_debut: time,
    heure_fin: time,
    rendez_vous_id_a_exclure: int | None = None,
) -> bool:
    statement = select(
        RendezVousModel.id
    ).where(
        RendezVousModel.user_id
        == user_id,
        RendezVousModel.date_rendez_vous
        == date_rendez_vous,
        RendezVousModel.statut != "Annulé",
        RendezVousModel.heure_debut
        < heure_fin,
        RendezVousModel.heure_fin
        > heure_debut,
    )

    if rendez_vous_id_a_exclure is not None:
        statement = statement.where(
            RendezVousModel.id
            != rendez_vous_id_a_exclure
        )

    rendez_vous_existant = db.scalars(
        statement.limit(1)
    ).first()

    return rendez_vous_existant is not None


def create_rendez_vous(
    db: Session,
    rendez_vous: RendezVousCreate,
    user_id: int,
) -> RendezVousModel | None:
    patient = get_patient(
        db,
        rendez_vous.patient_id,
        user_id,
    )

    if patient is None:
        return None

    if (
        rendez_vous.heure_fin
        <= rendez_vous.heure_debut
    ):
        raise RendezVousTimeError(
            "L'heure de fin doit Ãªtre "
            "postérieure à l'heure de début."
        )

    if (
        rendez_vous.statut != "Annulé"
        and rendez_vous_en_conflit(
            db=db,
            user_id=user_id,
            date_rendez_vous=
                rendez_vous.date_rendez_vous,
            heure_debut=
                rendez_vous.heure_debut,
            heure_fin=
                rendez_vous.heure_fin,
        )
    ):
        raise RendezVousConflictError(
            "Ce créneau chevauche "
            "un autre rendez-vous."
        )

    rendez_vous_data = (
        rendez_vous.model_dump(
            by_alias=False,
        )
    )

    rendez_vous_data[
        "user_id"
    ] = user_id

    db_rendez_vous = RendezVousModel(
        **rendez_vous_data
    )

    try:
        db.add(db_rendez_vous)
        db.commit()
        db.refresh(db_rendez_vous)
    except Exception:
        db.rollback()
        raise

    return db_rendez_vous


def update_rendez_vous(
    db: Session,
    rendez_vous_id: int,
    rendez_vous: RendezVousUpdate,
    user_id: int,
) -> RendezVousModel | None:
    db_rendez_vous = get_rendez_vous_by_id(
        db,
        rendez_vous_id,
        user_id,
    )

    if db_rendez_vous is None:
        return None

    rendez_vous_data = (
        rendez_vous.model_dump(
            by_alias=False,
            exclude_unset=True,
        )
    )

    patient_id = rendez_vous_data.get(
        "patient_id",
        db_rendez_vous.patient_id,
    )

    patient = get_patient(
        db,
        patient_id,
        user_id,
    )

    if patient is None:
        return None

    date_effective = (
        rendez_vous_data.get(
            "date_rendez_vous",
            db_rendez_vous.date_rendez_vous,
        )
    )

    heure_debut_effective = (
        rendez_vous_data.get(
            "heure_debut",
            db_rendez_vous.heure_debut,
        )
    )

    heure_fin_effective = (
        rendez_vous_data.get(
            "heure_fin",
            db_rendez_vous.heure_fin,
        )
    )

    statut_effectif = (
        rendez_vous_data.get(
            "statut",
            db_rendez_vous.statut,
        )
    )

    if (
        heure_fin_effective
        <= heure_debut_effective
    ):
        raise RendezVousTimeError(
            "L'heure de fin doit Ãªtre "
            "postérieure à l'heure de début."
        )

    if (
        statut_effectif != "Annulé"
        and rendez_vous_en_conflit(
            db=db,
            user_id=user_id,
            date_rendez_vous=date_effective,
            heure_debut=
                heure_debut_effective,
            heure_fin=
                heure_fin_effective,
            rendez_vous_id_a_exclure=
                rendez_vous_id,
        )
    ):
        raise RendezVousConflictError(
            "Ce créneau chevauche "
            "un autre rendez-vous."
        )

    for (
        field,
        value,
    ) in rendez_vous_data.items():
        setattr(
            db_rendez_vous,
            field,
            value,
        )

    try:
        db.commit()
        db.refresh(db_rendez_vous)
    except Exception:
        db.rollback()
        raise

    return db_rendez_vous


def delete_rendez_vous(
    db: Session,
    rendez_vous_id: int,
    user_id: int,
) -> RendezVousModel | None:
    db_rendez_vous = get_rendez_vous_by_id(
        db,
        rendez_vous_id,
        user_id,
    )

    if db_rendez_vous is None:
        return None

    try:
        db.delete(db_rendez_vous)
        db.commit()
    except Exception:
        db.rollback()
        raise

    return db_rendez_vous


# =========================================================
# NOTIFICATIONS
# =========================================================

def get_notifications(
    db: Session,
    user_id: int,
    est_lue: bool | None = None,
    statut: str | None = None,
) -> list[NotificationModel]:
    statement = select(
        NotificationModel
    ).where(
        NotificationModel.user_id == user_id,
    )

    if est_lue is not None:
        statement = statement.where(
            NotificationModel.est_lue == est_lue,
        )

    if statut is not None:
        statement = statement.where(
            NotificationModel.statut == statut,
        )

    statement = statement.order_by(
        NotificationModel.created_at.desc(),
        NotificationModel.id.desc(),
    )

    return list(
        db.scalars(statement).all()
    )


def get_notification_by_id(
    db: Session,
    notification_id: int,
    user_id: int,
) -> NotificationModel | None:
    statement = select(
        NotificationModel
    ).where(
        NotificationModel.id == notification_id,
        NotificationModel.user_id == user_id,
    )

    return db.scalars(
        statement
    ).first()


def get_notifications_non_lues_count(
    db: Session,
    user_id: int,
) -> int:
    statement = select(
        NotificationModel.id
    ).where(
        NotificationModel.user_id == user_id,
        NotificationModel.est_lue.is_(False),
    )

    return len(
        list(
            db.scalars(statement).all()
        )
    )


def create_notification(
    db: Session,
    notification: NotificationCreate,
    user_id: int,
) -> NotificationModel | None:
    patient = get_patient(
        db,
        notification.patient_id,
        user_id,
    )

    if patient is None:
        return None

    if notification.rendez_vous_id is not None:
        rendez_vous = get_rendez_vous_by_id(
            db,
            notification.rendez_vous_id,
            user_id,
        )

        if rendez_vous is None:
            return None

        if rendez_vous.patient_id != notification.patient_id:
            return None

    notification_data = notification.model_dump(
        by_alias=False,
    )

    notification_data["user_id"] = user_id

    db_notification = NotificationModel(
        **notification_data
    )

    try:
        db.add(db_notification)
        db.commit()
        db.refresh(db_notification)
    except Exception:
        db.rollback()
        raise

    return db_notification


def update_notification(
    db: Session,
    notification_id: int,
    notification: NotificationUpdate,
    user_id: int,
) -> NotificationModel | None:
    db_notification = get_notification_by_id(
        db,
        notification_id,
        user_id,
    )

    if db_notification is None:
        return None

    notification_data = notification.model_dump(
        by_alias=False,
        exclude_unset=True,
    )

    patient_id = notification_data.get(
        "patient_id",
        db_notification.patient_id,
    )

    patient = get_patient(
        db,
        patient_id,
        user_id,
    )

    if patient is None:
        return None

    rendez_vous_id = notification_data.get(
        "rendez_vous_id",
        db_notification.rendez_vous_id,
    )

    if rendez_vous_id is not None:
        rendez_vous = get_rendez_vous_by_id(
            db,
            rendez_vous_id,
            user_id,
        )

        if rendez_vous is None:
            return None

        if rendez_vous.patient_id != patient_id:
            return None

    for field, value in notification_data.items():
        setattr(
            db_notification,
            field,
            value,
        )

    try:
        db.commit()
        db.refresh(db_notification)
    except Exception:
        db.rollback()
        raise

    return db_notification


def marquer_notification_lue(
    db: Session,
    notification_id: int,
    user_id: int,
) -> NotificationModel | None:
    db_notification = get_notification_by_id(
        db,
        notification_id,
        user_id,
    )

    if db_notification is None:
        return None

    db_notification.est_lue = True

    try:
        db.commit()
        db.refresh(db_notification)
    except Exception:
        db.rollback()
        raise

    return db_notification


def marquer_toutes_notifications_lues(
    db: Session,
    user_id: int,
) -> list[NotificationModel]:
    notifications = get_notifications(
        db,
        user_id,
        est_lue=False,
    )

    if not notifications:
        return []

    for notification in notifications:
        notification.est_lue = True

    try:
        db.commit()

        for notification in notifications:
            db.refresh(notification)
    except Exception:
        db.rollback()
        raise

    return notifications


def delete_notification(
    db: Session,
    notification_id: int,
    user_id: int,
) -> NotificationModel | None:
    db_notification = get_notification_by_id(
        db,
        notification_id,
        user_id,
    )

    if db_notification is None:
        return None

    try:
        db.delete(db_notification)
        db.commit()
    except Exception:
        db.rollback()
        raise

    return db_notification
