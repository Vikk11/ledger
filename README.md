
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

Expected response:

```json
{
  "status": "UP"
}
```

### Run tests

On Windows:

```powershell
.\mvnw.cmd test
```

On macOS/Linux:

```bash
./mvnw test
```

## PostgreSQL Database

The SQL exercises use PostgreSQL 16 through Docker Compose.

Start the database:

```bash
docker compose up -d
```

Connect to the Lab 2 database:

```bash
docker compose exec db psql -U ledger_user -d ledger_v2
```

Database credentials are stored locally in `.env` and should never be committed to GitHub.

See `.env.example` for the required environment variable names.

## Design Notes

The ledger follows the double-entry bookkeeping principle: each transfer produces a debit and a corresponding credit of equal value.

The database validates that transfers are balanced before a transaction commits. Historical financial records are protected against updates and deletes.

For financial calculations in Java, `BigDecimal` should be preferred over floating-point types such as `double`.

## License

This project was created for educational purposes.
