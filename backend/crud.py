from sqlalchemy import select
from sqlalchemy.orm import Session

from models import PatientModel
from schemas import PatientCreate, PatientUpdate


def get_patients(
    db: Session,
) -> list[PatientModel]:
    statement = select(PatientModel).order_by(
        PatientModel.id,
    )

    return list(
        db.scalars(statement).all()
    )


def get_patient(
    db: Session,
    patient_id: int,
) -> PatientModel | None:
    return db.get(
        PatientModel,
        patient_id,
    )


def create_patient(
    db: Session,
    patient: PatientCreate,
) -> PatientModel:
    patient_data = patient.model_dump(
        by_alias=False,
    )

    db_patient = PatientModel(
        **patient_data,
    )

    db.add(
        db_patient,
    )

    db.commit()

    db.refresh(
        db_patient,
    )

    return db_patient


def update_patient(
    db: Session,
    patient_id: int,
    patient: PatientUpdate,
) -> PatientModel | None:
    db_patient = get_patient(
        db,
        patient_id,
    )

    if db_patient is None:
        return None

    patient_data = patient.model_dump(
        by_alias=False,
    )

    for field, value in patient_data.items():
        setattr(
            db_patient,
            field,
            value,
        )

    db.commit()

    db.refresh(
        db_patient,
    )

    return db_patient


def delete_patient(
    db: Session,
    patient_id: int,
) -> PatientModel | None:
    db_patient = get_patient(
        db,
        patient_id,
    )

    if db_patient is None:
        return None

    db.delete(
        db_patient,
    )

    db.commit()

    return db_patient