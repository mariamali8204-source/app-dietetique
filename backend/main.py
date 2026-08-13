from datetime import datetime

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel


app = FastAPI(
    title="NutriCare Pro API",
    version="1.0.0",
)


# ============================================================
# MODELE PYDANTIC
# ============================================================

class PatientCreate(BaseModel):
    userId: int
    nom: str
    email: str
    pays: str
    indicatif: str
    telephone: str
    objectifNutritionnel: str
    statut: str
    notificationsAutorisees: bool


# ============================================================
# DONNEES TEMPORAIRES
# Elles seront remplacées par la base de données plus tard.
# ============================================================

patients = [
    {
        "id": 1,
        "userId": 1,
        "nom": "Mariam Ali",
        "email": "mariam@example.com",
        "pays": "Liban",
        "indicatif": "+961",
        "telephone": "71111111",
        "objectifNutritionnel": "Perte de poids",
        "statut": "Actif",
        "notificationsAutorisees": True,
        "createdAt": "2026-07-28T10:00:00",
        "updatedAt": "2026-07-28T10:00:00",
    },
    {
        "id": 2,
        "userId": 1,
        "nom": "Sally Ahmad",
        "email": "sally@example.com",
        "pays": "Liban",
        "indicatif": "+961",
        "telephone": "72222222",
        "objectifNutritionnel": "Maintien du poids",
        "statut": "Suivi",
        "notificationsAutorisees": True,
        "createdAt": "2026-07-28T10:05:00",
        "updatedAt": "2026-07-28T10:05:00",
    },
    {
        "id": 3,
        "userId": 1,
        "nom": "Nour Hassan",
        "email": "nour@example.com",
        "pays": "Liban",
        "indicatif": "+961",
        "telephone": "73333333",
        "objectifNutritionnel": "Prise de poids",
        "statut": "Actif",
        "notificationsAutorisees": False,
        "createdAt": "2026-07-28T10:10:00",
        "updatedAt": "2026-07-28T10:10:00",
    },
]


next_patient_id = 4


# ============================================================
# GET /
# ============================================================

@app.get("/")
def root():
    return {
        "message": "NutriCare Pro API",
    }


# ============================================================
# GET /health
# ============================================================

@app.get("/health")
def health():
    return {
        "status": "ok",
        "message": "Backend FastAPI connecté",
    }


# ============================================================
# GET /patients
# ============================================================

@app.get("/patients")
def get_patients():
    return patients


# ============================================================
# GET /patients/{patient_id}
# ============================================================

@app.get("/patients/{patient_id}")
def get_patient(patient_id: int):
    for patient in patients:
        if patient["id"] == patient_id:
            return patient

    raise HTTPException(
        status_code=404,
        detail="Patient introuvable",
    )


# ============================================================
# POST /patients
# ============================================================

@app.post("/patients")
def create_patient(patient: PatientCreate):
    global next_patient_id

    now = datetime.now().isoformat()

    new_patient = patient.model_dump()

    new_patient["id"] = next_patient_id
    new_patient["createdAt"] = now
    new_patient["updatedAt"] = now

    patients.append(new_patient)

    next_patient_id += 1

    return new_patient


# ============================================================
# PUT /patients/{patient_id}
# ============================================================

@app.put("/patients/{patient_id}")
def update_patient(
    patient_id: int,
    patient: PatientCreate,
):
    for index, existing_patient in enumerate(patients):

        if existing_patient["id"] == patient_id:
            now = datetime.now().isoformat()

            updated_patient = patient.model_dump()

            updated_patient["id"] = patient_id

            updated_patient["createdAt"] = (
                existing_patient["createdAt"]
            )

            updated_patient["updatedAt"] = now

            patients[index] = updated_patient

            return updated_patient

    raise HTTPException(
        status_code=404,
        detail="Patient introuvable",
    )


# ============================================================
# DELETE /patients/{patient_id}
# ============================================================

@app.delete("/patients/{patient_id}")
def delete_patient(patient_id: int):
    for index, patient in enumerate(patients):

        if patient["id"] == patient_id:
            deleted_patient = patients.pop(index)

            return {
                "message": "Patient supprimé avec succès",
                "patient": deleted_patient,
            }

    raise HTTPException(
        status_code=404,
        detail="Patient introuvable",
    )