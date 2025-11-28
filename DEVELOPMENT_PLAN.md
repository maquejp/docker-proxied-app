# Development Plan: Docker Proxied App

This document outlines the implementation phases for the Docker Proxied App project.

## Phase 1: Project Setup & Infrastructure

### 1.1 Project Structure

- [x] Create main packages directory structure
- [x] Initialize backend folder with TypeScript structure (routes, controllers, services, interfaces, middlewares, configs, constants, utils)
- [x] Create database folders (packages, tables)
- [x] Create docker configuration folder
- [x] Create testing folders (e2e, api, fixtures, utils)
- [x] Add comprehensive README.md files for all directories documenting purpose and structure

### 1.2 Frontend Setup (eUI)

- [x] Navigate to packages/frontend directory
- [x] Ensure directory is empty (eUI CLI requires empty directory)
- [x] Run `npx @eui/cli` for interactive eUI Angular setup
- [x] Configure eUI project settings during CLI setup
- [x] Verify eUI project structure and dependencies

### 1.3 Backend Configuration

- [x] Create backend package.json with Express, TypeScript, Oracle dependencies
- [x] Setup TypeScript configuration (tsconfig.json)
- [x] Configure ESLint (.eslintrc.json) for TypeScript
- [x] Configure Prettier (.prettierrc) for code formatting
- [x] Create basic Express server structure

### 1.4 Testing Setup

- [x] Create testing package.json with Playwright dependencies
- [x] Setup Playwright configuration (playwright.config.ts)
- [x] Configure test structure for API and E2E testing

### 1.5 Docker Configuration

- [x] Create multi-stage Dockerfile for production builds
- [x] Setup nginx configuration for reverse proxy
- [x] Create startup script for container
- [x] Create environment variables template (.env.example)
- [x] Setup docker-compose for development (optional)

## Phase 2: Database Foundation

### 2.1 Database Schema Creation ✅

- [x] Create accounts table with all required fields (pk, givenname, lastname, unikid, email, created_on, modified_on, created_by, modified_by)
- [x] Create features table with required fields (pk, feature_code, feature_name, created_on, modified_on, created_by, modified_by)
- [x] Create accounts_features_rights table (pk, pk_account, pk_feature, right, created_on, created_by)
- [x] Create sessions table (pk, pk_account, token, session_start, session_end, session_duration)
- [x] Add primary key constraints and foreign key relationships
- [x] Create indexes for performance optimization

### 2.2 Oracle Package Development - p_accounts ✅

- [x] Create p_accounts package specification
- [x] Implement create_record function (expects all fields except pk and timestamp fields)
- [x] Implement update_record function (expects all fields including pk, except timestamp fields)
- [x] Implement delete_record function (expects pk parameter)
- [x] Implement get_record function (expects pk parameter)
- [x] Implement get_records function (with pagination, ordering, filtering parameters)
- [x] Add JSON helper function using Oracle json_object methods

### 2.3 Oracle Package Development - p_features ✅

- [x] Create p_features package specification
- [x] Implement create_record function
- [x] Implement update_record function
- [x] Implement delete_record function
- [x] Implement get_record function
- [x] Implement get_records function (with pagination, ordering, filtering)
- [x] Add JSON helper function

### 2.4 Oracle Package Development - p_accounts_features_rights ✅

- [x] Create p_accounts_features_rights package specification
- [x] Implement create_record function
- [x] Implement update_record function
- [x] Implement delete_record function
- [x] Implement get_record function
- [x] Implement get_records function (with pagination, ordering, filtering)
- [x] Add JSON helper function

### 2.5 Oracle Package Development - p_sessions ✅

- [x] Create p_sessions package specification
- [x] Implement standard CRUD functions (create_record, update_record, delete_record, get_record, get_records)
- [x] Implement validate_token function (checks token existence and validity)
- [x] Implement get_token function (returns token entry information)
- [x] Add JSON helper function
- [x] Add session cleanup procedures for expired sessions

### 2.6 Database Testing & Validation ✅

- [x] Test all package functions with sample data
- [x] Verify JSON output format from helper functions
- [x] Test pagination, ordering, and filtering in get_records functions
- [x] Validate foreign key constraints
- [x] Test session token validation and expiration logic
- [x] Create database seed data for development and testing

## Phase 3: Backend API Development

### 3.1 ExpressJS Foundation

- [ ] Create main Express application entry point (src/index.ts)
- [ ] Setup Express server with middleware (helmet, cors, express.json)
- [ ] Configure environment variables loading (dotenv)
- [ ] Setup basic error handling middleware
- [ ] Create application startup and shutdown procedures
- [ ] Configure logging (minimal as specified)

### 3.2 Database Integration

- [ ] Install and configure Oracle database driver (oracledb)
- [ ] Create database connection configuration (src/configs/database.ts)
- [ ] Implement connection pool management
- [ ] Create database connection service (src/services/database.ts)
- [ ] Test database connectivity and package calls
- [ ] Setup environment variables for Oracle connection (ORACLE_SERVER, ORACLE_PORT, etc.)

