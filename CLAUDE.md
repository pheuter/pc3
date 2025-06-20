# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Phoenix Framework 1.8.0-rc.3 web application built with Elixir that implements a product management API using Ash Framework. The project features both a web interface and a JSON API with OpenAPI documentation support.

## Essential Commands

### Development

```bash
# Initial setup (installs deps and builds assets)
mix setup

# Start Phoenix server
mix phx.server

# Start with interactive shell
iex -S mix phx.server
```

### Testing

```bash
# Run all tests
mix test

# Run specific test file
mix test test/path/to/test_file.exs

# Run tests matching a pattern
mix test --only test_name_pattern

# Run with coverage
mix test --cover

# Run tests with detailed trace
mix test --trace
```

### Code Quality

```bash
# Format code
mix format

# Check formatting without changing files
mix format --check-formatted

# Compile with warnings as errors
mix compile --warnings-as-errors

# Run Credo for code quality checks (strict mode)
mix credo --strict

# Run Credo with suggestions
mix credo suggest
```

### API Documentation

```bash
# Generate OpenAPI specification
mix openapi.gen
```

### Assets

```bash
# Build assets for development
mix assets.build

# Build assets for production
mix assets.deploy
```

## Architecture Overview

The project uses Ash Framework for domain modeling with a CSV data layer instead of a traditional database:

### Core Structure

- **lib/pc3/** - Business logic and Ash resources

  - **api.ex** - Ash domain configuration with JSON API routes
  - **product.ex** - Product resource using CSV data layer
  - **application.ex** - OTP application supervisor

- **lib/pc3_web/** - Web layer
  - **router.ex** - Main routing configuration with API pipeline
  - **api_router.ex** - API-specific routing with JSON API and OpenAPI support
  - **controllers/** - HTTP request handlers
  - **components/** - LiveView components using `.heex` templates

### API Documentation

The application provides a JSON API with both standard CRUD operations and custom business actions. All endpoints follow JSON API specification.

API documentation is available at:

- `/api/swaggerui` - Interactive Swagger UI
- `/api/redoc` - Redoc documentation
- `/api/open_api` - Raw OpenAPI specification

### Key Technical Details

1. **Ash Framework**: The project uses Ash for domain modeling with:

   - CSV data layer (no traditional database)
   - JSON API specification compliance
   - Automatic OpenAPI spec generation

2. **Data Storage**: Uses CSV files for data persistence instead of a traditional database. The Ash.DataLayer.Csv adapter handles all CRUD operations.

3. **API Structure**:

   - Uses separate router module (`Pc3Web.ApiRouter`) for API routes
   - Implements JSON API specification
   - Includes OpenAPI documentation generation

4. **Frontend Stack**:

   - Phoenix LiveView for real-time features
   - Tailwind CSS v4 with @plugin syntax
   - DaisyUI for component styling
   - ESBuild for JavaScript bundling

5. **Development Routes**:
   - `/dev/dashboard` - Live Dashboard for monitoring
   - `/dev/mailbox` - Email preview (Swoosh)

## Development Workflow

When working with the API:

1. Data is stored in CSV files under `priv/data/`
2. API changes should be reflected in OpenAPI docs by running `mix openapi.gen`
3. Test API endpoints using the Swagger UI at `/api/swaggerui`

When making code changes:

1. Run `mix format` before committing
2. Run `mix credo --strict` to check code quality
3. Run `mix test` to ensure tests pass
4. For frontend changes, assets are automatically rebuilt in development

## Important Notes

- The project uses CSV files instead of a database, so no Ecto migrations are needed
- When modifying Ash resources, ensure the CSV data layer constraints are maintained
- API routes are defined in both the Ash domain (`lib/pc3/api.ex`) and the Phoenix router
- The project uses Phoenix 1.8 RC version with modern features like verified routes
