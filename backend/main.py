from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

import crud
import models
from auth import get_current_user
from database import Base, engine, get_db
from models import UserModel
from schemas import (
    PatientCreate,
    PatientResponse,
    PatientUpdate,
    Token,
    UserCreate,
    UserResponse,
)
from security import create_access_token, verify_password


Base.metadata.create_all(bind=engine)


app = FastAPI(
    title="NutriCare Pro API",
    version="2.0.0",
)


DbSession = Annotated[
    Session,
    Depends(get_db),
]


CurrentUser = Annotated[
    UserModel,
    Depends(get_current_user),
]


# -------------------------
# General
# -------------------------

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


# -------------------------
# Authentication
# -------------------------

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
            detail="Un utilisateur avec cet e-mail existe déjà",
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
            detail="E-mail ou mot de passe incorrect",
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


# -------------------------
# Patients protégés par JWT
# -------------------------

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
        "message": "Patient supprimé avec succès",
        "patientId": patient_id,
    }