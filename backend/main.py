from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, status
from sqlalchemy.orm import Session

import crud
import models
from database import Base, engine, get_db
from schemas import PatientCreate, PatientResponse, PatientUpdate


Base.metadata.create_all(bind=engine)


app = FastAPI(
    title="NutriCare Pro API",
    version="2.0.0",
)


DbSession = Annotated[
    Session,
    Depends(get_db),
]


# =========================================================
# ROOT
# =========================================================

@app.get("/")
def root():
    return {
        "message": "NutriCare Pro API",
    }


# =========================================================
# HEALTH
# =========================================================

@app.get("/health")
def health():
    return {
        "status": "ok",
        "message": "Backend FastAPI connecté",
    }


# =========================================================
# GET ALL PATIENTS
# =========================================================

@app.get(
    "/patients",
    response_model=list[PatientResponse],
)
def get_patients(
    db: DbSession,
):
    return crud.get_patients(
        db,
    )


# =========================================================
# GET ONE PATIENT
# =========================================================

@app.get(
    "/patients/{patient_id}",
    response_model=PatientResponse,
)
def get_patient(
    patient_id: int,
    db: DbSession,
):
    patient = crud.get_patient(
        db,
        patient_id,
    )

    if patient is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient introuvable",
        )

    return patient


# =========================================================
# CREATE PATIENT
# =========================================================

@app.post(
    "/patients",
    response_model=PatientResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_patient(
    patient: PatientCreate,
    db: DbSession,
):
    return crud.create_patient(
        db,
        patient,
    )


# =========================================================
# UPDATE PATIENT
# =========================================================

@app.put(
    "/patients/{patient_id}",
    response_model=PatientResponse,
)
def update_patient(
    patient_id: int,
    patient: PatientUpdate,
    db: DbSession,
):
    patient_updated = crud.update_patient(
        db,
        patient_id,
        patient,
    )

    if patient_updated is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient introuvable",
        )

    return patient_updated


# =========================================================
# DELETE PATIENT
# =========================================================

@app.delete(
    "/patients/{patient_id}",
)
def delete_patient(
    patient_id: int,
    db: DbSession,
):
    patient_deleted = crud.delete_patient(
        db,
        patient_id,
    )

    if patient_deleted is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient introuvable",
        )

    return {
        "message": "Patient supprimé avec succès",
        "patientId": patient_id,
    }