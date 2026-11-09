# St10480926_Sombonga-Mjongile_POE-Part-3_RaceDay.API

# RaceDay

Event management platform for running, walking and cycling events, with **Organiser** and **Participant** roles.

| Project | What it is |
|---|---|
| `RaceDay.Api` | Part 2: ASP.NET Core REST API (EF Core + SQL Server, JWT auth, Azure Blob Storage) |
| `RaceDay.Web` | Part 3: ASP.NET Core MVC front end. It only talks to the API (no database access, no Azure access) |

> **YouTube demo video:** _paste your unlisted link here_

## Architecture

```
Browser ──> RaceDay.Web (MVC, session auth) ──HTTP + JWT──> RaceDay.Api ──> SQL Server
                                                                 └────────> Azure Blob Storage (banners, profile pictures)
```

* Login/registration call the API; the returned JWT, role and name are held in **server-side session** and attached to every API call by `ApiClient`.
* `[RoleAuthorize]` blocks anonymous users and wrong-role users from protected pages; each role gets its own navigation.
* Image uploads are posted by the MVC app to the API, which stores them in Azure Blob Storage and returns the public URL.

## Run locally

### 1. Prerequisites
.NET 8 SDK, SQL Server / LocalDB, and either an Azure Storage account or [Azurite](https://learn.microsoft.com/azure/storage/common/storage-use-azurite) (`docker run -p 10000:10000 mcr.microsoft.com/azure-storage/azurite azurite-blob --blobHost 0.0.0.0`).

### 2. Configure the API (`RaceDay.Api/appsettings.json`)
* `ConnectionStrings:RaceDayDb` : your SQL Server connection string (tables are created on first run)
* `Jwt:Key` : a random secret of 32+ characters
* `AzureBlob:ConnectionString` : your Azure Storage connection string (or `UseDevelopmentStorage=true` for Azurite)

### 3. Start the API
```bash
cd RaceDay.Api
dotnet run --urls http://localhost:5100
```
Swagger UI: http://localhost:5100/swagger

### 4. Start the MVC app
```bash
cd RaceDay.Web
dotnet run --urls http://localhost:5200
```
Open http://localhost:5200 (the API address is `Api:BaseUrl` in `RaceDay.Web/appsettings.json`).

## Run with Docker (MVC app)

With the API running on your machine at port 5100, run from the repository root:

```bash
docker build -t raceday-web . && docker run --rm -p 8080:8080 --add-host=host.docker.internal:host-gateway -e Api__BaseUrl=http://host.docker.internal:5100/ raceday-web
```

Then open http://localhost:8080. The container behaves the same as running locally; only the API address changes.

## Features

**Organiser:** dashboard (events, enrolments per event, upcoming dates) · create/edit/delete events with banner upload · categories per event · view and confirm/cancel enrolments · enter and publish results.

**Participant:** browse and filter upcoming events · event details and categories · enrol in a category · my enrolments (Confirmed = green, Pending = amber) · my results (e.g. "47th of 312 finishers") · profile with picture upload.

## API overview

| Method & route | Role |
|---|---|
| `POST /api/auth/register`, `/api/auth/login` | public |
| `GET /api/events`, `/api/events/{id}` | public |
| `GET/POST /api/events`, `PUT/DELETE /api/events/{id}`, `POST /api/events/{id}/banner`, `GET /api/events/mine` | Organiser |
| `POST /api/events/{id}/categories`, `DELETE /api/categories/{id}` | Organiser |
| `GET /api/events/{id}/enrolments`, `PUT /api/enrolments/{id}/status` | Organiser |
| `GET/POST /api/events/{id}/results`, `GET /api/organiser/dashboard` | Organiser |
| `POST /api/enrolments`, `GET /api/enrolments/mine`, `PUT /api/enrolments/{id}/cancel`, `GET /api/results/mine` | Participant |
| `GET/PUT /api/profile`, `POST /api/profile/picture` | any logged-in user |

## CI/CD
`.github/workflows/ci.yml` builds the API, the MVC project and the Docker image on every push.
