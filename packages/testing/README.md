# Testing Package

This directory contains all testing infrastructure and test cases for the application.

## Structure

- `e2e/` - End-to-end tests using Playwright
- `api/` - API integration tests
- `database/` - Oracle database testing and validation
- `fixtures/` - Test data and mock responses
- `utils/` - Testing utilities and helpers

## Testing Strategy

### End-to-End Testing

- User workflow testing across the entire application
- Browser-based testing with Playwright
- Cross-browser compatibility testing

### API Integration Testing

- Backend API endpoint testing
- Authentication and authorization testing
- Database integration testing

### Database Testing

- Oracle PL/SQL package validation
- CRUD operation testing with JSON responses
- Session management and JWT token validation
- Foreign key constraints and data integrity
- Performance benchmarking and pagination testing

### Test Data Management

- Fixtures for consistent test data
- Mock responses for external services
- Database seeding for test environments
