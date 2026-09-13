from contextlib import asynccontextmanager
from datetime import date, datetime
from typing import Annotated

from fastapi import (
    Depends,
    FastAPI,
    HTTPException,
    Query,
    status,
)
from fastapi.security import (
    OAuth2PasswordRequestForm,
)
from sqlalchemy.orm import Session

import crud
from auth import get_current_user
from database import Base, engine, get_db
from models import UserModel
from schemas import (
    NotificationCreate,
    NotificationResponse,
    NotificationUpdate,
    PatientCreate,
    PatientResponse,
    PatientUpdate,
    PlanJourResponse,
    PlanJourUpdate,
    PlanNutritionnelCreate,
    PlanNutritionnelResponse,
    PlanNutritionnelUpdate,
    PlanRepasResponse,
    PlanRepasUpdate,
    ProgrammePlanResponse,
    RendezVousCreate,
    RendezVousResponse,
    RendezVousUpdate,
    Token,
    UserCreate,
    UserResponse,
)
from security import (
    create_access_token,
    verify_password,
)

from email_service import (
    EmailConfigurationError,
    EmailSendError,
    envoyer_email,
)

from reminder_service import (
    arreter_scheduler_rappels,
    demarrer_scheduler_rappels,
)


from whatsapp_service import (
    WhatsAppConfigurationError,
    WhatsAppSendError,
    envoyer_message_whatsapp,
)


Base.metadata.create_all(
    bind=engine,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    demarrer_scheduler_rappels()

    try:
        yield
    finally:
        arreter_scheduler_rappels()


app = FastAPI(
    title="NutriCare Pro API",
    version="6.3.0",
    lifespan=lifespan,
)


DbSession = Annotated[
    Session,
    Depends(get_db),
]


CurrentUser = Annotated[
    UserModel,
    Depends(get_current_user),
]


# =========================================================
# GENERAL
# =========================================================

@app.get("/")
def root():
    return {
        "message": "NutriCare Pro API",
    }


@app.get("/health")
def health():
    return {
        "status": "ok",
        "message": "Backend FastAPI connecté",
    }


# =========================================================
# AUTHENTIFICATION
# =========================================================

@app.post(
    "/auth/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
def register_user(
    user: UserCreate,
    db: DbSession,
):
    existing_user = crud.get_user_by_email(
        db,
        user.email,
    )

    if existing_user is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "Un utilisateur avec cet e-mail "
                "existe déjà"
            ),
        )

    return crud.create_user(
        db,
        user,
    )


@app.post(
    "/auth/login",
    response_model=Token,
)
def login_user(
    form_data: Annotated[
        OAuth2PasswordRequestForm,
        Depends(),
    ],
    db: DbSession,
):
    user = crud.get_user_by_email(
        db,
        form_data.username,
    )

    if user is None or not verify_password(
        form_data.password,
        user.hashed_password,
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=(
                "E-mail ou mot de passe incorrect"
            ),
            headers={
                "WWW-Authenticate": "Bearer",
            },
        )

    access_token = create_access_token(
        {
            "sub": str(user.id),
        }
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
    }


@app.get(
    "/auth/me",
    response_model=UserResponse,
)
def get_authenticated_user(
    current_user: CurrentUser,
):
    return current_user


# =========================================================
# PATIENTS
# =========================================================

@app.get(
    "/patients",
    response_model=list[PatientResponse],
)
def get_patients(
    db: DbSession,
    current_user: CurrentUser,
):
    return crud.get_patients(
        db,
        current_user.id,
    )


@app.get(
    "/patients/{patient_id}",
    response_model=PatientResponse,
)
def get_patient(
    patient_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    patient = crud.get_patient(
        db,
        patient_id,
        current_user.id,
    )

    if patient is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient introuvable",
        )

    return patient


@app.post(
    "/patients",
    response_model=PatientResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_patient(
    patient: PatientCreate,
    db: DbSession,
    current_user: CurrentUser,
):
    return crud.create_patient(
        db,
        patient,
        current_user.id,
    )


@app.put(
    "/patients/{patient_id}",
    response_model=PatientResponse,
)
def update_patient(
    patient_id: int,
    patient: PatientUpdate,
    db: DbSession,
    current_user: CurrentUser,
):
    patient_updated = crud.update_patient(
        db,
        patient_id,
        patient,
        current_user.id,
    )

    if patient_updated is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient introuvable",
        )

    return patient_updated


