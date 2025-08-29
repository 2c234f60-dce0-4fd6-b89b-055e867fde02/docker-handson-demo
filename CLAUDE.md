# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a GitHub Copilot workshop demonstrating social media application development with JavaScript frontend and Java backend. The repository contains a complete implementation of a simple social media API with a React frontend and Spring Boot backend.

## Architecture

The application follows an API-first approach with separate frontend and backend:

- **Backend API**: Spring Boot RESTful services for posts, comments, and likes management
- **Frontend**: React application with Vite build tool consuming the API
- **Database**: SQLite with JPA/Hibernate
- **Containerization**: Docker support for both frontend and backend

### Directory Structure

- `complete/` - Complete working application
  - `backend/` - Spring Boot Java backend with Gradle
  - `frontend/` - React frontend application with Vite
- `docs/` - Step-by-step workshop instructions

## Development Commands

### Java Backend (Spring Boot)
```bash
cd complete/backend
./gradlew bootRun           # Run application (http://localhost:8080)
./gradlew build             # Build project
./gradlew test              # Run tests
./gradlew bootJar           # Create executable JAR
```

### JavaScript Frontend (React + Vite)
```bash
cd complete/frontend
npm install                 # Install dependencies
npm run dev                 # Development server (http://localhost:3000)
npm run build              # Production build
npm run preview            # Preview build
npm run lint               # ESLint
npx playwright test        # Run tests
```

### Docker Containerization
```bash
cd complete/backend
docker build -f Dockerfile.java -t socialapp-backend .

cd complete/frontend
docker build -t socialapp-frontend .
```

## API Specification

The backend implements a REST API:

- **Posts**: `/api/posts` (GET, POST, PATCH, DELETE)
- **Comments**: `/api/posts/{postId}/comments` (GET, POST, PATCH, DELETE)
- **Likes**: `/api/posts/{postId}/likes` (POST, DELETE)

The backend includes:
- OpenAPI/Swagger documentation at `/swagger-ui.html`
- CORS support for cross-origin requests
- Input validation and error handling
- Health check endpoints via Spring Boot Actuator

## Key Implementation Details

- **Backend**: Spring Boot 3.2.5 with Java 17, JPA/Hibernate, SQLite database, Gradle build system
- **Frontend**: React with Vite build tool, Tailwind CSS, Axios for API calls, Playwright for testing
- **Development**: Frontend proxy configured to route `/api/*` requests to backend on `http://localhost:8080`

## Workshop Context

This is an educational workshop for learning GitHub Copilot features. The implementation demonstrates consistent API design patterns and modern development practices with Java Spring Boot and React.