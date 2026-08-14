from typing import Annotated

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

import crud
from database import get_db
from models import UserModel
from security import decode_access_token


oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="auth/login",
)


DbSession = Annotated[
    Session,
    Depends(get_db),
]


def get_current_user(
    token: Annotated[
        str,
        Depends(oauth2_scheme),
    ],
    db: DbSession,
) -> UserModel:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Impossible de valider les informations d'authentification",
        headers={
            "WWW-Authenticate": "Bearer",
        },
    )

    try:
        user_id = decode_access_token(token)
    except jwt.InvalidTokenError:
        raise credentials_exception

    user = crud.get_user(
        db,
        user_id,
    )

    if user is None:
        raise credentials_exception

    return user