from __future__ import annotations

from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

from apscheduler.schedulers.background import BackgroundScheduler
from sqlalchemy import select
from sqlalchemy.orm import Session

from database import SessionLocal
from email_service import EmailSendError, envoyer_email
from models import NotificationModel, PatientModel, RendezVousModel


TIMEZONE = ZoneInfo("Asia/Beirut")
RAPPEL_AVANT = timedelta(hours=2)

_scheduler: BackgroundScheduler | None = None


def _maintenant_local() -> datetime:
    return datetime.now(TIMEZONE)


def _datetime_rendez_vous(rendez_vous: RendezVousModel) -> datetime:
    return datetime.combine(
        rendez_vous.date_rendez_vous,
        rendez_vous.heure_debut,
        tzinfo=TIMEZONE,
    )


def _message_rappel(
    patient: PatientModel,
    rendez_vous: RendezVousModel,
) -> tuple[str, str]:
    date_texte = rendez_vous.date_rendez_vous.strftime("%d/%m/%Y")
    heure_texte = rendez_vous.heure_debut.strftime("%H:%M")

    sujet = "Rappel de votre rendez-vous – NutriCare Pro"

    message = (
        f"Bonjour {patient.nom},\n\n"
        "Petit rappel : vous avez un rendez-vous "
        f"le {date_texte} à {heure_texte} avec NutriCare Pro.\n\n"
        f"Motif : {rendez_vous.motif}\n"
        f"Type : {rendez_vous.type_rendez_vous}\n\n"
        "Merci et à bientôt,\n"
        "NutriCare Pro"
    )

    return sujet, message


def _notification_existante(
    db: Session,
    rendez_vous_id: int,
) -> NotificationModel | None:
    statement = (
        select(NotificationModel)
        .where(
            NotificationModel.rendez_vous_id == rendez_vous_id,
            NotificationModel.type_notification == "Rappel rendez-vous",
            NotificationModel.canal == "Email",
        )
        .order_by(NotificationModel.id.desc())
    )

    return db.scalars(statement).first()


def _creer_ou_recuperer_notification(
    db: Session,
    *,
    rendez_vous: RendezVousModel,
    sujet: str,
    message: str,
    date_programmee: datetime,
) -> NotificationModel:
    notification = _notification_existante(
        db,
        rendez_vous.id,
    )

    if notification is not None:
        notification.titre = sujet
        notification.message = message
        notification.date_programmee = date_programmee.replace(tzinfo=None)
        return notification

    notification = NotificationModel(
        user_id=rendez_vous.user_id,
        patient_id=rendez_vous.patient_id,
        rendez_vous_id=rendez_vous.id,
        type_notification="Rappel rendez-vous",
        canal="Email",
        titre=sujet,
        message=message,
        statut="Programmé",
        est_lue=False,
        date_programmee=date_programmee.replace(tzinfo=None),
        date_envoi=None,
        erreur_envoi=None,
    )

    db.add(notification)
    db.flush()

    return notification


def traiter_rappels_rendez_vous() -> None:
    db = SessionLocal()

    try:
        maintenant = _maintenant_local()
        limite = maintenant + RAPPEL_AVANT

        dates_a_verifier = {
            maintenant.date(),
            limite.date(),
        }

        statement = (
            select(RendezVousModel, PatientModel)
            .join(
                PatientModel,
                PatientModel.id == RendezVousModel.patient_id,
            )
            .where(
                RendezVousModel.date_rendez_vous.in_(dates_a_verifier),
                RendezVousModel.rappel_patient_active.is_(True),
                RendezVousModel.statut.in_(["Planifié", "Confirmé"]),
                PatientModel.notifications_autorisees.is_(True),
            )
            .order_by(
                RendezVousModel.date_rendez_vous,
                RendezVousModel.heure_debut,
            )
        )

        lignes = db.execute(statement).all()

        for rendez_vous, patient in lignes:
            date_heure_rendez_vous = _datetime_rendez_vous(
                rendez_vous
            )

            if not (
                maintenant
                < date_heure_rendez_vous
                <= limite
            ):
                continue

            notification = _notification_existante(
                db,
                rendez_vous.id,
            )

            if (
                notification is not None
                and notification.statut == "Envoyé"
            ):
                continue

            email_patient = (patient.email or "").strip()

            date_programmee = (
                date_heure_rendez_vous - RAPPEL_AVANT
            )

            sujet, message = _message_rappel(
                patient,
                rendez_vous,
            )

            notification = _creer_ou_recuperer_notification(
                db,
                rendez_vous=rendez_vous,
                sujet=sujet,
                message=message,
                date_programmee=date_programmee,
            )

            if not email_patient:
                notification.statut = "Échoué"
                notification.date_envoi = None
                notification.erreur_envoi = (
                    "Le patient ne possède pas d’adresse e-mail."
                )
                db.commit()
                continue

            try:
                envoyer_email(
                    destinataire=email_patient,
                    sujet=sujet,
                    message=message,
                )

                notification.statut = "Envoyé"
                notification.date_envoi = datetime.now()
                notification.erreur_envoi = None

            except EmailSendError as error:
                notification.statut = "Échoué"
                notification.date_envoi = None
                notification.erreur_envoi = str(error)[:3000]

            except Exception as error:
                notification.statut = "Échoué"
                notification.date_envoi = None
                notification.erreur_envoi = str(error)[:3000]

            db.commit()

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


def demarrer_scheduler_rappels() -> None:
    global _scheduler

    if _scheduler is not None and _scheduler.running:
        return

    _scheduler = BackgroundScheduler(
        timezone=TIMEZONE,
    )

    _scheduler.add_job(
        traiter_rappels_rendez_vous,
        trigger="interval",
        minutes=1,
        id="rappels_rendez_vous_email",
        replace_existing=True,
        max_instances=1,
        coalesce=True,
    )

    _scheduler.start()


def arreter_scheduler_rappels() -> None:
    global _scheduler

    if _scheduler is None:
        return

    if _scheduler.running:
        _scheduler.shutdown(wait=False)

    _scheduler = None