### 3.3 TypeScript Interfaces & Models

- [ ] Create Account interface (src/interfaces/Account.ts)
- [ ] Create Feature interface (src/interfaces/Feature.ts)
- [ ] Create AccountFeatureRight interface (src/interfaces/AccountFeatureRight.ts)
- [ ] Create Session interface (src/interfaces/Session.ts)
- [ ] Create API response interfaces (ApiResponse, PaginatedResponse)
- [ ] Create JWT payload interface
- [ ] Create request/response DTOs for each endpoint

### 3.4 Authentication & Security

- [ ] Create JWT configuration and utilities (src/utils/jwt.ts)
- [ ] Implement authentication middleware (src/middlewares/auth.ts)
- [ ] Create external authentication integration service
- [ ] Implement session validation middleware
- [ ] Setup JWT token generation and verification
- [ ] Configure JWT expiration (10 hours) and refresh logic
- [ ] Create authorization middleware for protected routes

### 3.5 Services Layer

- [ ] Create AccountService (src/services/AccountService.ts) - calls p_accounts package
- [ ] Create FeatureService (src/services/FeatureService.ts) - calls p_features package
- [ ] Create AccountFeatureRightService (src/services/AccountFeatureRightService.ts)
- [ ] Create SessionService (src/services/SessionService.ts) - includes token validation
- [ ] Create AuthService (src/services/AuthService.ts) - handles authentication flow
- [ ] Implement error handling and Oracle package response parsing
- [ ] Add pagination, filtering, and sorting logic

### 3.6 Controllers Layer

- [ ] Create AccountController (src/controllers/AccountController.ts)
- [ ] Create FeatureController (src/controllers/FeatureController.ts)
- [ ] Create AccountFeatureRightController (src/controllers/AccountFeatureRightController.ts)
- [ ] Create SessionController (src/controllers/SessionController.ts)
- [ ] Create AuthController (src/controllers/AuthController.ts)
- [ ] Implement request validation and response formatting
- [ ] Add proper HTTP status codes and error responses

### 3.7 Routes & API Endpoints

- [ ] Create authentication routes (src/routes/auth.ts) - /api/authenticate
- [ ] Create accounts routes (src/routes/accounts.ts) - CRUD operations
- [ ] Create features routes (src/routes/features.ts) - CRUD operations
- [ ] Create sessions routes (src/routes/sessions.ts) - session management
- [ ] Create account features rights routes - /api/accounts/{id}/features
- [ ] Setup route protection with authentication middleware
- [ ] Create health check endpoint
- [ ] Configure API route prefixes and versioning

### 3.8 Validation & Error Handling

- [ ] Implement request validation middleware using express-validator or joi
- [ ] Create email format validation
- [ ] Add field length validation based on database constraints
- [ ] Setup centralized error handling middleware
- [ ] Create custom error classes and error responses
- [ ] Add request logging and error logging
- [ ] Implement Oracle package error parsing and mapping

## Phase 4: Frontend Development

### 4.1 eUI Angular Project Setup

- [ ] Navigate to packages/frontend directory (should already be initialized from Phase 1)
- [ ] Verify eUI project structure and dependencies
- [ ] Configure Angular environment files for dev/prod API endpoints
- [ ] Setup Angular routing configuration
- [ ] Configure eUI theme and styling

### 4.2 Authentication Integration

- [ ] Create authentication service (src/app/services/auth.service.ts)
- [ ] Implement JWT token storage and management
- [ ] Create login/logout functionality
- [ ] Implement authentication guard for protected routes
- [ ] Create token refresh logic (10-hour sessions)
- [ ] Handle external authentication system integration
- [ ] Create authentication interceptor for API calls

### 4.3 Core Services

- [ ] Create API service base class with HTTP client configuration
- [ ] Create AccountService for account CRUD operations
- [ ] Create FeatureService for feature management
- [ ] Create SessionService for session management
- [ ] Implement error handling and API response parsing
- [ ] Add loading states and user feedback mechanisms

### 4.4 Component Development - Public Area

- [ ] Create public home page component
- [ ] Implement navigation component (header/menu)
- [ ] Create footer component
- [ ] Add responsive design using eUI components
- [ ] Implement basic layout structure

### 4.5 Component Development - Protected Area

- [ ] Create dashboard/main layout component
- [ ] Create account list component with pagination and filtering
- [ ] Create account detail/edit component with form validation
- [ ] Create feature management components
- [ ] Create user feature rights management interface
- [ ] Implement CRUD operations for all entities

### 4.6 Routing & Navigation

- [ ] Setup public routes (home page)
- [ ] Configure protected routes with authentication guards
- [ ] Implement route-based access control
- [ ] Create navigation menu with role-based visibility
- [ ] Add breadcrumb navigation
- [ ] Handle 404 and error pages