@app.delete(
    "/patients/{patient_id}",
)
def delete_patient(
    patient_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    patient_deleted = crud.delete_patient(
        db,
        patient_id,
        current_user.id,
    )

    if patient_deleted is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient introuvable",
        )

    return {
        "message": (
            "Patient supprimé avec succès"
        ),
        "patientId": patient_id,
    }


# =========================================================
# PLANS NUTRITIONNELS
# =========================================================

@app.get(
    "/plans",
    response_model=list[
        PlanNutritionnelResponse
    ],
)
def get_plans(
    db: DbSession,
    current_user: CurrentUser,
):
    return crud.get_plans(
        db,
        current_user.id,
    )


@app.get(
    "/plans/{plan_id}",
    response_model=PlanNutritionnelResponse,
)
def get_plan(
    plan_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    plan = crud.get_plan(
        db,
        plan_id,
        current_user.id,
    )

    if plan is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Plan nutritionnel introuvable"
            ),
        )

    return plan


@app.post(
    "/plans",
    response_model=PlanNutritionnelResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_plan(
    plan: PlanNutritionnelCreate,
    db: DbSession,
    current_user: CurrentUser,
):
    plan_created = crud.create_plan(
        db,
        plan,
        current_user.id,
    )

    if plan_created is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Patient introuvable ou "
                "non autorisé"
            ),
        )

    return plan_created


@app.put(
    "/plans/{plan_id}",
    response_model=PlanNutritionnelResponse,
)
def update_plan(
    plan_id: int,
    plan: PlanNutritionnelUpdate,
    db: DbSession,
    current_user: CurrentUser,
):
    plan_updated = crud.update_plan(
        db,
        plan_id,
        plan,
        current_user.id,
    )

    if plan_updated is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Plan nutritionnel ou "
                "patient introuvable"
            ),
        )

    return plan_updated


@app.delete(
    "/plans/{plan_id}",
)
def delete_plan(
    plan_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    plan_deleted = crud.delete_plan(
        db,
        plan_id,
        current_user.id,
    )

    if plan_deleted is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Plan nutritionnel introuvable"
            ),
        )

    return {
        "message": (
            "Plan nutritionnel supprimé "
            "avec succès"
        ),
        "planId": plan_id,
    }


# =========================================================
# PROGRAMME NUTRITIONNEL — 14 JOURS
# =========================================================

@app.get(
    "/plans/{plan_id}/programme",
    response_model=ProgrammePlanResponse,
)
def get_plan_programme(
    plan_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    programme = crud.get_plan_programme(
        db,
        plan_id,
        current_user.id,
    )

    if programme is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Plan nutritionnel introuvable"
            ),
        )

    return programme


@app.patch(
    "/plans/{plan_id}/jours/{jour_id}",
    response_model=PlanJourResponse,
)
def update_plan_day(
    plan_id: int,
    jour_id: int,
    jour: PlanJourUpdate,
    db: DbSession,
    current_user: CurrentUser,
):
    jour_updated = crud.update_plan_day(
        db,
        plan_id,
        jour_id,
        jour,
        current_user.id,
    )

    if jour_updated is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Jour du programme introuvable"
            ),
        )

    return jour_updated


@app.patch(
    "/plans/{plan_id}/repas/{repas_id}",
    response_model=PlanRepasResponse,
)
def update_plan_meal(
    plan_id: int,
    repas_id: int,
    repas: PlanRepasUpdate,
    db: DbSession,
    current_user: CurrentUser,
):
    repas_updated = crud.update_plan_meal(
        db,
        plan_id,
        repas_id,
        repas,
        current_user.id,
    )

    if repas_updated is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Repas introuvable",
        )

    return repas_updated


# =========================================================
# RENDEZ-VOUS
# =========================================================

@app.get(
    "/rendez-vous",
    response_model=list[RendezVousResponse],
)
def get_rendez_vous(
    db: DbSession,
    current_user: CurrentUser,
    date_debut: date | None = Query(
        default=None,
        alias="dateDebut",
    ),
    date_fin: date | None = Query(
        default=None,
        alias="dateFin",
    ),
):
    if (
        date_debut is not None
        and date_fin is not None
        and date_fin < date_debut
    ):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=(
                "La date de fin doit être "
                "postérieure ou égale Ã  la date de début."
            ),
        )

    return crud.get_rendez_vous(
        db=db,
        user_id=current_user.id,
        date_debut=date_debut,
        date_fin=date_fin,
    )


@app.get(
    "/rendez-vous/jour/{jour}",
    response_model=list[RendezVousResponse],
)
def get_rendez_vous_du_jour(
    jour: date,
    db: DbSession,
    current_user: CurrentUser,
):
    return crud.get_rendez_vous_du_jour(
        db=db,
        user_id=current_user.id,
        jour=jour,
    )


