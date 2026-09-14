import os
import re
from pathlib import Path

from dotenv import load_dotenv
from twilio.rest import Client


BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")


class WhatsAppConfigurationError(Exception):
    pass


class WhatsAppSendError(Exception):
    pass


def _env_required(name: str) -> str:
    value = os.getenv(name)

    if value is None or not value.strip():
        raise WhatsAppConfigurationError(
            f"Variable manquante : {name}"
        )

    return value.strip()


def _normaliser_numero(
    indicatif: str,
    telephone: str,
) -> str:
    indicatif_clean = re.sub(r"\D", "", indicatif)
    telephone_clean = re.sub(r"\D", "", telephone)

    telephone_clean = telephone_clean.lstrip("0")

    if not indicatif_clean or not telephone_clean:
        raise WhatsAppSendError(
            "Numéro de téléphone invalide."
        )

    return f"+{indicatif_clean}{telephone_clean}"


def envoyer_message_whatsapp(
    *,
    indicatif: str,
    telephone: str,
    message: str,
) -> str:
    account_sid = _env_required(
        "TWILIO_ACCOUNT_SID"
    )
    auth_token = _env_required(
        "TWILIO_AUTH_TOKEN"
    )
    whatsapp_from = _env_required(
        "TWILIO_WHATSAPP_FROM"
    )

    destination = _normaliser_numero(
        indicatif,
        telephone,
    )

    client = Client(
        account_sid,
        auth_token,
    )

    try:
        resultat = client.messages.create(
            from_=f"whatsapp:{whatsapp_from}",
            to=f"whatsapp:{destination}",
            body=message,
        )
    except Exception as error:
        raise WhatsAppSendError(
            str(error)
        ) from error

    return resultat.sid