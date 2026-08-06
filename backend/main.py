from datetime import datetime

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()


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


class PatientUpdate(BaseModel):
    userId: int
    nom: str
    email: str
    pays: str
    indicatif: str
    telephone: str
    objectifNutritionnel: str
    statut: str
    notificationsAutorisees: bool


patients = [
    {
        "id": 1,
        "userId": 1,
        "nom": "Mariam Ali",
        "email": "mariam.ali@email.com",
        "pays": "Liban",
        "indicatif": "+961",
        "telephone": "70123456",
        "objectifNutritionnel": "Perte de poids",
        "statut": "Actif",
        "notificationsAutorisees": True,
        "createdAt": "2026-07-24T10:00:00",
        "updatedAt": "2026-07-24T10:00:00",
    },
    {
        "id": 2,
        "userId": 1,
        "nom": "Sally Ahmad",
        "email": "sally.ahmad@email.com",
        "pays": "Liban",
        "indicatif": "+961",
        "telephone": "71123456",
        "objectifNutritionnel": "Nutrition équilibrée",
        "statut": "Suivi",
        "notificationsAutorisees": True,
        "createdAt": "2026-07-24T10:00:00",
        "updatedAt": "2026-07-24T10:00:00",
    },
    {
        "id": 3,
        "userId": 1,
        "nom": "Nour Hassan",
        "email": "nour.hassan@email.com",
        "pays": "Liban",
        "indicatif": "+961",
        "telephone": "76123456",
        "objectifNutritionnel": "Maintien du poids",
        "statut": "En pause",
        "notificationsAutorisees": False,
        "createdAt": "2026-07-24T10:00:00",
        "updatedAt": "2026-07-24T10:00:00",
    },
]

next_patient_id = 4


@app.get("/")
def home():
    return {"message": "Backend FastAPI is running"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/patients")
def get_patients():
    return patients


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


@app.put("/patients/{patient_id}")
def update_patient(patient_id: int, patient: PatientUpdate):
    for index, existing_patient in enumerate(patients):
        if existing_patient["id"] == patient_id:
            updated_patient = patient.model_dump()
            updated_patient["id"] = patient_id
            updated_patient["createdAt"] = existing_patient["createdAt"]
            updated_patient["updatedAt"] = datetime.now().isoformat()

            patients[index] = updated_patient

            return updated_patient

    raise HTTPException(status_code=404, detail="Patient not found")


@app.delete("/patients/{patient_id}")
def delete_patient(patient_id: int):
    for index, existing_patient in enumerate(patients):
        if existing_patient["id"] == patient_id:
            deleted_patient = patients.pop(index)

            return {
                "message": "Patient deleted successfully",
                "patient": deleted_patient,
            }

    raise HTTPException(status_code=404, detail="Patient not found")