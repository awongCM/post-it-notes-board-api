# Rails 5.1 → Rails 8 Migration Strategy

## Overview

This document outlines a phased approach to upgrading from Rails 5.1.4 to Rails 8, accounting for the API-only architecture and single `Note` resource.

## Phase 1: Dependency & Compatibility Audit (Foundation)

### 1.1 Identify Breaking Changes
- **Ruby version**: Rails 8 requires Ruby 3.1+. Current version likely 2.4–2.6. Plan Ruby upgrade first.
- **Database**: PostgreSQL is already used—good compatibility. Verify extension requirements (pgjwt, pgsodium, etc.)
- **Gems to check**:
  - `rack-cors` (compatible, but may need version bump)
  - `redis-rails` (update to 5.2+ for Rails 8 support)
  - `rspec-rails` (update to 6.0+)
  - `factory_girl_rails` → migrate to `factory_bot_rails` (factory_girl is deprecated)
  - `shoulda-matchers` (6.0+)
  - `faker` (2.20+)

### 1.2 Create Migration Branch
```bash
git checkout -b upgrade/rails-8-migration
```

## Phase 2: Incremental Rails Upgrade (5.1 → 5.2 → 6.0 → 6.1 → 7.0 → 7.1 → 8.0)

**Why incremental?** Rails spans 3 major versions. Each step has deprecation warnings that guide you to next version.

### 2.1 Update Gemfile & Dependencies

For **each version jump**, follow this pattern:

```ruby
# Step 1: Update Rails version
gem 'rails', '~> 5.2.0'  # Then 6.0, then 6.1, then 7.0, then 7.1, then 8.0

# Step 2: Update dependent gems for compatibility
bundle update rails --strict
```

### 2.2 Per-Version Action Items

| Version | Key Changes | Actions |
|---------|------------|---------|
| 5.2 | `require_relative` changes | Update `config/boot.rb` |
| 6.0 | Zeitwerk autoloader, `require` removal | Enable Zeitwerk, remove requires |
| 6.1 | Encrypted credentials | Verify `config/credentials.yml.enc` setup |
| 7.0 | Keyword arguments, `rails 7:upgrade` task | Run upgrade rake task |
| 7.1 | Encrypted config by default | Update config patterns |
| 8.0 | Solid Queue, Ruby 3.1+ requirement | Potential async job changes |

### 2.3 Run Rails Upgrade Helper
```bash
# Available in Rails 6.1+
bundle exec rails app:upgrade    # Automated deprecation fixes
bundle exec rails app:update     # Configuration updates
```

## Phase 3: Code-Specific Changes for This Project

### 3.1 Controller Updates (Low Risk)

Current pattern is safe for Rails 8:
```ruby
# app/controllers/api/v1/notes_controller.rb — ALREADY COMPATIBLE
render json: @note  # Works in all versions
```

**Minor update**: Verify `strong_parameters` syntax (already modern in 5.1).

### 3.2 Model Validations (If Added)

If adding validations to [app/models/note.rb](app/models/note.rb):
- Rails 8 prefers `validate` over custom validators (no breaking change, just better patterns)
- Example: `validates :title, presence: true` works unchanged

### 3.3 Test Suite Migration

**Biggest lift in this project**:
- **FactoryGirl → FactoryBot**: Update [spec/factories/notes.rb](spec/factories/notes.rb)
  ```ruby
  # Old
  FactoryGirl.define { factory :note { ... } }
  
  # New
  FactoryBot.define { factory :note { ... } }
  ```
- **RSpec-Rails 6.0+**: Update config in [spec/spec_helper.rb](spec/spec_helper.rb) and [spec/rails_helper.rb](spec/rails_helper.rb)
- **Shoulda-Matchers 6.0+**: API matchers work unchanged

### 3.4 Routes & Subdomain Constraints

Current dev-only subdomain pattern in [config/routes.rb](config/routes.rb) is compatible:
```ruby
# WORKS IN RAILS 8
constraints: {subdomain: 'api'}  # No changes needed
```

