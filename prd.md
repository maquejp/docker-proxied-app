# Product Requirements Document: Docker Proxied App

## 1. Introduction

This document outlines the product requirements for the Docker Proxied App.

The application will consist of a frontend and a backend service, both running in Docker containers. A proxy server will route requests to the appropriate service.

## 2. Target Audience

The target audience for this application is internal users who need access to account and feature management functionality through a secure web interface.

## 3. Features

- **Frontend Service:** An Angular (eUI) application built with TypeScript, initialized using the eUI CLI (European Union Interface) - a comprehensive design system and Angular component library. See: [eUI Showcase](https://eui.ecdevops.eu/eui-showcase-ux-components-19.x)
- **Backend Service:** An ExpressJS API built with TypeScript.
- **Database:** An Oracle database, initially hosted locally.
- **Proxy:** An nginx reverse proxy to route traffic to the frontend and backend services.
- **Containerization:** All services will be containerized using Docker.

## 4. Architecture

The application will be accessible via the following URLs:

- `https://localhost:8095/`: Serves the Angular frontend.
- `https://localhost:8095/api`: Routes to the ExpressJS backend API.

### API Endpoints Structure

The API will follow RESTful conventions with the following endpoint patterns:

- `/api/authenticate`: Authentication endpoint (public)
- `/api/accounts`: CRUD operations for accounts
- `/api/features`: CRUD operations for features
- `/api/accounts/{id}/features`: User's feature rights management
- `/api/sessions`: Session management operations

### 4.1. Database Schema

The application will use an Oracle database with the following tables:

- **accounts**:
  - `pk` (Primary Key)
  - `givenname`
  - `lastname`
  - `unikid`
  - `email`
  - `created_on`
  - `modified_on`
  - `created_by`
  - `modified_by`
- **features**:
  - `pk` (Primary Key)
  - `feature_code`
  - `feature_name`
  - `created_on`
  - `modified_on`
  - `created_by`
  - `modified_by`
- **accounts_features_rights**:
  - `pk` (Primary Key)
  - `pk_account` (Foreign Key to `accounts`)
  - `pk_feature` (Foreign Key to `features`)
  - `right` (char 'F' for full or 'R' for read-only)
  - `created_on`
  - `created_by`
- **sessions**:
  - `pk` (Primary Key)
  - `pk_account` (Foreign Key to `accounts`)
  - `token`
  - `session_start`
  - `session_end`
  - `session_duration`

#### Database Packages

For each table, a corresponding Oracle package exists (`p_accounts`, `p_features`, `p_accounts_features_rights`, `p_sessions`) with the following functions:

- `create_record`: Expects all fields except for the primary key (`pk`) and timestamp fields (`created_on`, `modified_on`), which are set by default.
- `update_record`: Expects all fields, including the primary key (`pk`), but not the timestamp fields.
- `delete_record`: Expects the primary key (`pk`) of the record to delete.
- `get_record`: Expects the primary key (`pk`) of the record to retrieve.
- `get_records`: Expects parameters for pagination, ordering, and filtering, with default presets.

A helper function is available to return a single record as a JSON CLOB, using Oracle's `json_object` methods. The ExpressJS API will interact with the database exclusively through these packages, avoiding direct SQL calls.

The `p_sessions` package has additional specialized functions:

- `validate_token`: Checks if the provided token exists and is still valid.
- `get_token`: Returns the token entry information.

#### Database Configuration

The ExpressJS API will connect to Oracle using environment variables:

- `ORACLE_SERVER`: Database server hostname/IP
- `ORACLE_PORT`: Database port
- `ORACLE_USERNAME`: Database username
- `ORACLE_PASSWORD`: Database password

The API will use the Oracle database package for connections.

#### Data Validation

- **Email Format**: Standard email validation for account email fields
- **Field Lengths**: Validation based on database column constraints
- **Required Fields**: Standard validation for mandatory fields

#### Error Handling

All Oracle packages return JSON responses indicating success or failure. The API will pass these responses directly to the client with appropriate HTTP status codes.

### 4.2. Security

- **Authentication:** All routes for both the frontend (except the home page) and the API will be protected using JWT (JSON Web Token) authentication.
- **Authentication Flow:** Authentication is handled by an external authentication system that redirects back to the API, which then validates the user against the `accounts` table.
- **Session Management:** Active sessions are tracked in the `sessions` table, storing JWT tokens along with session timing information. Sessions are valid for 10 hours with automatic refresh and database-level session control.
- **Authentication Endpoint:** A public endpoint at `/api/authenticate` will be used to obtain a JWT.
- **Logging:** Minimal logging will be implemented for basic application monitoring.
- **Frontend Routing:** Angular will use basic routing strategy with nginx handling SPA fallback.
- **Environment Configuration:** Different JWT secrets and database configurations for development vs production environments (via .env files).
- **Health Checks:** API health endpoints and database connectivity checks will be implemented.

### 4.3. Build and Deployment

Upon a developer's request, a build process will be triggered to create a production-ready Docker image. This process involves:

1. Building the Angular eUI frontend (using `ng build --prod`) and compiling the ExpressJS API (using `tsc`).
2. Packaging only the production-built artifacts (dist folders) into a single Docker image with nginx as the web server.
3. This image can then be used to instantiate a container for deployment on the internal infrastructure.

**Note**: The Docker image contains only the compiled/built artifacts, not the development source code, ensuring a lean production deployment.

#### Container Architecture

The application will use a single Docker container approach:

- **nginx**: Serves Angular static files and proxies API requests (handles CORS automatically)
- **ExpressJS API**: Runs as a background service within the same container
- **Single image**: Simplified deployment and maintenance

#### Testing Strategy

The application will use Playwright for comprehensive testing:

- **End-to-End Testing**: Full user workflow testing through the frontend
- **API Integration Testing**: Direct API endpoint testing
- **Cross-browser Testing**: Ensuring compatibility across different browsers
- **Test Data Management**: Fixtures and utilities for consistent test data

#### Frontend Technology - eUI Framework

The frontend will use the **eUI (European Union Interface)** framework:

- **eUI CLI**: Official command-line tool for generating eUI Angular applications
- **Design System**: Comprehensive UI component library following EU design standards
- **Documentation**: [eUI Showcase](https://eui.ecdevops.eu/eui-showcase-ux-components-19.x)
- **App Generation Guide**: [eUI Development Guide](https://eui.ecdevops.eu/eui-showcase-ux-components-19.x/showcase-dev-guide/docs/01b-app-generation/00-overview)
- **Initialization Command**: `npx @eui/cli` (interactive setup)

#### Code Quality

- **ESLint/TSLint**: TypeScript linting for both frontend and backend
- **Prettier**: Consistent code formatting across the project
- **Commit Convention**: Enforced conventional commit format (e.g., feat:, fix:, docs:, etc.)

### 4.4. Development Structure

The project will follow this folder structure:

```text
docker-proxied-app/
├── packages/
│   ├── frontend/          # Angular (eUI) application (TypeScript)
│   │   │                  # Initialized using: npx @eui/cli
│   │   │                  # eUI: European Union Interface framework
│   │   ├── src/
│   │   ├── angular.json
│   │   ├── tsconfig.json
│   │   ├── .eslintrc.json
│   │   ├── .prettierrc
│   │   ├── package.json
│   │   └── ...
│   ├── backend/           # ExpressJS API (TypeScript)
│   │   ├── src/
│   │   │   ├── routes/        # API route definitions
│   │   │   ├── controllers/   # Request handlers
│   │   │   ├── services/      # Business logic
│   │   │   ├── interfaces/    # TypeScript interfaces
│   │   │   ├── middlewares/   # Custom middleware
│   │   │   ├── configs/       # Configuration files
│   │   │   ├── constants/     # Application constants
│   │   │   └── utils/         # Helper functions
│   │   ├── tsconfig.json
│   │   ├── .eslintrc.json
│   │   ├── .prettierrc
│   │   ├── package.json
│   │   └── ...
│   ├── database/          # Database scripts and Oracle packages
│   │   ├── packages/      # Oracle PL/SQL packages
│   │   ├── tables/        # Table creation scripts
│   │   └── ...
│   ├── docker/            # Docker configuration
│   │   ├── Dockerfile
│   │   ├── nginx.conf
│   │   ├── docker-compose.yml
│   │   └── .env.example
│   └── testing/           # Testing suite (Playwright)
│       ├── e2e/           # End-to-end tests
│       ├── api/           # API integration tests
│       ├── fixtures/      # Test data and fixtures
│       ├── utils/         # Testing utilities
│       ├── playwright.config.ts
│       ├── package.json
│       └── ...
├── prd.md                 # This document
├── DEVELOPMENT_PLAN.md    # Implementation phases and tasks
├── README.md
└── ...
```

## 5. Future Work

This section is intentionally left blank.