### 4.7 Forms & Validation

- [ ] Implement reactive forms for all CRUD operations
- [ ] Add client-side validation (email format, required fields)
- [ ] Create custom validators for business rules
- [ ] Implement form submission and error handling
- [ ] Add user feedback for successful operations
- [ ] Handle server-side validation errors

### 4.8 UI/UX & eUI Integration

- [ ] Implement consistent styling using eUI components
- [ ] Add loading spinners and progress indicators
- [ ] Create confirmation dialogs for destructive operations
- [ ] Implement toast notifications for user feedback
- [ ] Add responsive design for mobile/tablet
- [ ] Ensure accessibility compliance

## Phase 5: Integration & Containerization

### 5.1 Development Integration

- [ ] Test full application flow in development mode
- [ ] Verify frontend-backend API integration
- [ ] Test authentication flow end-to-end
- [ ] Validate all CRUD operations work correctly
- [ ] Test session management and token refresh

### 5.2 Production Build Process

- [ ] Configure Angular production build settings
- [ ] Setup TypeScript compilation for backend
- [ ] Test production builds locally
- [ ] Optimize bundle sizes and performance
- [ ] Verify environment variable substitution

### 5.3 Docker Configuration

- [ ] Create multi-stage Dockerfile for production
- [ ] Configure nginx for static file serving and API proxying
- [ ] Setup SSL/TLS configuration for HTTPS
- [ ] Create container startup script
- [ ] Configure environment variable handling in container

### 5.4 Container Testing

- [ ] Build Docker image and test locally
- [ ] Verify nginx routing works correctly (/ to frontend, /api to backend)
- [ ] Test HTTPS configuration
- [ ] Validate environment variable configuration
- [ ] Test container startup and health checks

### 5.5 Environment Configuration

- [ ] Create production environment variables template
- [ ] Setup different JWT secrets for dev/prod
- [ ] Configure different database connections for environments
- [ ] Test production configuration
- [ ] Document environment setup requirements

## Phase 6: Testing & Quality Assurance

### 6.1 Playwright Setup

- [ ] Initialize Playwright in packages/testing directory
- [ ] Configure test browsers and environments
- [ ] Setup test data and fixtures
- [ ] Configure test reporting and CI integration
- [ ] Create helper utilities for common test operations

### 6.2 API Integration Testing

- [ ] Write tests for authentication endpoints
- [ ] Test all account CRUD operations
- [ ] Test feature management endpoints
- [ ] Test session management and token validation
- [ ] Test error handling and validation responses
- [ ] Test pagination, filtering, and sorting

### 6.3 End-to-End Testing

- [ ] Create test scenarios for complete user workflows
- [ ] Test public home page accessibility
- [ ] Test login/logout flow
- [ ] Test account creation and management workflows
- [ ] Test feature assignment and management
- [ ] Test session timeout and refresh scenarios

### 6.4 Cross-Browser Testing

- [ ] Run tests on Chrome/Chromium
- [ ] Run tests on Firefox
- [ ] Run tests on Safari/WebKit
- [ ] Test responsive design on different screen sizes
- [ ] Validate eUI component compatibility

### 6.5 Performance & Security Testing

- [ ] Test application performance under load
- [ ] Validate JWT security implementation
- [ ] Test session management security
- [ ] Check for XSS and CSRF vulnerabilities
- [ ] Validate input sanitization and validation

## Phase 7: Deployment Preparation

### 7.1 Production Environment Setup

- [ ] Configure production Oracle database connection
- [ ] Setup production environment variables
- [ ] Configure production logging and monitoring
- [ ] Setup backup and recovery procedures
- [ ] Configure SSL certificates for production

### 7.2 Infrastructure Testing

- [ ] Deploy to staging/test environment
- [ ] Test full application on internal infrastructure
- [ ] Validate network connectivity and firewall rules
- [ ] Test load balancing and scaling requirements
- [ ] Verify backup and disaster recovery procedures

### 7.3 Security Validation

- [ ] Validate JWT token security in production
- [ ] Test session timeout and cleanup procedures
- [ ] Verify HTTPS enforcement and security headers
- [ ] Conduct security audit of exposed endpoints
- [ ] Test authentication and authorization controls

### 7.4 Documentation & Training

- [ ] Create deployment runbook and procedures
- [ ] Document environment setup and configuration
- [ ] Create user manual and training materials
- [ ] Document API endpoints and usage
- [ ] Create troubleshooting guide

### 7.5 Go-Live Preparation

- [ ] Schedule deployment window
- [ ] Prepare rollback procedures
- [ ] Setup monitoring and alerting
- [ ] Conduct final pre-deployment testing
- [ ] Execute deployment and validate functionality

## Progress Tracking

You can check off tasks as you complete them. Each phase should be completed before moving to the next one to ensure proper dependencies are met.
