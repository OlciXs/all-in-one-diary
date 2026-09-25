# All In One Diary

Aplikacja typu pamiętnik/dziennik, pozwalająca użytkownikom na śledzenie wspomnień, kategoryzowanie wpisów, przeglądanie ich w interaktywnym kalendarzu oraz dołączanie zdjęć. Projekt składa się z backendu REST API w NestJS oraz aplikacji mobilnej w Flutterze.

# Technologie

Frontend (Aplikacja mobilna)

- Framework: Flutter (Dart)

- Zarządzanie stanem: Provider

- Kalendarz: table_calendar

- Klient HTTP: http / dio

Backend (API)

- Framework: NestJS (Node.js / TypeScript)

- Bazy danych: Prisma

- Baza danych: PostgreSQL

- Uwierzytelnianie: JWT (JSON Web Tokens)

# Funkcjonalności

- Autoryzacja użytkowników: Bezpieczna rejestracja i logowanie przy użyciu tokenów JWT oraz szyfrowania haseł.

- Interaktywny kalendarz: Wizualna reprezentacja wpisów z dostosowanymi kropkami kategorii, podglądem zdjęć i nawigacją po miesiącach/dniach.

- System kategorii: Możliwość tworzenia kategorii z własnymi kolorami i obsługą załączników graficznych.

- Zarządzanie wpisami: Pełny CRUD (tworzenie, odczyt, edycja, usuwanie) wpisów z zakresem dat, przypisaną kategorią i zdjęciami.

- Załączniki multimedialne: Przesyłanie i wyświetlanie miniaturek oraz zdjęć w pełnej rozdzielczości do wpisów.


# Uruchomienie

Przed uruchomieniem backendu stwórz plik .env w katalogu backend/ na podstawie poniższego wzoru:

- Adres połączenia z bazą danych (PostgreSQL lub SQLite)
DATABASE_URL="postgresql://user:password@localhost:5432/all-in-one-diary"

- Tajny klucz JWT do podpisywania tokenów
JWT_SECRET="super-secret-jwt-key-change-in-production"

1. Konfiguracja backendu (NestJS)

- Przejdź do folderu backendu:

cd backend

- Uruchom serwer deweloperski:

npm run start:dev

Serwer API rozpocznie działanie pod adresem http://localhost:3000.

2. Konfiguracja aplikacji mobilnej (Flutter)

- Przejdź do folderu aplikacji mobilnej:

cd ../mobile

- Pobierz pakiety Fluttera:

flutter pub get

- Uruchom aplikację:

flutter run
