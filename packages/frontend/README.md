# Frontend Package

This directory will contain the Angular (eUI) application for the Docker Proxied App.

## Setup Instructions

The frontend will be initialized using the eUI CLI:

```bash
cd packages/frontend
npx @eui/cli
```

## About eUI

**eUI (European Union Interface)** is a comprehensive design system and Angular component library that follows EU design standards.

- **Documentation**: [eUI Showcase](https://eui.ecdevops.eu/eui-showcase-ux-components-19.x)
- **Development Guide**: [eUI App Generation Guide](https://eui.ecdevops.eu/eui-showcase-ux-components-19.x/showcase-dev-guide/docs/01b-app-generation/00-overview)
- **Interactive Setup**: The CLI provides guided project initialization

## Technology Stack

- Angular with TypeScript
- eUI component library
- Reactive forms for data management
- Angular routing with authentication guards
- JWT token management

## Development Structure

Once initialized, the frontend will include:

- `src/app/` - Angular application components and services
- `src/app/services/` - Authentication, API, and business logic services
- `src/app/components/` - UI components organized by feature
- `src/app/guards/` - Route protection and authentication guards
- `src/environments/` - Environment-specific configurations