@app.get(
    "/rendez-vous/{rendez_vous_id}",
    response_model=RendezVousResponse,
)
def get_rendez_vous_by_id(
    rendez_vous_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    rendez_vous = (
        crud.get_rendez_vous_by_id(
            db=db,
            rendez_vous_id=rendez_vous_id,
            user_id=current_user.id,
        )
    )

    if rendez_vous is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Rendez-vous introuvable",
        )

    return rendez_vous


@app.post(
    "/rendez-vous",
    response_model=RendezVousResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_rendez_vous(
    rendez_vous: RendezVousCreate,
    db: DbSession,
    current_user: CurrentUser,
):
    try:
        rendez_vous_created = (
            crud.create_rendez_vous(
                db=db,
                rendez_vous=rendez_vous,
                user_id=current_user.id,
            )
        )

    except crud.RendezVousConflictError as error:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(error),
        ) from error

    except crud.RendezVousTimeError as error:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(error),
        ) from error

    if rendez_vous_created is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Patient introuvable ou "
                "non autorisé"
            ),
        )

    return rendez_vous_created


@app.patch(
    "/rendez-vous/{rendez_vous_id}",
    response_model=RendezVousResponse,
)
def update_rendez_vous(
    rendez_vous_id: int,
    rendez_vous: RendezVousUpdate,
    db: DbSession,
    current_user: CurrentUser,
):
    try:
        rendez_vous_updated = (
            crud.update_rendez_vous(
                db=db,
                rendez_vous_id=rendez_vous_id,
                rendez_vous=rendez_vous,
                user_id=current_user.id,
            )
        )

    except crud.RendezVousConflictError as error:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(error),
        ) from error

    except crud.RendezVousTimeError as error:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(error),
        ) from error

    if rendez_vous_updated is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Rendez-vous ou patient "
                "introuvable"
            ),
        )

    return rendez_vous_updated


@app.delete(
    "/rendez-vous/{rendez_vous_id}",
)
def delete_rendez_vous(
    rendez_vous_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    rendez_vous_deleted = (
        crud.delete_rendez_vous(
            db=db,
            rendez_vous_id=rendez_vous_id,
            user_id=current_user.id,
        )
    )

    if rendez_vous_deleted is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Rendez-vous introuvable",
        )

    return {
        "message": (
            "Rendez-vous supprimé avec succès"
        ),
        "rendezVousId": rendez_vous_id,
    }


# =========================================================
# NOTIFICATIONS
# =========================================================

@app.get(
    "/notifications",
    response_model=list[NotificationResponse],
)
def get_notifications(
    db: DbSession,
    current_user: CurrentUser,
    est_lue: bool | None = Query(
        default=None,
        alias="estLue",
    ),
    statut_notification: str | None = Query(
        default=None,
        alias="statut",
    ),
):
    return crud.get_notifications(
        db=db,
        user_id=current_user.id,
        est_lue=est_lue,
        statut=statut_notification,
    )


@app.get(
    "/notifications/non-lues/count",
)
def get_notifications_non_lues_count(
    db: DbSession,
    current_user: CurrentUser,
):
    return {
        "count": crud.get_notifications_non_lues_count(
            db=db,
            user_id=current_user.id,
        ),
    }


@app.patch(
    "/notifications/tout-lire",
)
def marquer_toutes_notifications_lues(
    db: DbSession,
    current_user: CurrentUser,
):
    notifications = crud.marquer_toutes_notifications_lues(
        db=db,
        user_id=current_user.id,
    )

    return {
        "message": "Toutes les notifications ont été marquées comme lues.",
        "nombre": len(notifications),
    }


@app.get(
    "/notifications/{notification_id}",
    response_model=NotificationResponse,
)
def get_notification_by_id(
    notification_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    notification = crud.get_notification_by_id(
        db=db,
        notification_id=notification_id,
        user_id=current_user.id,
    )

    if notification is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification introuvable",
        )

    return notification


@app.post(
    "/notifications",
    response_model=NotificationResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_notification(
    notification: NotificationCreate,
    db: DbSession,
    current_user: CurrentUser,
):
    notification_created = crud.create_notification(
        db=db,
        notification=notification,
        user_id=current_user.id,
    )

    if notification_created is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Patient ou rendez-vous introuvable, "
                "non autorisé ou incohérent"
            ),
        )

    return notification_created


