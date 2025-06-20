# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Phoenix Framework 1.8.0-rc.3 web application built with Elixir. The project uses modern tooling including Tailwind CSS v4, LiveView for real-time features, and DaisyUI for component styling.

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

# Run with coverage
mix test --cover
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

# Check specific files
mix credo lib/pc3_web/router.ex

# Generate Credo config (already done)
mix credo gen.config
```

### Assets
```bash
# Build assets for development
mix assets.build

# Build assets for production
mix assets.deploy
```

## Architecture Overview

The project follows standard Phoenix conventions with clear separation of concerns:

- **lib/pc3/** - Business logic and domain models
- **lib/pc3_web/** - Web layer (controllers, views, components)
  - **components/** - Reusable LiveView components
  - **controllers/** - HTTP request handlers
  - **router.ex** - All route definitions
- **assets/** - Frontend assets
  - Uses Tailwind CSS v4 with @plugin syntax
  - DaisyUI for themed components (light/dark themes)
  - LiveView for real-time interactivity

## Key Technical Details

1. **LiveView Integration**: The app uses Phoenix LiveView for real-time features. Components in `lib/pc3_web/components/` use the `.heex` extension and support live updates.

2. **Tailwind v4**: The project uses the new Tailwind v4 syntax. CSS configuration is in `assets/css/app.css` using `@plugin` directives instead of the old config file approach.

3. **Development Routes**: 
   - `/dev/dashboard` - Live Dashboard for monitoring
   - `/dev/mailbox` - Email preview (Swoosh)

4. **No Database Yet**: The project doesn't have Ecto/database configured. When adding database functionality, use `mix ecto.*` commands.

5. **Testing Structure**: Tests mirror the source structure. Controller tests go in `test/pc3_web/controllers/`, etc.

## Development Workflow

When making changes:
1. Always run `mix format` before committing
2. Run `mix credo --strict` to check code quality and maintain consistency
3. Run `mix test` to ensure tests pass
4. For frontend changes, assets are automatically rebuilt in development
5. Use `mix phx.server` for development with hot reloading enabled