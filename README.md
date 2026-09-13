\# NutriCare Pro



NutriCare Pro est une application de gestion destinée aux diététiciens.  

Elle permet de centraliser la gestion des patients, des plans nutritionnels, des rendez-vous et des rappels automatiques.



Le projet repose sur une architecture complète avec une application mobile Flutter, une API REST FastAPI et une base de données PostgreSQL.



\---



\## Fonctionnalités principales



\- Authentification sécurisée avec JWT

\- Création de compte et connexion

\- Gestion des sessions utilisateur

\- Isolation des données entre les diététiciens

\- Gestion complète des patients

\- Recherche rapide des patients

\- Gestion des plans nutritionnels

\- Programme nutritionnel sur 14 jours

\- Gestion détaillée des repas quotidiens

\- Gestion des rendez-vous

\- Détection des conflits horaires

\- Vue journalière et sélection de semaine

\- Centre de notifications

\- Suivi des notifications lues et non lues

\- Rappels automatiques des rendez-vous par e-mail

\- Suivi du statut d'envoi des rappels

\- Tableau de bord avec indicateurs principaux



\---



\## Technologies utilisées



\### Frontend



\- Flutter

\- Dart

\- Provider

\- Architecture MVVM

\- HTTP REST API

\- Stockage sécurisé de la session



\### Backend



\- Python

\- FastAPI

\- SQLAlchemy

\- Pydantic

\- JWT

\- APScheduler

\- Resend API



\### Base de données



\- PostgreSQL



\### Outils



\- Git

\- GitHub

\- Swagger / OpenAPI

\- Android Emulator

\- Visual Studio Code



\---



\## Architecture



L'application suit une architecture séparant clairement l'interface, la logique métier et l'accès aux données.



```text

Flutter View

&#x20;   ↓

ViewModel

&#x20;   ↓

Repository

&#x20;   ↓

Remote Data Source

&#x20;   ↓

FastAPI

&#x20;   ↓

SQLAlchemy

&#x20;   ↓

PostgreSQL

