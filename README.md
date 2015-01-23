Algolia Search API Client for Ruby
==================



[Algolia Search](http://www.algolia.com) is a search API that provides hosted full-text, numerical and faceted search.
Algolia’s Search API makes it easy to deliver a great search experience in your apps & websites providing:

 * REST and JSON-based API
 * search among infinite attributes from a single searchbox
 * instant-search after each keystroke
 * relevance & popularity combination
 * typo-tolerance in any language
 * faceting
 * 99.99% SLA
 * first-class data security

This Ruby client let you easily use the Algolia Search API from your backend. It wraps [Algolia's REST API](http://www.algolia.com/doc/rest_api).

[![Build Status](https://travis-ci.org/algolia/algoliasearch-client-ruby.png?branch=master)](https://travis-ci.org/algolia/algoliasearch-client-ruby) [![Gem Version](https://badge.fury.io/rb/algoliasearch.png)](http://badge.fury.io/rb/algoliasearch) [![Code Climate](https://codeclimate.com/github/algolia/algoliasearch-client-ruby.png)](https://codeclimate.com/github/algolia/algoliasearch-client-ruby) [![Coverage Status](https://coveralls.io/repos/algolia/algoliasearch-client-ruby/badge.png)](https://coveralls.io/r/algolia/algoliasearch-client-ruby)



Table of Content
================
**Get started**

1. [Setup](#setup)
1. [Quick Start](#quick-start)
1. [Online documentation](#documentation)
1. [Tutorials](#tutorials)

**Commands reference**

1. [Add a new object](#add-a-new-object-in-the-index)
1. [Update an object](#update-an-existing-object-in-the-index)
1. [Search](#search)
1. [Get an object](#get-an-object)
1. [Delete an object](#delete-an-object)
1. [Delete by query](#delete-by-query)
1. [Index settings](#index-settings)
1. [List indices](#list-indices)
1. [Delete an index](#delete-an-index)
1. [Clear an index](#clear-an-index)
1. [Wait indexing](#wait-indexing)
1. [Batch writes](#batch-writes)
1. [Security / User API Keys](#security--user-api-keys)
1. [Copy or rename an index](#copy-or-rename-an-index)
1. [Backup / Retrieve all index content](#backup--retrieve-all-index-content)
1. [Logs](#logs)
1. [Mock](#mock)




Setup
-------------
To setup your project, follow these steps:




 1. Install AlgoliaSearch using <code>gem install algoliasearch</code>.
 2. Initialize the client with your ApplicationID and API-Key. You can find all of them on [your Algolia account](http://www.algolia.com/users/edit).

```ruby
require 'rubygems'
require 'algoliasearch'

Algolia.init :application_id => "YourApplicationID",
             :api_key        => "YourAPIKey"
```







Quick Start
-------------

This quick start is a 30 seconds tutorial where you can discover how to index and search objects.

Without any prior-configuration, you can index [500 contacts](https://github.com/algolia/algoliasearch-client-ruby/blob/master/contacts.json) in the ```contacts``` index with the following code:
```ruby
index = Algolia::Index.new("contacts")
batch = JSON.parse(File.read("contacts.json"))
index.add_objects(batch)
```

You can then start to search for a contact firstname, lastname, company, ... (even with typos):
```ruby
# search by firstname
puts index.search('jimmie').to_json
# search a firstname with typo
puts index.search('jimie').to_json
# search for a company
puts index.search('california paint').to_json
# search for a firstname & company
puts index.search('jimmie paint').to_json
```

Settings can be customized to tune the search behavior. For example you can add a custom sort by number of followers to the already good out-of-the-box relevance:
```ruby
index.set_settings({"customRanking" => ["desc(followers)"]})
```

You can also configure the list of attributes you want to index by order of importance (first = most important):
```ruby
index.set_settings({"attributesToIndex" => ["lastname", "firstname", "company",
                                            "email", "city", "address"]})
```

Since the engine is designed to suggest results as you type, you'll generally search by prefix. In this case the order of attributes is very important to decide which hit is the best:
```ruby
puts index.search('or').to_json
puts index.search('jim').to_json
```


**Notes:** If you are building a web application, you may be more interested in using our [JavaScript client](https://github.com/algolia/algoliasearch-client-js) to perform queries. It brings two benefits:
  * your users get a better response time by avoiding to go through your servers,
  * it will offload your servers of unnecessary tasks.

```html
<script type="text/javascript" src="//path/to/algoliasearch.min.js"></script>
<script type="text/javascript">
  var client = new AlgoliaSearch("YourApplicationID", "YourSearchOnlyAPIKey");
  var index = client.initIndex('YourIndexName');

  function searchCallback(success, content) {
    if (success) {
      console.log(content);
    }
  }

  // perform query "jim"
  index.search("jim", searchCallback);

  // the last optional argument can be used to add search parameters
  index.search("jim", searchCallback, { hitsPerPage: 5, facets: '*', maxValuesPerFacet: 10 });
</script>
```








Documentation
================

Check our [online documentation](http://www.algolia.com/doc/guides/ruby):
 * [Initial Import](http://www.algolia.com/doc/guides/ruby#InitialImport)
 * [Ranking &amp; Relevance](http://www.algolia.com/doc/guides/ruby#RankingRelevance)
 * [Indexing](http://www.algolia.com/doc/guides/ruby#Indexing)
 * [Search](http://www.algolia.com/doc/guides/ruby#Search)
 * [Sorting](http://www.algolia.com/doc/guides/ruby#Sorting)
 * [Filtering](http://www.algolia.com/doc/guides/ruby#Filtering)
 * [Faceting](http://www.algolia.com/doc/guides/ruby#Faceting)
 * [Geo-Search](http://www.algolia.com/doc/guides/ruby#Geo-Search)
 * [Security](http://www.algolia.com/doc/guides/ruby#Security)
 * [REST API](http://www.algolia.com/doc/rest)


Tutorials
================

Check our [tutorials](http://www.algolia.com/doc/tutorials):
 * [Searchbar with auto-completion](http://www.algolia.com/doc/tutorials/auto-complete)
 * [Searchbar with multi-categories auto-completion](http://www.algolia.com/doc/tutorials/multi-auto-complete)
 * [Instant-search](http://www.algolia.com/doc/tutorials/instant-search)



Commands reference
==================





Add a new object in the Index
-------------

Each entry in an index has a unique identifier called `objectID`. You have two ways to add en entry in the index:

 1. Using automatic `objectID` assignement, you will be able to retrieve it in the answer.
 2. Passing your own `objectID`

You don't need to explicitely create an index, it will be automatically created the first time you add an object.
Objects are schema less, you don't need any configuration to start indexing. The settings section provide details about advanced settings.

Example with automatic `objectID` assignement:

```ruby
res = index.add_object({"firstname" => "Jimmie",
                        "lastname" => "Barninger"})
puts "ObjectID=" + res["objectID"]
```

Example with manual `objectID` assignement:

```ruby
res = index.add_object({"firstname" => "Jimmie",
                        "lastname" => "Barninger"}, "myID")
puts "ObjectID=" + res["objectID"]
```

Update an existing object in the Index
-------------

You have three options to update an existing object:

 1. Replace all its attributes.
 2. Replace only some attributes.
 3. Apply an operation to some attributes

Example to replace all the content of an existing object:

```ruby
index.save_object({"firstname" => "Jimmie",
                   "lastname" => "Barninger",
                   "city" => "New York",
                   "objectID" => "myID"})
```

Example to update only the city attribute of an existing object:

```ruby
index.partial_update_object({"city" => "San Francisco",
                             "objectID" => "myID"})
```

Example to add a tag:

```ruby
index.partial_update_object({"_tags" => {"value" => "MyTag", "_operation": "Add"},
                             "objectID" => "myID"})
```

Example to remove a tag:

```ruby
index.partial_update_object({"_tags" => {"value" => "MyTag", "_operation": "Remove"},
                             "objectID" => "myID"})
```

Example to add a tag if it doesn't exist:

```ruby
index.partial_update_object({"_tags" => {"value" => "MyTag", "_operation": "AddUnique"},
                             "objectID" => "myID"})
```

Example to increment a numeric value:

```ruby
index.partial_update_object({"price" => {"value" => 42, "_operation": "Increment"},
                             "objectID" => "myID"})
```

Example to decrement a numeric value:

```ruby
index.partial_update_object({"price" => {"value" => 42, "_operation": "Decrement"},
                             "objectID" => "myID"})
```



Search
-------------

**Opening note:** If you are building a web application, you may be more interested in using our [javascript client](https://github.com/algolia/algoliasearch-client-js) to send queries. It brings two benefits:
  * your users get a better response time by avoiding to go through your servers,
  * and it will offload your servers of unnecessary tasks.


To perform a search, you just need to initialize the index and perform a call to the search function.

You can use the following optional arguments:

### Query parameters

#### Full Text Search parameters

 * **query**: (string) The instant-search query string, all words of the query are interpreted as prefixes (for example "John Mc" will match "John Mccamey" and "Johnathan Mccamey"). If no query parameter is set, retrieves all objects.
 * **queryType**: select how the query words are interpreted, it can be one of the following value:
  * **prefixAll**: all query words are interpreted as prefixes,
  * **prefixLast**: only the last word is interpreted as a prefix (default behavior),
  * **prefixNone**: no query word is interpreted as a prefix. This option is not recommended.
 * **removeWordsIfNoResults**: This option to select a strategy to avoid having an empty result page. There is three different option:
  * **lastWords**: when a query does not return any result, the last word will be added as optional (the process is repeated with n-1 word, n-2 word, ... until there is results),
  * **firstWords**: when a query does not return any result, the first word will be added as optional (the process is repeated with second word, third word, ... until there is results),
  * **none**: No specific processing is done when a query does not return any result (default behavior).
 * **minWordSizefor1Typo**: the minimum number of characters in a query word to accept one typo in this word.<br/>Defaults to 4.
 * **minWordSizefor2Typos**: the minimum number of characters in a query word to accept two typos in this word.<br/>Defaults to 8.
 * **allowTyposOnNumericTokens**: if set to false, disable typo-tolerance on numeric tokens (numbers). Default to false.
 * **typoTolerance**:  This option allows you to control the number of typos in the result set:
  * **true**: the typo-tolerance is enabled and all matching hits are retrieved. (Default behavior)
  * **false**: the typo-tolerance is disabled. For example if one result match without typos, then all results with typos will be hidden.
  * **min**: only keep the results with the minimum number of typos.
  * **strict**: hits matching with 2 typos are not retrieved if there are some matching without typos. This option is useful if you want to avoid as much as possible false positive.
 * **allowTyposOnNumericTokens**: if set to false, disable typo-tolerance on numeric tokens (numbers). Default to true.
 * **ignorePlural**: If set to true, plural won't be considered as a typo (for example car/cars will be considered as equals). Default to false.
 * **restrictSearchableAttributes** List of attributes you want to use for textual search (must be a subset of the `attributesToIndex` index setting). Attributes are separated with a comma (for example `"name,address"`), you can also use a JSON string array encoding (for example encodeURIComponent("[\"name\",\"address\"]")). By default, all attributes specified in `attributesToIndex` settings are used to search.
 * **advancedSyntax**: Enable the advanced query syntax. Defaults to 0 (false).
    * **Phrase query**: a phrase query defines a particular sequence of terms. A phrase query is build by Algolia's query parser for words surrounded by `"`. For example, `"search engine"` will retrieve records having `search` next to `engine` only. Typo-tolerance is _disabled_ on phrase queries.
    * **Prohibit operator**: The prohibit operator excludes records that contain the term after the `-` symbol. For example `search -engine` will retrieve records containing `search` but not `engine`.
 * **analytics**: If set to false, this query will not be taken into account in analytics feature. Default to true.
 * **synonyms**: If set to false, this query will not use synonyms defined in configuration. Default to true.
 * **replaceSynonymsInHighlight**: If set to false, words matched via synonyms expansion will not be replaced by the matched synonym in highlight result. Default to true.
 * **optionalWords**: a string that contains the list of words that should be considered as optional when found in the query. The list of words is comma separated.

#### Pagination parameters

 * **page**: (integer) Pagination parameter used to select the page to retrieve.<br/>Page is zero-based and defaults to 0. Thus, to retrieve the 10th page you need to set `page=9`
 * **hitsPerPage**: (integer) Pagination parameter used to select the number of hits per page. Defaults to 20.

#### Geo-search parameters

 * **aroundLatLng**: search for entries around a given latitude/longitude (specified as two floats separated by a comma).<br/>For example `aroundLatLng=47.316669,5.016670`).<br/>You can specify the maximum distance in meters with the **aroundRadius** parameter (in meters) and the precision for ranking with **aroundPrecision** (for example if you set aroundPrecision=100, two objects that are distant of less than 100m will be considered as identical for "geo" ranking parameter).<br/>At indexing, you should specify geoloc of an object with the `_geoloc` attribute (in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`)

 * **aroundLatLngViaIP**: search for entries around a given latitude/longitude (automatically computed from user IP address).<br/>For example `aroundLatLng=47.316669,5.016670`).<br/>You can specify the maximum distance in meters with the **aroundRadius** parameter (in meters) and the precision for ranking with **aroundPrecision** (for example if you set aroundPrecision=100, two objects that are distant of less than 100m will be considered as identical for "geo" ranking parameter).<br/>At indexing, you should specify geoloc of an object with the `_geoloc` attribute (in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`)


 * **insideBoundingBox**: search entries inside a given area defined by the two extreme points of a rectangle (defined by 4 floats: p1Lat,p1Lng,p2Lat,p2Lng).<br/>For example `insideBoundingBox=47.3165,4.9665,47.3424,5.0201`).<br/>At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form `{"_geoloc":{"lat":48.853409, "lng":2.348800}}`)

#### Parameters to control results content

 * **attributesToRetrieve**: a string that contains the list of object attributes you want to retrieve (let you minimize the answer size).<br/> Attributes are separated with a comma (for example `"name,address"`), you can also use a string array encoding (for example `["name","address"]` ). By default, all attributes are retrieved. You can also use `*` to retrieve all values when an **attributesToRetrieve** setting is specified for your index.
 * **attributesToHighlight**: a string that contains the list of attributes you want to highlight according to the query. Attributes are separated by a comma. You can also use a string array encoding (for example `["name","address"]`). If an attribute has no match for the query, the raw value is returned. By default all indexed text attributes are highlighted. You can use `*` if you want to highlight all textual attributes. Numerical attributes are not highlighted. A matchLevel is returned for each highlighted attribute and can contain:
  * **full**: if all the query terms were found in the attribute,
  * **partial**: if only some of the query terms were found,
  * **none**: if none of the query terms were found.
 * **attributesToSnippet**: a string that contains the list of attributes to snippet alongside the number of words to return (syntax is `attributeName:nbWords`). Attributes are separated by a comma (Example: `attributesToSnippet=name:10,content:10`). <br/>You can also use a string array encoding (Example: `attributesToSnippet: ["name:10","content:10"]`). By default no snippet is computed.
 * **getRankingInfo**: if set to 1, the result hits will contain ranking information in **_rankingInfo** attribute.


#### Numeric search parameters
 * **numericFilters**: a string that contains the list of numeric filters you want to apply separated by a comma. The syntax of one filter is `attributeName` followed by `operand` followed by `value`. Supported operands are `<`, `<=`, `=`, `>` and `>=`.

You can easily perform range queries via the `:` operator (equivalent to combining a `>=` and `<=` operand), for example `numericFilters=price:10 to 1000`.

You can also mix OR and AND operators. The OR operator is defined with a parenthesis syntax. For example `(code=1 AND (price:[0-100] OR price:[1000-2000]))` translates in `encodeURIComponent("code=1,(price:0 to 10,price:1000 to 2000)")`.

You can also use a string array encoding (for example `numericFilters: ["price>100","price<1000"]`).

#### Category search parameters
 * **tagFilters**: filter the query by a set of tags. You can AND tags by separating them by commas. To OR tags, you must add parentheses. For example, `tags=tag1,(tag2,tag3)` means *tag1 AND (tag2 OR tag3)*. You can also use a string array encoding, for example `tagFilters: ["tag1",["tag2","tag3"]]` means *tag1 AND (tag2 OR tag3)*.<br/>At indexing, tags should be added in the **_tags** attribute of objects (for example `{"_tags":["tag1","tag2"]}`).

#### Faceting parameters
 * **facetFilters**: filter the query by a list of facets. Facets are separated by commas and each facet is encoded as `attributeName:value`. To OR facets, you must add parentheses. For example: `facetFilters=(category:Book,category:Movie),author:John%20Doe`. You can also use a string array encoding (for example `[["category:Book","category:Movie"],"author:John%20Doe"]`).
 * **facets**: List of object attributes that you want to use for faceting. <br/>Attributes are separated with a comma (for example `"category,author"` ). You can also use a JSON string array encoding (for example `["category","author"]` ). Only attributes that have been added in **attributesForFaceting** index setting can be used in this parameter. You can also use `*` to perform faceting on all attributes specified in **attributesForFaceting**.
 * **maxValuesPerFacet**: Limit the number of facet values returned for each facet. For example: `maxValuesPerFacet=10` will retrieve max 10 values per facet.

#### Distinct parameter
 * **distinct**: If set to 1, enable the distinct feature (disabled by default) if the `attributeForDistinct` index setting is set. This feature is similar to the SQL "distinct" keyword: when enabled in a query with the `distinct=1` parameter, all hits containing a duplicate value for the attributeForDistinct attribute are removed from results. For example, if the chosen attribute is `show_name` and several hits have the same value for `show_name`, then only the best one is kept and others are removed.
**Note**: This feature is disabled if the query string is empty and there isn't any `tagFilters`, nor any `facetFilters`, nor any `numericFilters` parameters.

```ruby
index = Algolia::Index.new("contacts")
res = index.search("query string")
res = index.search("query string", { "attributesToRetrieve" => "firstname,lastname", "hitsPerPage" => 20})
```

The server response will look like:

```javascript
{
  "hits": [
    {
      "firstname": "Jimmie",
      "lastname": "Barninger",
      "objectID": "433",
      "_highlightResult": {
        "firstname": {
          "value": "<em>Jimmie</em>",
          "matchLevel": "partial"
        },
        "lastname": {
          "value": "Barninger",
          "matchLevel": "none"
        },
        "company": {
          "value": "California <em>Paint</em> & Wlpaper Str",
          "matchLevel": "partial"
        }
      }
    }
  ],
  "page": 0,
  "nbHits": 1,
  "nbPages": 1,
  "hitsPerPage": 20,
  "processingTimeMS": 1,
  "query": "jimmie paint",
  "params": "query=jimmie+paint&attributesToRetrieve=firstname,lastname&hitsPerPage=50"
}
```


Multi-queries
--------------

You can send multiple queries with a single API call using a batch of queries:

```ruby
# perform 3 queries in a single API call:
# - 1st query targets index `categories`
# - 2nd and 3rd queries target index `products`
res = Algolia.multiple_queries([{:index_name => "categories", "query" => my_query_string, "hitsPerPage" => 3}
  , {:index_name => "products", "query" => my_query_string, "hitsPerPage" => 3, "tagFilters" => "promotion"}
  , {:index_name => "products", "query" => my_query_string, "hitsPerPage" => 10}])

puts res["results"]
```






Get an object
-------------

You can easily retrieve an object using its `objectID` and optionnaly a list of attributes you want to retrieve (using comma as separator):

```ruby
# Retrieves all attributes
index.get_object("myID")
# Retrieves firstname and lastname attributes
res = index.get_object("myID", "firstname,lastname")
# Retrieves only the firstname attribute
res = index.get_object("myID", "fistname")
```

You can also retrieve a set of objects:

```ruby
res = index.get_objects(["myID", "myID2"])
```

Delete an object
-------------

You can delete an object using its `objectID`:

```ruby
index.delete_object("myID")
```


Delete by query
-------------

You can delete all objects matching a single query with the following code. Internally, the API client performs the query, delete all matching hits, wait until the deletions have been applied and so on.

```ruby
params = {}
index.delete_by_query("John", params)
```


Index Settings
-------------

You can retrieve all settings using the `get_settings` function. The result will contains the following attributes:


#### Indexing parameters
 * **attributesToIndex**: (array of strings) the list of fields you want to index.<br/>If set to null, all textual and numerical attributes of your objects are indexed, but you should update it to get optimal results.<br/>This parameter has two important uses:
  * *Limit the attributes to index*.<br/>For example if you store a binary image in base64, you want to store it and be able to retrieve it but you don't want to search in the base64 string.
  * *Control part of the ranking*.<br/>(see the ranking parameter for full explanation) Matches in attributes at the beginning of the list will be considered more important than matches in attributes further down the list. In one attribute, matching text at the beginning of the attribute will be considered more important than text after, you can disable this behavior if you add your attribute inside `unordered(AttributeName)`, for example `attributesToIndex: ["title", "unordered(text)"]`.
**Notes**: All numerical attributes are automatically indexed as numerical filters. If you don't need filtering on some of your numerical attributes, please consider sending them as strings to speed up the indexing.<br/>
You can decide to have the same priority for two attributes by passing them in the same string using comma as separator. For example `title` and `alternative_title` have the same priority in this example, which is different than text priority: `attributesToIndex:["title,alternative_title", "text"]`
 * **attributesForFaceting**: (array of strings) The list of fields you want to use for faceting. All strings in the attribute selected for faceting are extracted and added as a facet. If set to null, no attribute is used for faceting.
 * **attributeForDistinct**: The attribute name used for the `Distinct` feature. This feature is similar to the SQL "distinct" keyword: when enabled in query with the `distinct=1` parameter, all hits containing a duplicate value for this attribute are removed from results. For example, if the chosen attribute is `show_name` and several hits have the same value for `show_name`, then only the best one is kept and others are removed. **Note**: This feature is disabled if the query string is empty and there isn't any `tagFilters`, nor any `facetFilters`, nor any `numericFilters` parameters.
 * **ranking**: (array of strings) controls the way results are sorted.<br/>We have nine available criteria:
  * **typo**: sort according to number of typos,
  * **geo**: sort according to decreassing distance when performing a geo-location based search,
  * **words**: sort according to the number of query words matched by decreasing order. This parameter is useful when you use `optionalWords` query parameter to have results with the most matched words first.
  * **proximity**: sort according to the proximity of query words in hits,
  * **attribute**: sort according to the order of attributes defined by attributesToIndex,
  * **exact**:
    * if the user query contains one word: sort objects having an attribute that is exactly the query word before others. For example if you search for the "V" TV show, you want to find it with the "V" query and avoid to have all popular TV show starting by the v letter before it.
    * if the user query contains multiple words: sort according to the number of words that matched exactly (and not as a prefix).
  * **custom**: sort according to a user defined formula set in **customRanking** attribute.
  * **asc(attributeName)**: sort according to a numeric attribute by ascending order. **attributeName** can be the name of any numeric attribute of your records (integer, a double or boolean).
  * **desc(attributeName)**: sort according to a numeric attribute by descending order. **attributeName** can be the name of any numeric attribute of your records (integer, a double or boolean). <br/>The standard order is ["typo", "geo", "words", "proximity", "attribute", "exact", "custom"]
 * **customRanking**: (array of strings) lets you specify part of the ranking.<br/>The syntax of this condition is an array of strings containing attributes prefixed by asc (ascending order) or desc (descending order) operator.
For example `"customRanking" => ["desc(population)", "asc(name)"]`
 * **queryType**: Select how the query words are interpreted, it can be one of the following value:
  * **prefixAll**: all query words are interpreted as prefixes,
  * **prefixLast**: only the last word is interpreted as a prefix (default behavior),
  * **prefixNone**: no query word is interpreted as a prefix. This option is not recommended.
 * **separatorsToIndex**: Specify the separators (punctuation characters) to index. By default, separators are not indexed. Use `+#` to be able to search Google+ or C#.
 * **slaves**: The list of indices on which you want to replicate all write operations. In order to get response times in milliseconds, we pre-compute part of the ranking during indexing. If you want to use different ranking configurations depending of the use-case, you need to create one index per ranking configuration. This option enables you to perform write operations only on this index, and to automatically update slave indices with the same operations.
 * **unretrievableAttributes**: The list of attributes that cannot be retrieved at query time. This feature allow to have an attribute that is used for indexing and/or ranking but cannot be retrieved. Default to null.
 * **allowCompressionOfIntegerArray**: Allows compression of big integer arrays. We recommended to store the list of user ID or rights as an integer array and enable this setting. When enabled the integer array are reordered to reach a better compression ratio. Default to false.

#### Query expansion
 * **synonyms**: (array of array of words considered as equals). For example, you may want to retrieve your **black ipad** record when your users are searching for **dark ipad**, even if the **dark** word is not part of the record: so you need to configure **black** as a synonym of **dark**. For example `"synomyms": [ [ "black", "dark" ], [ "small", "little", "mini" ], ... ]`.
 * **placeholders**: (hash of array of words). This is an advanced use case to define a token substitutable by a list of words without having the original token searchable. It is defined by a hash associating placeholders to lists of substitutable words. For example `"placeholders": { "<streetnumber>": ["1", "2", "3", ..., "9999"]}` placeholder to be able to match all street numbers (we use the `< >` tag syntax to define placeholders in an attribute). For example:
  * Push a record with the placeholder: `{ "name" : "Apple Store", "address" : "&lt;streetnumber&gt; Opera street, Paris" }`
  * Configure the placeholder in your index settings: `"placeholders": { "<streetnumber>" : ["1", "2", "3", "4", "5", ... ], ... }`.
 * **disableTypoToleranceOn**: (string array). Specify a list of words on which the automatic typo tolerance will be disabled.
 * **altCorrections**: (object array). Specify alternative corrections that you want to consider. Each alternative correction is described by an object containing three attributes:
  * **word**: the word to correct
  * **correction**: the corrected word
  * **nbTypos** the number of typos (1 or 2) that will be considered for the ranking algorithm (1 typo is better than 2 typos)

  For example `"altCorrections": [ { "word" : "foot", "correction": "feet", "nbTypos": 1}, { "word": "feet", "correction": "foot", "nbTypos": 1}].`

#### Default query parameters (can be overwrite by query)
 * **minWordSizefor1Typo**: (integer) the minimum number of characters to accept one typo (default = 4).
 * **minWordSizefor2Typos**: (integer) the minimum number of characters to accept two typos (default = 8).
 * **hitsPerPage**: (integer) the number of hits per page (default = 10).
 * **attributesToRetrieve**: (array of strings) default list of attributes to retrieve in objects. If set to null, all attributes are retrieved.
 * **attributesToHighlight**: (array of strings) default list of attributes to highlight. If set to null, all indexed attributes are highlighted.
 * **attributesToSnippet**: (array of strings) default list of attributes to snippet alongside the number of words to return (syntax is 'attributeName:nbWords')<br/>By default no snippet is computed. If set to null, no snippet is computed.
 * **highlightPreTag**: (string) Specify the string that is inserted before the highlighted parts in the query result (default to "&lt;em&gt;").
 * **highlightPostTag**: (string) Specify the string that is inserted after the highlighted parts in the query result (default to "&lt;/em&gt;").
 * **optionalWords**: (array of strings) Specify a list of words that should be considered as optional when found in the query.

You can easily retrieve settings or update them:

```ruby
res = index.get_settings
puts settings.to_json
```

```ruby
index.set_settings({"customRanking" => ["desc(followers)"]})
```

List indices
-------------
You can list all your indices with their associated information (number of entries, disk size, etc.) with the `list_indexes` method:

```ruby
Algolia.list_indexes
```

Delete an index
-------------
You can delete an index using its name:

```ruby
index = Algolia::Index.new("contacts")
index.delete_index
```

Clear an index
-------------
You can delete the index content without removing settings and index specific API keys with the clearIndex command:

```ruby
index.clear_index
```

Wait indexing
-------------

All write operations return a `taskID` when the job is securely stored on our infrastructure but not when the job is published in your index. Even if it's extremely fast, you can easily ensure indexing is complete using  the same method with a `!`.

For example, to wait for indexing of a new object:
```ruby
res = index.add_object!({"firstname" => "Jimmie",
                         "lastname" => "Barninger"})
```


If you want to ensure multiple objects have been indexed, you can only check the biggest taskID with `wait_task`.

Batch writes
-------------

You may want to perform multiple operations with one API call to reduce latency.
We expose three methods to perform batch:
 * `add_objects`: add an array of object using automatic `objectID` assignement
 * `save_objects`: add or update an array of object that contains an `objectID` attribute
 * `delete_objects`: delete an array of objectIDs
 * `partial_update_objects`: partially update an array of objects that contain an `objectID` attribute (only specified attributes will be updated, other will remain unchanged)

Example using automatic `objectID` assignement:
```ruby
res = index.add_objects([{"firstname" => "Jimmie",
                          "lastname" => "Barninger"},
                         {"firstname" => "Warren",
                          "lastname" => "Speach"}])
```

Example with user defined `objectID` (add or update):
```ruby
res = index.save_objects([{"firstname" => "Jimmie",
                          "lastname" => "Barninger",
                           "objectID" => "myID1"},
                          {"firstname" => "Warren",
                          "lastname" => "Speach",
                           "objectID" => "myID2"}])
```

Example that delete a set of records:
```ruby
res = index.delete_objects(["myID1", "myID2"])
```

Example that update only the `firstname` attribute:
```ruby
res = index.partial_update_objects([{"firstname" => "Jimmie",
                                     "objectID" => "SFO"},
                                    {"firstname" => "Warren",
                                     "objectID" => "myID2"}])
```



Security / User API Keys
-------------

The admin API key provides full control of all your indices.
You can also generate user API keys to control security.
These API keys can be restricted to a set of operations or/and restricted to a given index.

To list existing keys, you can use `list_user_keys` method:
```ruby
# Lists global API Keys
Algolia.list_user_keys
# Lists API Keys that can access only to this index
index.list_user_keys
```

Each key is defined by a set of rights that specify the authorized actions. The different rights are:
 * **search**: allows to search,
 * **browse**: allow to retrieve all index content via the browse API,
 * **addObject**: allows to add/update an object in the index,
 * **deleteObject**: allows to delete an existing object,
 * **deleteIndex**: allows to delete index content,
 * **settings**: allows to get index settings,
 * **editSettings**: allows to change index settings.
 * **analytics**: allows to retrieve the analytics through the analytics API.
 * **listIndexes**: allows to list all accessible indexes.

Example of API Key creation:
```ruby
# Creates a new global API key that can only perform search actions
res = Algolia.add_user_key(["search"])
puts res['key']
# Creates a new API key that can only perform search action on this index
res = index.add_user_key(["search"])
puts res['key']
```

You can also create an API Key with advanced restrictions:

 * Add a validity period: the key will be valid only for a specific period of time (in seconds),
 * Specify the maximum number of API calls allowed from an IP address per hour. Each time an API call is performed with this key, a check is performed. If the IP at the origin of the call did more than this number of calls in the last hour, a 403 code is returned. Defaults to 0 (no rate limit). This parameter can be used to protect you from attempts at retrieving your entire content by massively querying the index.


  Note: If you are sending the query through your servers, you must use the `Algolia.with_rate_limits("EndUserIP", "APIKeyWithRateLimit") do ... end` block to enable rate-limit.

 * Specify the maximum number of hits this API key can retrieve in one call. Defaults to 0 (unlimited). This parameter can be used to protect you from attempts at retrieving your entire content by massively querying the index.
 * Specify the list of targeted indices, you can target all indices starting by a prefix or finishing by a suffix with the '*' character (for example "dev_*" matches all indices starting by "dev_" and "*_dev" matches all indices finishing by "_dev"). Defaults to all indices if empty of blank.

```ruby
# Creates a new global API key that is valid for 300 seconds
res = Algolia.add_user_key(["search"], 300)
puts res['key']
# Creates a new index specific API key:
#  - valid for 300 seconds
#  - rate limit of 100 calls per hour per IP
#  - maximum of 20 hits
#  - valid on 'my_index1' and 'my_index2'
res = index.add_user_key(["search"], 300, 100, 20, ['my_index1', 'my_index2'])
puts res['key']
```

Update the rights of an existing key:
```ruby
# Update an existing global API key that is valid for 300 seconds
res = Algolia.update_user_key("myAPIKey", ["search"], 300)
puts res['key']
# Update an existing index specific API key:
#  - valid for 300 seconds
#  - rate limit of 100 calls per hour per IP
#  - maximum of 20 hits
#  - valid on 'my_index1' and 'my_index2'
res = index.update_user_key("myAPIKey", ["search"], 300, 100, 20, ['my_index1', 'my_index2'])
puts res['key']
```
Get the rights of a given key:
```ruby
# Gets the rights of a global key
Algolia.get_user_key("f420238212c54dcfad07ea0aa6d5c45f")
# Gets the rights of an index specific key
index.get_user_key("71671c38001bf3ac857bc82052485107")
```

Delete an existing key:
```ruby
# Deletes a global key
Algolia.delete_user_key("f420238212c54dcfad07ea0aa6d5c45f")
# Deletes an index specific key
index.delete_user_key("71671c38001bf3ac857bc82052485107")
```



You may have a single index containing per-user data. In that case, all records should be tagged with their associated user_id in order to add a `tagFilters=(public,user_42)` filter at query time to retrieve only what a user has access to. If you're using the [JavaScript client](http://github.com/algolia/algoliasearch-client-js), it will result in a security breach since the user is able to modify the `tagFilters` you've set modifying the code from the browser. To keep using the JavaScript client (recommended for optimal latency) and target secured records, you can generate secured API key from your backend:

```ruby
# generate a public API key for user 42. Here, records are tagged with:
#  - 'public' if they are visible by all users
#  - 'user_XXXX' if they are visible by user XXXX
public_key = Algolia.generate_secured_api_key 'YourSearchOnlyApiKey', '(public,user_42)'
```

This public API key must then be used in your JavaScript code as follow:

```javascript
<script type="text/javascript">
  var algolia = new AlgoliaSearch('YourApplicationID', '<%= public_api_key %>');
  algolia.setSecurityTags('(public,user_42)'); // must be same than those used at generation-time
  algolia.initIndex('YourIndex').search($('#q').val(), function(success, content) {
    // [...]
  });
</script>
```

You can mix rate limits and secured API keys setting an extra `user_token` attribute both at API key generation-time and query-time. When set, a uniq user will be identified by her `IP + user_token` instead of only her `IP`. It allows you to restrict a single user to perform maximum `N` API calls per hour, even if she share her `IP` with another user.

```ruby
# generate a public API key for user 42. Here, records are tagged with:
#  - 'public' if they are visible by all users
#  - 'user_XXXX' if they are visible by user XXXX
public_key = Algolia.generate_secured_api_key 'YourRateLimitedApiKey', '(public,user_42)', 'user_42'
```

This public API key must then be used in your JavaScript code as follow:

```javascript
<script type="text/javascript">
  var algolia = new AlgoliaSearch('YourApplicationID', '<%= public_api_key %>');
  algolia.setSecurityTags('(public,user_42)'); // must be same than those used at generation-time
  algolia.setUserToken('user_42')              // must be same than the one used at generation-time
  algolia.initIndex('YourIndex').search($('#q').val(), function(success, content) {
    // [...]
  });
</script>
```



Copy or rename an index
-------------

You can easily copy or rename an existing index using the `copy` and `move` commands.
**Note**: Move and copy commands overwrite destination index.

```ruby
# Rename MyIndex in MyIndexNewName
puts Algolia.move_index("MyIndex", "MyIndexNewName")
# Copy MyIndex in MyIndexCopy
puts Algolia.copy_index("MyIndex", "MyIndexCopy")
```

The move command is particularly useful is you want to update a big index atomically from one version to another. For example, if you recreate your index `MyIndex` each night from a database by batch, you just have to:
 1. Import your database in a new index using [batches](#batch-writes). Let's call this new index `MyNewIndex`.
 1. Rename `MyNewIndex` in `MyIndex` using the move command. This will automatically override the old index and new queries will be served on the new one.

```ruby
# Rename MyNewIndex in MyIndex (and overwrite it)
puts Algolia.move_index("MyNewIndex", "MyIndex")
```

Backup / Retrieve all index content
-------------

You can retrieve all index content for backup purpose or for SEO using the browse method.
This method retrieve 1000 objects by API call and support pagination.

```ruby
# Get first page
puts index.browse(0)
# Get second page
puts index.browse(1)
```

Logs
-------------

You can retrieve the last logs via this API. Each log entry contains:
 * Timestamp in ISO-8601 format
 * Client IP
 * Request Headers (API-Key is obfuscated)
 * Request URL
 * Request method
 * Request body
 * Answer HTTP code
 * Answer body
 * SHA1 ID of entry

You can retrieve the logs of your last 1000 API calls and browse them using the offset/length parameters:
 * ***offset***: Specify the first entry to retrieve (0-based, 0 is the most recent log entry). Default to 0.
 * ***length***: Specify the maximum number of entries to retrieve starting at offset. Defaults to 10. Maximum allowed value: 1000.
 * ***onlyErrors***: Retrieve only logs with an httpCode different than 200 and 201. (deprecated)
 * ***type***: Specify the type of logs to retrieve:
  * ***query***: Retrieve only the queries.
  * ***build***: Retrieve only the build operations.
  * ***error***: Retrieve only the errors. (same as ***onlyErrors*** parameters)

```ruby
# Get last 10 log entries
puts Algolia.get_logs.to_json
# Get last 100 log entries
puts Algolia.get_logs(0, 100).to_json
# Get last 100 errors
puts Algolia.get_logs(0, 100, true).to_json
```

Mock
-------------

For testing purpose, you may want to mock Algolia's API calls. We provide a [WebMock](https://github.com/bblimke/webmock) configuration that you can use including `algolia/webmock`:

```ruby
require 'algolia/webmock'

describe 'With a mocked client' do

  before(:each) do
    WebMock.enable!
    Algolia.load_webmocks!
  end

  it "shouldn't perform any API calls here" do
    index = Algolia::Index.new("friends")
    index.add_object!({ :name => "John Doe", :email => "john@doe.org" })
    index.search('').should == {} # mocked
    index.clear_index
    index.delete_index
  end

  after(:each) do
    WebMock.disable!
  end

end
```

You can also require `'algolia/webmock_rspec'` which runs `load_webmocks!` in a before filter for you.
