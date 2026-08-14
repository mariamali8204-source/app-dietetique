from sqlalchemy import select
from sqlalchemy.orm import Session

from models import PatientModel, UserModel
from schemas import PatientCreate, PatientUpdate, UserCreate
from security import get_password_hash


# -------------------------
# Patients
# -------------------------

def get_patients(
    db: Session,
    user_id: int,
) -> list[PatientModel]:
    statement = (
        select(PatientModel)
        .where(PatientModel.user_id == user_id)
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
    statement = select(PatientModel).where(
        PatientModel.id == patient_id,
        PatientModel.user_id == user_id,
    )

    return db.scalars(statement).first()


def create_patient(
    db: Session,
    patient: PatientCreate,
    user_id: int,
) -> PatientModel:
    patient_data = patient.model_dump(
        by_alias=False,
    )

    # Le propriétaire du patient est toujours
    # l'utilisateur authentifié.
    patient_data["user_id"] = user_id

    db_patient = PatientModel(
        **patient_data,
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

    # L'utilisateur ne peut pas changer
    # le propriétaire du patient.
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


# -------------------------
# Users
# -------------------------

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
    statement = select(UserModel).where(
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