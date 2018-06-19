## [1.23.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.23.1) (2018-06-19)

* Fix(analytics): gem without new analytics class

## [1.23.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.23.0) (2018-06-19)

* Feat(analytics): introduce new analytics class
* Chore(rake): use unshift to keep compat with older ruby versions
* Ruby version must be after client version in ua
* Fix ua tests with new format
* Rewrite ua
* Feat(ua): add ruby version
* Fix(syntax): this isn't php
* Tests(mcm): use unique userid everytime
* Tests(mcm): introduce auto_retry for more stable tests
* Feat(client): expose waittask in the client (#302)
* Fix(travis): always test on the latest patches (#295)

## [1.22.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.22.0) (2018-05-30)

* Rename license file (#297)
* Fix release task (#294)
* Introduce multi cluster management (#285)
* Fix(browse): ensure cursor is passed in the body (#288)
* Chore(md): update contribution-related files (#293)

## [1.21.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.21.0) (2018-05-24)

* Fix(tests): fix warning for unspecified exception (#287)
* Fix release task missing github link (#291)
* Api review (#292)

## [1.20.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.20.1) (2018-05-15)

* Fix changelog link in gemspec (#290)
* Utils: move to changelog.md and add rake task for release (#289)

## [1.20.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.20.0) (2018-05-07)

* Feat: deprecate api keys methods on index in favor of client ones (#286)
* Chore(gemfile): remove useless dependencies (#280)
* Fix(env): adding default env var (#279)
* Chore(travis): test against Rubinius 3 (#281)
* Fix: prevent saving a rule with an empty `objectID` (#283)

## [1.19.2](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.19.2) (2018-04-03)

* Fix `Algolia.delete_index` wrong number of arguments (#277)

## [1.19.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.19.1) (2017-12-18)

* Fix hard dependency on `hashdiff` (#262)

## [1.19.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.19.0) (2017-12-15)

* Add request options to any method using API calls (#213)
* Add `export_synonyms` index method (#260)
* Add `export_rules` index method (#261)

## [1.18.5](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.18.5) (2017-12-07)

* Fix missing requirement

## [1.18.4](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.18.4) (2017-12-06)

* Remove remaining unnecessary requirements (#256)
* Remove Gemfile.lock (#257)

## [1.18.3](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.18.3) (2017-12-04)

* Remove Bundler and RubyGems requirements (#253)

## [1.18.2](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.18.2) (2017-11-28)

* Add (undocumented) gzip option to disable gzip (#240)

## [1.18.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.18.1) (2017-11-15)

* Fix `get_logs` always returning type `all` (#244)
* New scopes to `copy_index` method (#243)

## [1.18.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.18.0) (2017-11-02)

* Allow to reuse the webmocks using `Algolia::WebMock.mock!` (#256)

## [1.17.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.17.0) (2017-10-10)

* New `delete_by` method

## [1.16.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.16.0) (2017-09-14)

* New Query Rules API

## [1.15.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.15.1) (2017-08-17)

* Fixed regression introduced in 1.15.0

## [1.15.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.15.0) (2017-08-17)

* Make `delete_by_query` not `wait_task` by default (also, make it mockable)
* Add a new `delete_by_query!` doing the last `wait_task`

## [1.14.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.14.0) (2017-07-31)

* Ability to override the underlying user-agent

## [1.13.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.13.0) (2017-03-17)

* Add a `index.get_task_status(taskID)` method (#199)

## [1.12.7](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.12.7) (2017-03-01)

* Renamed all `*_user_key` methods to `*_api_key`

## [1.12.6](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.12.6) (2017-01-25)

* Upgraded `httpclient` to 2.8.3

## [1.12.5](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.12.5) (2016-12-07)

* Fixed retry strategy not keeping the `current_host` first (#163)

## [1.12.4](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.12.4) (2016-12-07)

* Fix DNS tests

## [1.12.3](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.12.3) (2016-12-06)

* Allow for multiple clients on different app ids on the same thread

## [1.12.2](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.12.2) (2016-12-05)

* Fix client scoped methods

## [1.12.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.12.1) (2016-11-25)

* Rename `search_facet` to `search_for_facet_values`

## [1.12.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.12.0) (2016-10-31)

* Add `search_facet`

## [1.11.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.11.0) (2016-08-21)

* Upgraded to httpclient 2.8.1 to avoid reseting the keep-alive while changing timeouts

## [1.10.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.10.0) (2016-07-11)

* `{get,set}_settings` now take optional custom query parameters

## [1.9.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.9.0) (2016-06-17)

* New synonyms API

## [1.8.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.8.1) (2016-04-14)

* Ensure we're using an absolute path for the `ca-bundle.crt` file (could fix some `OpenSSL::X509::StoreError: system lib` errors)

## [1.8.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.8.0) (2016-04-06)

* Upgraded to `httpclient` 2.7.1 (includes ruby 2.3.0 deprecation fixes)
* Upgraded WebMock URLs

## [1.7.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.7.0) (2016-01-09)

* New `generate_secured_api_key` embedding the filters in the resulting key

## [1.6.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.6.1) (2015-08-01)

* Search queries are now using POST requests

## [1.6.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.6.0) (2015-07-19)

* Ability to instantiate multiple API clients in the same process (was using a class variable before).

## [1.5.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.5.1) (2015-07-14)

* Ability to retrieve a single page from a cursor with `browse_from`

## [1.5.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.5.0) (2015-06-05)

* New cursor-based `browse()` implementation taking query parameters

## [1.4.3](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.4.3) (2015-05-27)

* Do not call `WebMock.disable!` in the helper

## [1.4.2](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.4,2) (2015-05-04)

* Add new methods to add/update api key
* Add batch method to target multiple indices
* Add strategy parameter for the multipleQueries
* Add new method to generate secured api key from query parameters

## [1.4.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.4.1) (2015-04-10)

* Force the default connect/read/write/search/batch timeouts to Algolia-specific values

## [1.4.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.4.0) (2015-03-17)

* High-available DNS: search queries are now targeting `APPID-DSN.algolia.net` first, then the main cluster using NSOne, then the main cluster using Route53.
* High-available DNS: Indexing queries are targeting `APPID.algolia.net` first, then the main cluster using NSOne, then the main cluster using Route53.

## [1.3.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.3.1) (2014-11-29)

* Fixed wrong deployed version (1.3.0 was based on 1.2.13 instead of 1.2.14)

## [1.3.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.3.0) (2014-11-29)

* Use `algolia.net` domain instead of `algolia.io`

## [1.2.14](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.14) (2014-11-10)

* Force the underlying `httpclient` dependency to be >= 2.4 in the gemspec as well
* Ability to force the SSL version

## [1.2.13](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.13) (2014-10-22)

* Fix the loop on hosts to retry when the http code is different than 200, 201, 400, 403, 404

## [1.2.12](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.12) (2014-10-08)

* Upgrade to `httpclient` 2.4
* Do not reset the timeout on each requests

## [1.2.11](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.11) (2014-09-14)

* Ability to update API keys

## [1.2.10](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.10) (2014-08-22)

* Using Digest to remove "Digest::Digest is deprecated; Use Digest" warning (author: @dglancy)

## [1.2.9](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.9) (2014-07-10)

* Expose `connect_timeout`, `receive_timeout` and `send_timeout`
* Add new `delete_by_query` method to delete all objects matching a specific query
* Add new `get_objects` method to retrieve a list of objects from a single API call
* Add a helper to perform disjunctive faceting

## [1.2.8](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.8) (2014-03-27)

* Catch all exceptions before retrying with another host

## [1.2.7](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.7) (2014-03-24)

* Ruby 1.8 compatibility

## [1.2.6](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.6) (2014-03-19)

* Raise an exception if no `APPLICATION_ID` is provided
* Ability to get last API call errors
* Ability to send multiple queries using a single API call
* Secured API keys generation is now based on secured HMAC-SHA256

## [1.2.5](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.5) (2014-02-24)

* Ability to generate secured API key from a list of tags + optional `user_token`
* Ability to specify a list of indexes targeted by the user key

## [1.2.4](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.4) (2014-02-21)

* Add `delete_objects`

## [1.2.3](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.3) (2014-02-10)

* `add_object`: POST request if `objectID` is `nil` OR `empty`

## [1.2.2](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.2) (2014-01-11)

* Expose `batch` requests

## [1.2.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.1) (2014-01-07)

* Removed `jeweler` since it doesn't support platform specific deps (see https://github.com/technicalpickles/jeweler/issues/170)

## [1.2.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.2.0) (2014-01-07)

* Removed `curb` dependency and switched on `httpclient` to avoid fork-safety issue (see issue #5)

## [1.1.18](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.18) (2014-01-06)

* Fixed batch request builder (broken since last refactoring)

## [1.1.17](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.17) (2014-01-02)

* Ability to use IP rate limit behind a proxy forwarding the end-user's IP
* Add documentation for the new `attributeForDistinct` setting and `distinct` search parameter

## [1.1.16](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.16) (2013-12-16)

* Add arguments type-checking
* Normalize save_object/partial_update/add_object signatures
* Force dependencies versions

## [1.1.15](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.15) (2013-12-16)

* Embed ca-bundle.crt

## [1.1.14](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.14) (2013-12-11)

* Added `index.add_user_key(acls, validity, rate_limit, maxApiCalls)``

## [1.1.13](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.13) (2013-12-10)

* WebMock integration

## [1.1.12](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.12) (2013-12-05)

* Add `browse` command

## [1.1.11](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.11) (2013-11-29)

* Remove rubysl (rbx required dependencies)

## [1.1.10](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.10) (2013-11-29)

* Fixed gzip handling bug

## [1.1.9](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.9) (2013-11-28)

* Added gzip support

## [1.1.8](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.8) (2013-11-26)

* Add `partial_update_objects` method

## [1.1.7](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.7) (2013-11-08)

* Search params: encode array-based parameters (`tagFilters`, `facetFilters`, ...)

## [1.1.6](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.6) (2013-11-07)

* Index: `clear` and `clear!` methods can now be used the delete the whole content of an index
* User keys: plug new `maxQueriesPerIPPerHour` and `maxHitsPerQuery` parameters

## [1.1.5](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.5) (2013-10-17)

* Version is now part of the user-agent

## [1.1.4](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.4) (2013-10-17)

* Fixed `wait_task` not sleeping at all

## [1.1.3](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.3) (2013-10-15)

* Fixed thread-safety issues
* Curl sessions are now thread-local

## [1.1.2](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.2) (2013-10-02)

* Fixed instance/class method conflict

## [1.1.1](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.1) (2013-10-01)

* Updated documentation
* Plug copy/move index

## [1.1.0](https://github.com/algolia/algoliasearch-client-ruby/releases/tag/1.1.0) (2013-09-17)

* Initial import
