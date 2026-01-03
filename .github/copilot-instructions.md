# Copilot Instructions for Post-It Notes Board API

## Architecture Overview

This is a **Rails 5.1 JSON API** (API-only mode) serving a React frontend. The API has a single core resource: `Note` with positioning coordinates for a drag-and-drop board UI.

**Key structural decision**: Versioned API namespace (`/api/v1/`) allows future breaking changes without affecting clients. CORS is configured for development (localhost:3000) and production (Render deployment).

## Core Components

- **Model**: [app/models/note.rb](app/models/note.rb) — Simple `Note` with `title`, `content`, `color`, `x_coordinate`, `y_coordinate`
- **Controller**: [app/controllers/api/v1/notes_controller.rb](app/controllers/api/v1/notes_controller.rb) — RESTful CRUD (index, create, update, destroy)
- **Routes**: [config/routes.rb](config/routes.rb) — Namespace pattern with environment-specific subdomain constraints (dev only)
- **CORS**: [config/initializers/cors.rb](config/initializers/cors.rb) — Rack-CORS configured for localhost:3000 (dev) and post-it-notes-board-react.onrender.com (prod)

## Key Workflows

### Development Server

```bash
bundle install      # Install dependencies
rails db:migrate    # Apply database migrations
rails s -p 5000     # Start server (Puma, port 5000)
```

### Testing

```bash
bundle exec rspec spec/                    # Run all RSpec tests
bundle exec rspec spec/controllers/api/v1/ # Run controller specs
```

### Database

- Database: PostgreSQL (dev/test/prod)
- Migrations: [db/migrate/](db/migrate/) — Two migrations: initial table creation and adding x/y coordinates
- Test data: [spec/factories/notes.rb](spec/factories/notes.rb) uses FactoryGirl with Faker for randomization

### Deployment

- Platform: **Render** (migrated from Heroku)
- Build script: [bin/render-build.sh](bin/render-build.sh)
- Config: [render.yaml](render.yaml) — Web service + Redis cache
- Redis: Used by `redis-rails` gem for caching/sessions

## Project Conventions

### Code Style

- **API response format**: Plain JSON (no custom wrapper). Controllers render model directly: `render json: @note`
- **Timestamps**: Rails conventions (created_at, updated_at auto-managed)
- **Parameter handling**: Strong parameters in controller (`note_params` method whitelists: title, content, color, x_coordinate, y_coordinate)
- **HTTP verbs**: Standard REST — GET, POST, PUT (via PATCH), DELETE

### Testing Patterns

- RSpec for all tests (type: `:api`)
- Shared test helpers: [spec/support/api_helper.rb](spec/support/api_helper.rb), [spec/support/request_helper.rb](spec/support/request_helper.rb)
- Example: [spec/controllers/api/v1/notes_controller_spec.rb](spec/controllers/api/v1/notes_controller_spec.rb) — Tests response status and JSON content

### Error Handling

- Destroy action returns `head :no_content, status: :ok` on success, or error JSON on failure
- No custom error response wrapper; follows Rails defaults
- Note: RSpec tests have incomplete assertions (TODO comments suggest work in progress)

## Important Context

- **Rails version**: 5.1.4 (note: at API only mode; no views, helpers, or assets served)
- **Dependencies to know**: `rack-cors`, `redis-rails`, `rspec-rails`, `factory_girl_rails`, `shoulda-matchers`
- **Environment variables**: `SECRET_KEY_BASE`, `DATABASE_URL`, `REDIS_URL` (set in Render)
- **API versioning strategy**: URL-based (`/api/v1/`), not header-based; allows future v2 namespace if needed
- **Frontend origin**: React app at https://post-it-notes-board-react.onrender.com — changes here need CORS updates

## Common Tasks

- **Add a Note field**: Migration, update [app/models/note.rb](app/models/note.rb), add to `note_params` in controller, update factory
- **Add validations**: Use ActiveModel in [app/models/note.rb](app/models/note.rb) (e.g., `validates :title, presence: true`)
- **Update CORS**: Edit [config/initializers/cors.rb](config/initializers/cors.rb) with new frontend URL
- **Test a controller action**: Follow the pattern in [spec/controllers/api/v1/notes_controller_spec.rb](spec/controllers/api/v1/notes_controller_spec.rb) — use `create_list(:note, N)` to generate test data
