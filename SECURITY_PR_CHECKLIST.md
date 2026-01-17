## Security PR Checklist

Purpose: Harden production security for the Rails API — enforce TLS, require master key, filter sensitive logs, tighten CORS, and add basic rate-limiting skeleton.

Summary (PR title suggestion)
- Harden production security: SSL, master key, logs, CORS, rate-limits

Files to review
- `config/environments/production.rb`
- `config/initializers/filter_parameter_logging.rb`
- `config/initializers/cors.rb`
- `config/initializers/rack_attack.rb` (new)
- `Gemfile` (add `rack-attack`)

Behavior checklist (what reviewer should verify)
- SSL enforced: `config.force_ssl = true` in production
- Master key required: `config.require_master_key = true` in production and `RAILS_MASTER_KEY` set in deployment
- Secrets only in env/encrypted credentials (no plaintext `secret_key_base` in repo)
- Log filtering: `config.filter_parameters` includes `:secret_key_base, :api_key, :token, :authorization`
- CORS tightened: `resource '/v1/*'` and explicit headers
- Rate-limits: `rack-attack` present with sane throttles
- Tests: `bundle exec rspec` passes (no regressions)
- Smoke: exercise GET/POST/PUT/DELETE on `/v1/notes`

Tests / QA required before merge
- Run unit tests: `bundle exec rspec`
- Run dependency check: `bundle audit` or `snyk test`
- Manual smoke tests against staging/prod

Quick commands (local)
```bash
# run tests
bundle exec rspec

# run a quick audit (if bundle-audit installed)
bundle exec bundle-audit check --update
```

Small, reviewable code patches (apply only after review)

1) Enforce SSL and require master key (production)
```diff
*** production.rb (snippet) ***
@@
  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Enforce TLS and require master key in production
  config.force_ssl = true
  config.require_master_key = true
```

2) Filter additional sensitive parameters
```diff
*** config/initializers/filter_parameter_logging.rb ***
@@
Rails.application.config.filter_parameters += [
  :password,
  :secret_key_base,
  :api_key,
  :token,
  :authorization
]
```

3) Tighten CORS to API namespace and explicit headers
```diff
*** config/initializers/cors.rb ***
@@
  # PROD - restrict to API namespace and explicit headers
  allow do
    origins 'https://post-it-notes-board-react.onrender.com'
    resource '/v1/*',
      headers: ['Authorization', 'Content-Type', 'Accept'],
      methods: [:get, :post, :put, :patch, :delete, :options],
      credentials: true
  end
```

4) Gemfile addition (add `rack-attack`)
```diff
*** Gemfile (snippet) ***
@@
 gem 'rack-cors', :require => 'rack/cors'
 gem 'rack-attack'
```

5) `rack-attack` initializer skeleton
```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  # Throttle any IP to 100 requests per 10 minutes
  throttle('req/ip', limit: 100, period: 10.minutes) do |req|
    req.ip
  end

  # Throttle unauthenticated POSTs to /v1/notes
  throttle('posts/unauth', limit: 20, period: 10.minutes) do |req|
    if req.path.start_with?('/v1/notes') && req.post? && req.get_header('HTTP_AUTHORIZATION').blank?
      req.ip
    end
  end
end

Rails.application.config.middleware.use Rack::Attack
```

Optional follow-ups (separate PRs)
- Add API authentication (tokens, JWT, or OAuth)
- Add `secure_headers` and CSP/HSTS tuning
- Add automated dependency scanning (Dependabot/Snyk)

Rollback plan
- Revert the commit(s) that add `rack-attack` and the config changes; document required env vars for rollback.

---
Place this file in the repo root so reviewers can use it as the PR description + checklist.
