
# Ledger

A learning project exploring relational database design, double-entry bookkeeping, SQL transactions, and Java money handling using PostgreSQL and Spring Boot.

## Technologies

- Java 21
- Spring Boot
- Maven
- PostgreSQL 16
- Docker Compose
- JUnit 5
- BigDecimal

## Getting Started

### Requirements

- Java 21
- Docker Desktop
- Maven (optional, because the Maven wrapper is included)

### Run the Spring Boot application

On Windows:

```powershell
.\mvnw.cmd spring-boot:run
```

On macOS/Linux:

```bash
./mvnw spring-boot:run
```

The application runs at:

`http://localhost:8080`

### Check application health

Open:

`http://localhost:8080/actuator/health`

The health endpoint returns JSON containing "status": "UP". The response may also include additional component information, such as liveness and readiness groups.

### Run tests

On Windows:

```powershell
.\mvnw.cmd test
```

On macOS/Linux:

```bash
./mvnw test
```


## PostgreSQL Database Setup

The database schema is stored in the `db/` directory and uses PostgreSQL 16 through Docker Compose.

The Docker Compose configuration uses the `POSTGRES_DB` environment variable to initialize the database. The default database name is `ledger_v2`.

### 1. Configure environment variables

Copy the example environment file:

Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

macOS/Linux:

```bash
cp .env.example .env
```

Update `.env` with your local database credentials if necessary.

### 2. Start PostgreSQL

```bash
docker compose up -d
```

### 3. Load the database schema

For a fresh database, apply the migrations in order.

Windows PowerShell:

```powershell
Get-Content db\V1__ledger_schema.sql | docker compose exec -T db psql -U ledger_user -d ledger_v2

Get-Content db\V2__improve_ledger_integrity.sql | docker compose exec -T db psql -U ledger_user -d ledger_v2
```

macOS/Linux:

```bash
docker compose exec -T db psql -U ledger_user -d ledger_v2 < db/V1__ledger_schema.sql

docker compose exec -T db psql -U ledger_user -d ledger_v2 < db/V2__improve_ledger_integrity.sql
```

These migration files should be applied once, in order, to a fresh database.

### 4. Connect to PostgreSQL

```bash
docker compose exec db psql -U ledger_user -d ledger_v2
```

Database credentials are stored locally in `.env`. Never commit real credentials to GitHub.

## Application Scope

The Spring Boot application currently runs independently of the PostgreSQL database. The database schema and the Spring Boot application are separate parts of this educational project; database connectivity has not yet been implemented.

## Design Notes

The ledger follows the double-entry bookkeeping principle: each transfer produces a debit and a corresponding credit of equal value.

The database validates that transfers are balanced before a transaction commits. Historical financial records are protected against updates and deletes.

For financial calculations in Java, `BigDecimal` should be preferred over floating-point types such as `double`.

## License

This project was created for educational purposes.