@app.patch(
    "/notifications/{notification_id}",
    response_model=NotificationResponse,
)
def update_notification(
    notification_id: int,
    notification: NotificationUpdate,
    db: DbSession,
    current_user: CurrentUser,
):
    notification_updated = crud.update_notification(
        db=db,
        notification_id=notification_id,
        notification=notification,
        user_id=current_user.id,
    )

    if notification_updated is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Notification, patient ou rendez-vous introuvable"
            ),
        )

    return notification_updated


@app.patch(
    "/notifications/{notification_id}/lue",
    response_model=NotificationResponse,
)
def marquer_notification_lue(
    notification_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    notification = crud.marquer_notification_lue(
        db=db,
        notification_id=notification_id,
        user_id=current_user.id,
    )

    if notification is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification introuvable",
        )

    return notification




@app.post(
    "/notifications/{notification_id}/envoyer-whatsapp",
    response_model=NotificationResponse,
)
def envoyer_notification_whatsapp(
    notification_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    notification = crud.get_notification_by_id(
        db=db,
        notification_id=notification_id,
        user_id=current_user.id,
    )

    if notification is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification introuvable",
        )

    patient = crud.get_patient(
        db=db,
        patient_id=notification.patient_id,
        user_id=current_user.id,
    )

    if patient is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient introuvable",
        )

    if not patient.notifications_autorisees:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Le patient n'autorise pas les notifications."
            ),
        )

    try:
        envoyer_message_whatsapp(
            indicatif=patient.indicatif,
            telephone=patient.telephone,
            message=notification.message,
        )
    except (
        WhatsAppConfigurationError,
        WhatsAppSendError,
    ) as error:
        crud.update_notification(
            db=db,
            notification_id=notification_id,
            notification=NotificationUpdate(
                canal="WhatsApp",
                statut="Échoué",
                erreurEnvoi=str(error),
            ),
            user_id=current_user.id,
        )

        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=(
                "Échec de l'envoi WhatsApp. "
                "Vérifiez la configuration du Sandbox "
                "et le numéro du patient."
            ),
        ) from error

    notification_updated = crud.update_notification(
        db=db,
        notification_id=notification_id,
        notification=NotificationUpdate(
            canal="WhatsApp",
            statut="Envoyé",
            dateEnvoi=datetime.now(),
            erreurEnvoi=None,
        ),
        user_id=current_user.id,
    )

    if notification_updated is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification introuvable",
        )

    return notification_updated


@app.post(
    "/notifications/{notification_id}/envoyer-email",
    response_model=NotificationResponse,
)
def envoyer_notification_email(
    notification_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    notification = crud.get_notification_by_id(
        db=db,
        notification_id=notification_id,
        user_id=current_user.id,
    )

    if notification is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification introuvable",
        )

    patient = crud.get_patient(
        db=db,
        patient_id=notification.patient_id,
        user_id=current_user.id,
    )

    if patient is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient introuvable",
        )

    if not patient.notifications_autorisees:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Le patient n'autorise pas les notifications."
            ),
        )

    if not patient.email or not patient.email.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Le patient ne possède pas d'adresse e-mail.",
        )

    try:
        envoyer_email(
            destinataire=patient.email.strip(),
            sujet=notification.titre,
            message=notification.message,
        )
    except (
        EmailConfigurationError,
        EmailSendError,
    ) as error:
        crud.update_notification(
            db=db,
            notification_id=notification_id,
            notification=NotificationUpdate(
                canal="Email",
                statut="Échoué",
                erreurEnvoi=str(error),
            ),
            user_id=current_user.id,
        )

        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=(
                "Échec de l'envoi de l'e-mail. "
                "Vérifiez la configuration SMTP "
                "et l'adresse e-mail du patient."
            ),
        ) from error

    notification_updated = crud.update_notification(
        db=db,
        notification_id=notification_id,
        notification=NotificationUpdate(
            canal="Email",
            statut="Envoyé",
            dateEnvoi=datetime.now(),
            erreurEnvoi=None,
        ),
        user_id=current_user.id,
    )

    if notification_updated is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification introuvable",
        )

    return notification_updated


@app.delete(
    "/notifications/{notification_id}",
)
def delete_notification(
    notification_id: int,
    db: DbSession,
    current_user: CurrentUser,
):
    notification_deleted = crud.delete_notification(
        db=db,
        notification_id=notification_id,
        user_id=current_user.id,
    )

    if notification_deleted is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification introuvable",
        )

    return {
        "message": "Notification supprimée avec succès",
        "notificationId": notification_id,
    }
