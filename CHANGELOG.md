2018-05-07 1.20.0
			* Feat: deprecate api keys methods on index in favor of client ones (#286)
			* Chore(gemfile): remove useless dependencies (#280)
			* Fix(env): adding default env var (#279)
			* Chore(travis): test against rubinius 3 (#281)
			* Fix: prevent saving a rule with an empty objectid (#283)

2018-04-03 1.19.2
      * Fix Algolia.delete_index wrong number of arguments (#277)

2017-12-18 1.19.1
      * Fix hard dependency on `hashdiff` (#262)

2017-12-15 1.19.0
      * Add request options to any method using API calls (#213)
      * Add export_synonyms index method (#260)
      * Add export_rules index method (#261)

2017-12-07 1.18.5
      * Fix missing requirement

2017-12-06 1.18.4
      * Remove remaining unnecessary requirements (#256)
      * Remove Gemfile.lock (#257)

2017-12-04 1.18.3
      * Remove Bundler and RubyGems requirements (#253)

2017-11-28 1.18.2
      * Add (undocumented) gzip option to disable gzip (#240)

2017-11-15 1.18.1
      * Fix get_logs always returning type `all` (#244)
      * New scopes to copy_index method (#243)

2017-11-02 1.18.0
      * Allow to reuse the webmocks using `Algolia::WebMock.mock!` (#256)

2017-10-10 1.17.0
      * New delete_by method

2017-09-14 1.16.0
      * New Query Rules API

2017-08-17 1.15.1
      * Fixed regression introduced in 1.15.0

2017-08-17 1.15.0
      * Make delete_by_query not wait_task by default (also, make it mockable)
      * Add a new delete_by_query! doing the last wait_task

2017-07-31 1.14.0
      * Ability to override the underlying user-agent

2017-03-17 1.13.0
      * Add a `index.get_task_status(taskID)` method (#199)

2017-03-01 1.12.7
      * Renamed all `*_user_key` methods to `*_api_key`

2017-01-25 1.12.6
      * Upgraded `httpclient` to 2.8.3

2016-12-07 1.12.5
      * Fixed retry strategy not keeping the `current_host` first #163

2016-12-07 1.12.4
      * Fix DNS tests

2016-12-06 1.12.3
      * Allow for multiple clients on different app ids on the same thread

2016-12-05 1.12.2
      * Fix client scoped methods

2016-11-25 1.12.1
      * Rename `search_facet` to `search_for_facet_values`

2016-10-31 1.12.0
      * Add `search_facet`

2016-08-21 1.11.0
      * Upgraded to httpclient 2.8.1 to avoid reseting the keep-alive while changing timeouts

2016-07-11 1.10.0
      * `{get,set}_settings` now take optional custom query parameters

2016-06-17 1.9.0
      * New synonyms API

2016-04-14 1.8.1
      * Ensure we're using an absolute path for the `ca-bundle.crt` file (could fix some `OpenSSL::X509::StoreError: system lib` errors)

2016-04-06 1.8.0
      * Upgraded to httpclient 2.7.1 (includes ruby 2.3.0 deprecation fixes)
      * Upgraded WebMock URLs

2016-01-09 1.7.0
      * New generate_secured_api_key embedding the filters in the resulting key

2015-08-01 1.6.1
      * Search queries are now using POST requests

2015-07-19 1.6.0
      * Ability to instantiate multiple API clients in the same process (was using a class variable before).

2015-07-14 1.5.1
      * Ability to retrieve a single page from a cursor with `browse_from`

2015-06-05 1.5.0
      * New cursor-based browse() implementation taking query parameters

2015-05-27 1.4.3
      * Do not call `WebMock.disable!` in the helper

2015-05-04 1.4.2
      * Add new methods to add/update api key
      * Add batch method to target multiple indices
      * Add strategy parameter for the multipleQueries
      * Add new method to generate secured api key from query parameters

2015-04-10  1.4.1
      * Force the default connect/read/write/search/batch timeouts to Algolia-specific values

2015-03-17  1.4.0
      * High-available DNS: search queries are now targeting "APPID-DSN.algolia.net" first, then the main cluster using NSOne, then the main cluster using Route53.
        Indexing queries are targeting "APPID.algolia.net" first, then the main cluster using NSOne, then the main cluster using Route53.

2014-11-29  1.3.1
      * Fixed wrong deployed version (1.3.0 was based on 1.2.13 instead of 1.2.14)

2014-11-29  1.3.0
      * Use algolia.net domain instead of algolia.io

2014-11-10 1.2.14
      * Force the underlying httpclient dependency to be >= 2.4 in the gemspec as well
      * Ability to force the SSL version

2014-10-22 1.2.13
      * Fix the loop on hosts to retry when the http code is different than 200, 201, 400, 403, 404

2014-10-08  1.2.12

      * Upgrade to httpclient 2.4
      * Do not reset the timeout on each requests

2014-09-14  1.2.11

      * Ability to update API keys

2014-08-22  1.2.10

      * Using Digest to remove "Digest::Digest is deprecated; Use Digest" warning (author: @dglancy)

2014-07-10  1.2.9

      * Expose connect_timeout, receive_timeout and send_timeout
      * Add new 'delete_by_query' method to delete all objects matching a specific query
      * Add new 'get_objects' method to retrieve a list of objects from a single API call
      * Add a helper to perform disjunctive faceting

2014-03-27  1.2.8

      * Catch all exceptions before retrying with another host

2014-03-24  1.2.7

      * Ruby 1.8 compatibility

2014-03-19  1.2.6

      * Raise an exception if no APPLICATION_ID is provided
      * Ability to get last API call errors
      * Ability to send multiple queries using a single API call
      * Secured API keys generation is now based on secured HMAC-SHA256

2014-02-24  1.2.5

      * Ability to generate secured API key from a list of tags + optional user_token
      * Ability to specify a list of indexes targeted by the user key

2014-02-21  1.2.4

      * Added delete_objects

2014-02-10  1.2.3

      * add_object: POST request if objectID is nil OR empty

2014-01-11  1.2.2

      * Expose batch requests

2014-01-07  1.2.1

      * Removed 'jeweler' since it doesn't support platform specific deps (see https://github.com/technicalpickles/jeweler/issues/170)

2014-01-07  1.2.0

      * Removed 'curb' dependency and switched on 'httpclient' to avoid fork-safety issue (see issue #5)

2014-01-06  1.1.18

      * Fixed batch request builder (broken since last refactoring)

2014-01-02  1.1.17

      * Ability to use IP rate limit behind a proxy forwarding the end-user's IP
      * Add documentation for the new 'attributeForDistinct' setting and 'distinct' search parameter

2013-12-16  1.1.16

      * Add arguments type-checking
      * Normalize save_object/partial_update/add_object signatures
      * Force dependencies versions

2013-12-16  1.1.15

      * Embed ca-bundle.crt

2013-12-11  1.1.14

      * Added index.add_user_key(acls, validity, rate_limit, maxApiCalls)

2013-12-10  1.1.13

      * WebMock integration

2013-12-05  1.1.12

      * Add browse command

2013-11-29  1.1.11

      * Remove rubysl (rbx required dependencies)

2013-11-29  1.1.10

      * Fixed gzip handling bug

2013-11-28  1.1.9

      * Added gzip support

2013-11-26  1.1.8

      * Add partial_update_objects method

2013-11-08  1.1.7

      * Search params: encode array-based parameters (tagFilters, facetFilters, ...)

2013-11-07  1.1.6

      * Index: clear and clear! methods can now be used the delete the whole content of an index
      * User keys: plug new maxQueriesPerIPPerHour and maxHitsPerQuery parameters

2013-10-17  1.1.5

      * Version is now part of the user-agent

2013-10-17  1.1.4

      * Fixed wait_task not sleeping at all

2013-10-15  1.1.3

      * Fixed thread-safety issues.  - Curl sessions are now thread-local

2013-10-02  1.1.2

      * Fixed instance/class method conflict

2013-10-01  1.1.1

      * Updated documentation
      * Plug copy/move index

2013-09-17  1.1.0

      * Initial import
