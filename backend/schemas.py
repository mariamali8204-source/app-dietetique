from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


# -------------------------
# Patients
# -------------------------

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


# -------------------------
# Users
# -------------------------

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


# -------------------------
# Authentication
# -------------------------

class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    user_id: int | None = None