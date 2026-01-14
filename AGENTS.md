# RUBY CLIENT - AI AGENT INSTRUCTIONS

## ⚠️ CRITICAL: CHECK YOUR REPOSITORY FIRST

Before making ANY changes, verify you're in the correct repository:

```bash
git remote -v
```

- ✅ **CORRECT**: `origin .../algolia/api-clients-automation.git` → You may proceed
- ❌ **WRONG**: `origin .../algolia/algoliasearch-client-ruby.git` → STOP! This is the PUBLIC repository

**If you're in `algoliasearch-client-ruby`**: Do NOT make changes here. All changes must go through `api-clients-automation`. PRs and commits made directly to the public repo will be discarded on next release.

## ⚠️ BEFORE ANY EDIT: Check If File Is Generated

Before editing ANY file, verify it's hand-written by checking `config/generation.config.mjs`:

```javascript
// In generation.config.mjs - patterns WITHOUT '!' are GENERATED (do not edit)
'clients/algoliasearch-client-ruby/lib/algolia/**',           // Generated
'!clients/algoliasearch-client-ruby/lib/algolia/transport/**', // Hand-written ✓
'!clients/algoliasearch-client-ruby/lib/algolia/error.rb',     // Hand-written ✓
```

**Hand-written (safe to edit):**

- `lib/algolia/transport/**` - Transport, retry strategy, HTTP handling
- `lib/algolia/api_client.rb` - Core API client
- `lib/algolia/api_error.rb` - API error class
- `lib/algolia/configuration.rb` - Configuration
- `lib/algolia/error.rb` - Error base class
- `lib/algolia/logger_helper.rb` - Logging utilities
- `lib/algolia/user_agent.rb` - User agent handling

**Generated (DO NOT EDIT):**

- `lib/algolia/api/**` - API client classes
- `lib/algolia/models/**` - API models
- `Gemfile.lock`, `version.rb`

## Language Conventions

### Naming

- **Files**: `snake_case.rb`
- **Classes/Modules**: `PascalCase`
- **Methods/Variables**: `snake_case`
- **Constants**: `UPPER_SNAKE_CASE`
- **Predicates**: `method_name?` (returns boolean)
- **Dangerous methods**: `method_name!` (mutates or raises)

### Formatting

- RubyFmt for formatting
- Run: `yarn cli format ruby clients/algoliasearch-client-ruby`

### Ruby Idioms

- Use `attr_reader`, `attr_accessor` for accessors
- Prefer `||=` for memoization
- Use `&.` safe navigation operator
- Blocks over lambdas for callbacks

### Dependencies

- **HTTP**: Faraday (with Net::HTTP adapter)
- **Build**: Bundler + gemspec
- **Versions**: Ruby 3.4+

## Client Patterns

### Transport Architecture

```ruby
# lib/algolia/transport/
class Transport
  def initialize(config)
    @http_requester = HttpRequester.new(config.app_id, config.api_key)
    @retry_strategy = RetryStrategy.new(config.hosts)
  end

  def request(method, path, body, opts)
    # Retry with host failover
  end
end
```

### Retry Strategy

```ruby
# lib/algolia/transport/retry_strategy.rb
class RetryStrategy
  # Host states: :up, :down, :timed_out
  # Retries on network errors
  # 4xx errors not retried
end
```

### Configuration

```ruby
# Configuration object pattern
config = Algolia::Configuration.new(
  app_id: 'APP_ID',
  api_key: 'API_KEY',
  hosts: [...],
  read_timeout: 5,
  write_timeout: 30
)
```

## Common Gotchas

### Symbol vs String Keys

```ruby
# API returns string keys, use with_indifferent_access or symbols
response[:hits]      # May not work
response['hits']     # Works
response.hits        # Works if using model objects
```

### Block Syntax

```ruby
# Use do..end for multi-line, braces for single-line
client.search { |r| r.query = 'test' }

client.search do |params|
  params.query = 'test'
  params.hits_per_page = 10
end
```

### Error Handling

```ruby
begin
  response = client.search(params)
rescue Algolia::AlgoliaError => e
  # Base error class
rescue Algolia::ApiError => e
  # API returned error
  puts e.status_code
  puts e.message
end
```

### Nil Safety

```ruby
# Use safe navigation
result&.hits&.first&.object_id

# Or explicit checks
if result && result.hits && result.hits.any?
  result.hits.first.object_id
end
```

### Deprecated Operations

Some operations in `ingestion_client.rb` and `search_client.rb` are deprecated. Check method documentation before use.

## Build & Test Commands

```bash
# From repo root (api-clients-automation)
yarn cli build clients ruby                    # Build Ruby client
yarn cli cts generate ruby                     # Generate CTS tests
yarn cli cts run ruby                          # Run CTS tests
yarn cli playground ruby search                # Interactive playground
yarn cli format ruby clients/algoliasearch-client-ruby

# From client directory
cd clients/algoliasearch-client-ruby
bundle install                                 # Install dependencies
bundle exec rake test                          # Run tests
bundle exec rubocop                            # Run linter
```
