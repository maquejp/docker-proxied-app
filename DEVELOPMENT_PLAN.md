# Development Plan: Docker Proxied App

This document outlines the implementation phases for the Docker Proxied App project.

## Phase 1: Project Setup & Infrastructure

- [ ] Initialize project structure with folders (frontend, backend, database, docker, testing)
- [ ] Setup TypeScript configurations for both frontend and backend
- [ ] Configure ESLint, Prettier, and commit conventions
- [ ] Setup basic Docker configuration (Dockerfile, nginx.conf)
- [ ] Initialize package.json files for all TypeScript projects

## Phase 2: Database Foundation

- [ ] Create Oracle database tables (accounts, features, accounts_features_rights, sessions)
- [ ] Develop Oracle packages (p_accounts, p_features, p_accounts_features_rights, p_sessions)
- [ ] Implement specialized functions (validate_token, get_token)
- [ ] Test database packages and helper functions

## Phase 3: Backend API Development

- [ ] Setup ExpressJS with TypeScript structure (routes, controllers, services, etc.)
- [ ] Implement Oracle database connection and configuration
- [ ] Create TypeScript interfaces for all data models
- [ ] Develop authentication middleware and JWT handling
- [ ] Implement API endpoints (accounts, features, sessions, authenticate)
- [ ] Add data validation and error handling
- [ ] Setup health check endpoints

## Phase 4: Frontend Development

- [ ] Initialize Angular (eUI) project with TypeScript
- [ ] Setup basic routing and navigation structure
- [ ] Implement authentication service and JWT management
- [ ] Create components for account and feature management
- [ ] Develop public home page and protected routes
- [ ] Integrate with backend API endpoints

## Phase 5: Integration & Containerization

- [ ] Configure nginx for frontend serving and API proxying
- [ ] Complete Docker image build process
- [ ] Setup environment variable configurations (dev/prod)
- [ ] Test full application flow in container
- [ ] Verify CORS and session management

## Phase 6: Testing & Quality Assurance

- [ ] Setup Playwright testing framework
- [ ] Write API integration tests
- [ ] Develop end-to-end user workflow tests
- [ ] Create test fixtures and utilities
- [ ] Run cross-browser testing

## Phase 7: Deployment Preparation

- [ ] Finalize production environment configuration
- [ ] Test deployment on internal infrastructure
- [ ] Validate security measures and session timeouts
- [ ] Document deployment procedures

## Progress Tracking

You can check off tasks as you complete them. Each phase should be completed before moving to the next one to ensure proper dependencies are met.
