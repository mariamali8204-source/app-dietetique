import json
import os
from pathlib import Path
from urllib import error, request

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env", override=True)


class EmailConfigurationError(Exception):
    pass


class EmailSendError(Exception):
    pass


def _required(name: str) -> str:
    value = os.getenv(name)
    if value is None or not value.strip():
        raise EmailConfigurationError(f"Variable manquante : {name}")
    return value.strip()


def envoyer_email(
    *,
    destinataire: str,
    sujet: str,
    message: str,
) -> None:
    api_key = _required("RESEND_API_KEY")

    expediteur = os.getenv(
        "RESEND_FROM_EMAIL",
        "NutriCare Pro <onboarding@resend.dev>",
    ).strip()

    payload = {
        "from": expediteur,
        "to": [destinataire],
        "subject": sujet,
        "text": message,
    }

    req = request.Request(
        "https://api.resend.com/emails",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "User-Agent": "NutriCare-Pro/1.0",
        },
        method="POST",
    )

    try:
        with request.urlopen(req, timeout=20) as response:
            if response.status < 200 or response.status >= 300:
                raise EmailSendError(
                    f"Resend a retourné le statut HTTP {response.status}."
                )
    except error.HTTPError as exc:
        try:
            details = exc.read().decode("utf-8")
        except Exception:
            details = str(exc)

        raise EmailSendError(
            f"Erreur Resend HTTP {exc.code}: {details}"
        ) from exc
    except error.URLError as exc:
        raise EmailSendError(
            f"Impossible de contacter Resend : {exc.reason}"
        ) from exc
    except Exception as exc:
        if isinstance(exc, EmailSendError):
            raise

        raise EmailSendError(str(exc)) from exc
