# ChangeLog

## [Unreleased](https://github.com/algolia/algoliasearch-client-ruby/compare/2.1.1..master)

## [2.1.1](https://github.com/algolia/algoliasearch-client-ruby/compare/2.1.0...2.1.1) (2021-05-27)

### Fix
- Bug with read/write nodes caching ([`#455`](https://github.com/algolia/algoliasearch-client-ruby/pull/455))

## [2.1.0](https://github.com/algolia/algoliasearch-client-ruby/compare/2.0.4...2.1.0) (2021-03-30)

### Feat
- Custom dictionaries methods

### Fix
- The parameter `forwardToReplicas` should be handled independently in the `set_settings` method

## [2.0.4](https://github.com/algolia/algoliasearch-client-ruby/compare/2.0.3...2.0.4) (2021-01-05)

### Fix
- `app_api_key`: send opts with waitable method

## [2.0.3](https://github.com/algolia/algoliasearch-client-ruby/compare/2.0.2...2.0.3) (2020-11-24)

### Chore
- Containerize the repo

## [2.0.2](https://github.com/algolia/algoliasearch-client-ruby/compare/2.0.1...2.0.2) (2020-11-09)

### Fix
- Don't mutate index name on stripping

## [2.0.1](https://github.com/algolia/algoliasearch-client-ruby/compare/2.0.0...2.0.1) (2020-11-02)

### Fix
- Simplify merge of headers in `Transport` class
- `deserialize_settings` function to take into account `symbolize_keys` parameter

## [2.0.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/2.0.0) (2020-10-27)

* Initial release of v2
