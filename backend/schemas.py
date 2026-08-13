from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class PatientBase(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
        from_attributes=True,
    )

    user_id: int = Field(
        alias="userId",
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

    created_at: datetime = Field(
        alias="createdAt",
    )

    updated_at: datetime = Field(
        alias="updatedAt",
    )