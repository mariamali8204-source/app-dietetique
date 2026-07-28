from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def home():
    return {"message": "Backend FastAPI is running"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/patients")
def get_patients():
    return [
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