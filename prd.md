# Product Requirements Document: Docker Proxied App

## 1. Introduction

This document outlines the product requirements for the Docker Proxied App.

The application will consist of a frontend and a backend service, both running in Docker containers. A proxy server will route requests to the appropriate service.

## 2. Target Audience

The target audience for this application is developers who want a starting point for a containerized web application with a frontend and backend.

## 3. Features

- **Frontend Service:** An Angular (eUI) application.
- **Backend Service:** An ExpressJS API.
- **Database:** An Oracle database, initially hosted locally.
- **Proxy:** A reverse proxy to route traffic to the frontend and backend services.
- **Containerization:** All services will be containerized using Docker.

## 4. Architecture

The application will be accessible via the following URLs:

- `https://localhost:8095/`: Serves the Angular frontend.
- `https://localhost:8095/api`: Routes to the ExpressJS backend API.

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

#### Database Packages

For each table, a corresponding Oracle package exists (`p_accounts`, `p_features`, `p_accounts_features_rights`) with the following functions:

- `create_record`: Expects all fields except for the primary key (`pk`) and timestamp fields (`created_on`, `modified_on`), which are set by default.
- `update_record`: Expects all fields, including the primary key (`pk`), but not the timestamp fields.
- `delete_record`: Expects the primary key (`pk`) of the record to delete.
- `get_record`: Expects the primary key (`pk`) of the record to retrieve.
- `get_records`: Expects parameters for pagination, ordering, and filtering, with default presets.

A helper function is available to return a single record as a JSON CLOB, using Oracle's `json_object` methods. The ExpressJS API will interact with the database exclusively through these packages, avoiding direct SQL calls.

### 4.2. Security

- **Authentication:** All routes for both the frontend (except the home page) and the API will be protected using JWT (JSON Web Token) authentication.
- **Authentication Endpoint:** A public endpoint at `/api/authenticate` will be used to obtain a JWT.

### 4.3. Build and Deployment

Upon a developer's request, a build process will be triggered to create a production-ready Docker image. This process involves:

1. Building the Angular frontend and the ExpressJS API.
2. Packaging the built frontend and API into a single Docker image that includes a web server.
3. This image can then be used to instantiate a container for deployment on the internal infrastructure.

## 5. Future Work

This section is intentionally left blank.
