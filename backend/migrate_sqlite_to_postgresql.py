import sqlite3
from datetime import datetime
from pathlib import Path

from sqlalchemy import insert, select, text

from database import engine
from models import PatientModel, UserModel


BASE_DIR = Path(__file__).resolve().parent

SQLITE_PATH = (
    BASE_DIR
    / "nutricare_backup_before_postgresql.db"
)


def parse_datetime(value):
    if value is None:
        return None

    if isinstance(value, datetime):
        return value

    return datetime.fromisoformat(value)


def main():
    if not SQLITE_PATH.exists():
        raise FileNotFoundError(
            "Le fichier SQLite de sauvegarde "
            "est introuvable."
        )

    sqlite_connection = sqlite3.connect(
        SQLITE_PATH
    )

    sqlite_connection.row_factory = (
        sqlite3.Row
    )

    try:
        users = sqlite_connection.execute(
            """
            SELECT
                id,
                nom,
                email,
                hashed_password,
                role,
                created_at,
                updated_at
            FROM users
            ORDER BY id
            """
        ).fetchall()

        patients = sqlite_connection.execute(
            """
            SELECT
                id,
                user_id,
                nom,
                email,
                pays,
                indicatif,
                telephone,
                objectif_nutritionnel,
                statut,
                notifications_autorisees,
                created_at,
                updated_at
            FROM patients
            ORDER BY id
            """
        ).fetchall()

    finally:
        sqlite_connection.close()

    print(
        f"SQLite Users: {len(users)}"
    )
    print(
        f"SQLite Patients: {len(patients)}"
    )

    with engine.begin() as connection:
        postgres_users_count = (
            connection.execute(
                select(
                    text(
                        "COUNT(*)"
                    )
                ).select_from(
                    UserModel
                )
            ).scalar_one()
        )

        postgres_patients_count = (
            connection.execute(
                select(
                    text(
                        "COUNT(*)"
                    )
                ).select_from(
                    PatientModel
                )
            ).scalar_one()
        )

        if (
            postgres_users_count != 0
            or postgres_patients_count != 0
        ):
            raise RuntimeError(
                "Migration annulée : "
                "PostgreSQL contient déjà "
                "des données."
            )

        if users:
            connection.execute(
                insert(UserModel),
                [
                    {
                        "id": row["id"],
                        "nom": row["nom"],
                        "email": row["email"],
                        "hashed_password":
                            row[
                                "hashed_password"
                            ],
                        "role": row["role"],
                        "created_at":
                            parse_datetime(
                                row["created_at"]
                            ),
                        "updated_at":
                            parse_datetime(
                                row["updated_at"]
                            ),
                    }
                    for row in users
                ],
            )

        if patients:
            connection.execute(
                insert(PatientModel),
                [
                    {
                        "id": row["id"],
                        "user_id":
                            row["user_id"],
                        "nom": row["nom"],
                        "email": row["email"],
                        "pays": row["pays"],
                        "indicatif":
                            row["indicatif"],
                        "telephone":
                            row["telephone"],
                        "objectif_nutritionnel":
                            row[
                                "objectif_nutritionnel"
                            ],
                        "statut": row["statut"],
                        "notifications_autorisees":
                            bool(
                                row[
                                    "notifications_autorisees"
                                ]
                            ),
                        "created_at":
                            parse_datetime(
                                row["created_at"]
                            ),
                        "updated_at":
                            parse_datetime(
                                row["updated_at"]
                            ),
                    }
                    for row in patients
                ],
            )

        connection.execute(
            text(
                """
                SELECT setval(
                    pg_get_serial_sequence(
                        'users',
                        'id'
                    ),
                    (
                        SELECT MAX(id)
                        FROM users
                    ),
                    true
                )
                """
            )
        )

        connection.execute(
            text(
                """
                SELECT setval(
                    pg_get_serial_sequence(
                        'patients',
                        'id'
                    ),
                    (
                        SELECT MAX(id)
                        FROM patients
                    ),
                    true
                )
                """
            )
        )

    print(
        "Migration SQLite -> PostgreSQL réussie."
    )


if __name__ == "__main__":
    main()