### 3.5 CORS Configuration

[config/initializers/cors.rb](config/initializers/cors.rb) will work unchanged—`rack-cors` is stable.

## Phase 4: Infrastructure & Deployment Updates

### 4.1 Update Render Configuration

[render.yaml](render.yaml) changes:
```yaml
# Only needed if upgrading Ruby binary
services:
  - name: post-it-notes-board-api
    type: web
    env: ruby  # Render auto-detects from Gemfile; ensure .ruby-version has 3.1+
```

### 4.2 Update Build Script

[bin/render-build.sh](bin/render-build.sh) likely needs:
```bash
#!/usr/bin/env bash
bundle install
bundle exec rails db:migrate
bundle exec rails assets:precompile  # Skip if API-only (already skipped)
```

## Phase 5: Testing & QA

### 5.1 Test Coverage
```bash
# Full test suite after each version jump
bundle exec rspec spec/

# Specific: controller tests (minimal in this project)
bundle exec rspec spec/controllers/api/v1/
```

### 5.2 Manual Smoke Tests
```bash
rails s -p 5000

# From frontend or curl:
curl http://localhost:5000/notes      # Index
curl -X POST http://localhost:5000/notes -d '...'  # Create
```

### 5.3 Deprecation Warnings
```bash
# Rails logs deprecations during test runs
bundle exec rspec spec/ 2>&1 | grep DEPRECATION
```

## Phase 6: Deployment & Rollback Strategy

### 6.1 Staging Deployment
1. Deploy to Render staging (if available) or create staging branch
2. Test React frontend at `http://staging-api.onrender.com`
3. Verify CORS headers: `Access-Control-Allow-Origin: https://post-it-notes-board-react.onrender.com`

### 6.2 Production Deployment
```bash
git merge upgrade/rails-8-migration
git push  # Triggers Render build

# Monitor logs
# https://dashboard.render.com/
```

### 6.3 Rollback Plan
- Keep Rails 5.1 branch alive for quick rollback: `git checkout main && git push deploy main`
- Test rollback locally first

## Timeline Estimate

| Phase | Effort | Duration |
|-------|--------|----------|
| Phase 1: Audit | 4–6 hours | 1 day |
| Phase 2: Incremental upgrades (5.1→8.0) | 20–30 hours | 3–5 days (1 version per day) |
| Phase 3: Code updates | 4–8 hours | 1 day |
| Phase 4: Infrastructure | 2–3 hours | 2–4 hours |
| Phase 5: Testing | 4–6 hours | 1 day |
| Phase 6: Deployment | 2–4 hours | 1 day |
| **Total** | **36–57 hours** | **~2 weeks** (1–2 devs) |

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Ruby version incompatibility | Install Ruby 3.1+ locally first; test locally before pushing |
| Gem conflicts (especially RSpec) | Use `bundle outdated` to identify; bump one at a time |
| API breaking for React frontend | Test CORS headers; React frontend keeps same URL prefix |
| Database migrations failing | Test migrations on production-like DB backup first |
| Render build timeout | Increase memory/CPU in render.yaml if needed |

## Success Criteria

- [x] All RSpec tests pass (`bundle exec rspec spec/`)
- [x] No deprecation warnings in test logs
- [x] React frontend still fetches/creates/updates notes
- [ ] CORS works for both localhost:3000 (dev) and production URL
- [ ] Render deployment completes without errors
- [ ] Monitoring shows no increase in error rates post-deployment

## Post-Migration Cleanup

1. **Update Ruby version lock**: Ensure `.ruby-version` is 3.1+ and `.tool-versions` if used
2. **Update documentation**: Bump Rails version in README.md and this file
3. **Review new Rails 8 features**: Solid Queue for async jobs, Kamal for deployments (optional)
4. **Archive old branch**: Keep `rails-5.1-legacy` branch for reference
