# Algolia Search API Client for Ruby

[Algolia Search](https://www.algolia.com) is a hosted full-text, numerical,
and faceted search engine capable of delivering realtime results from the first keystroke.

The **Algolia Search API Client for Ruby** lets
you easily use the [Algolia Search REST API](https://www.algolia.com/doc/rest-api/search) from
your Ruby code.

[![Build Status](https://travis-ci.org/algolia/algoliasearch-client-ruby.svg?branch=master)](https://travis-ci.org/algolia/algoliasearch-client-ruby) [![Gem Version](https://badge.fury.io/rb/algoliasearch.svg)](http://badge.fury.io/rb/algoliasearch) [![Code Climate](https://codeclimate.com/github/algolia/algoliasearch-client-ruby.svg)](https://codeclimate.com/github/algolia/algoliasearch-client-ruby) [![Coverage Status](https://coveralls.io/repos/algolia/algoliasearch-client-ruby/badge.svg)](https://coveralls.io/r/algolia/algoliasearch-client-ruby)


If you are a **Ruby on Rails** user, you are probably looking for the [algoliasearch-rails](https://github.com/algolia/algoliasearch-rails) gem.




## API Documentation

You can find the full reference on [Algolia's website](https://www.algolia.com/doc/api-client/ruby/).



1. **[Install](#install)**


1. **[Quick Start](#quick-start)**


1. **[Push data](#push-data)**


1. **[Configure](#configure)**


1. **[Search](#search)**


1. **[Search UI](#search-ui)**


1. **[List of available methods](#list-of-available-methods)**


# Getting Started



## Install

Install AlgoliaSearch using:

```bash
gem install algoliasearch
```

### Ruby on Rails

If you're a Ruby on Rails user; you're probably looking for the [algoliasearch-rails](https://github.com/algolia/algoliasearch-rails) gem.

## Quick Start

In 30 seconds, this quick start tutorial will show you how to index and search objects.

### Initialize the client

To begin, you will need to initialize the client. In order to do this you will need your **Application ID** and **API Key**.
You can find both on [your Algolia account](https://www.algolia.com/api-keys).

```ruby
require 'rubygems'
require 'algoliasearch'

Algolia.init(application_id: 'YourApplicationID',
             api_key:        'YourAPIKey')
index = Algolia::Index.new('your_index_name')
```

## Push data

Without any prior configuration, you can start indexing [500 contacts](https://github.com/algolia/datasets/blob/master/contacts/contacts.json) in the ```contacts``` index using the following code:
```ruby
index = Algolia::Index.new('contacts')
batch = JSON.parse(File.read('contacts.json'))
index.add_objects(batch)
```

## Configure

Settings can be customized to fine tune the search behavior. For example, you can add a custom sort by number of followers to further enhance the built-in relevance:

```ruby
index.set_settings(customRanking: ['desc(followers)'])
```

You can also configure the list of attributes you want to index by order of importance (most important first).

**Note:** The Algolia engine is designed to suggest results as you type, which means you'll generally search by prefix.
In this case, the order of attributes is very important to decide which hit is the best:

```ruby
index.set_settings searchableAttributes: %w(
  lastname
  firstname
  company
  email
  city
  address
)
```

## Search

You can now search for contacts using `firstname`, `lastname`, `company`, etc. (even with typos):

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

## Search UI

**Warning:** If you are building a web application, you may be more interested in using one of our
[frontend search UI libraries](https://www.algolia.com/doc/guides/search-ui/search-libraries/)

The following example shows how to build a front-end search quickly using
[InstantSearch.js](https://community.algolia.com/instantsearch.js/)

### index.html

```html
<!doctype html>
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/instantsearch.js@2.3/dist/instantsearch.min.css">
  <!-- Always use `2.x` versions in production rather than `2` to mitigate any side effects on your website,
  Find the latest version on InstantSearch.js website: https://community.algolia.com/instantsearch.js/v2/guides/usage.html -->
</head>
<body>
  <header>
    <div>
       <input id="search-input" placeholder="Search for products">
       <!-- We use a specific placeholder in the input to guides users in their search. -->
    
  </header>
  <main>
      
      
  </main>

  <script type="text/html" id="hit-template">
    
      <p class="hit-name">{{{_highlightResult.firstname.value}}} {{{_highlightResult.lastname.value}}}</p>
    
  </script>

  <script src="https://cdn.jsdelivr.net/npm/instantsearch.js@2.3/dist/instantsearch.min.js"></script>
  <script src="app.js"></script>
</body>
```

### app.js

```js
var search = instantsearch({
  // Replace with your own values
  appId: 'YourApplicationID',
  apiKey: 'YourSearchOnlyAPIKey', // search only API key, no ADMIN key
  indexName: 'contacts',
  routing: true,
  searchParameters: {
    hitsPerPage: 10
  }
});

search.addWidget(
  instantsearch.widgets.searchBox({
    container: '#search-input'
  })
);

search.addWidget(
  instantsearch.widgets.hits({
    container: '#hits',
    templates: {
      item: document.getElementById('hit-template').innerHTML,
      empty: "We didn't find any results for the search <em>\"{{query}}\"</em>"
    }
  })
);

search.start();
```




## List of available methods





### Search

- [Search index](https://algolia.com/doc/api-reference/api-methods/search/?language=ruby)
- [Search for facet values](https://algolia.com/doc/api-reference/api-methods/search-for-facet-values/?language=ruby)
- [Search multiple indexes](https://algolia.com/doc/api-reference/api-methods/multiple-queries/?language=ruby)
- [Browse index](https://algolia.com/doc/api-reference/api-methods/browse/?language=ruby)




### Indexing

- [Add objects](https://algolia.com/doc/api-reference/api-methods/add-objects/?language=ruby)
- [Update objects](https://algolia.com/doc/api-reference/api-methods/update-objects/?language=ruby)
- [Partial update objects](https://algolia.com/doc/api-reference/api-methods/partial-update-objects/?language=ruby)
- [Delete objects](https://algolia.com/doc/api-reference/api-methods/delete-objects/?language=ruby)
- [Delete by](https://algolia.com/doc/api-reference/api-methods/delete-by/?language=ruby)
- [Get objects](https://algolia.com/doc/api-reference/api-methods/get-objects/?language=ruby)
- [Custom batch](https://algolia.com/doc/api-reference/api-methods/batch/?language=ruby)




### Settings

- [Get settings](https://algolia.com/doc/api-reference/api-methods/get-settings/?language=ruby)
- [Set settings](https://algolia.com/doc/api-reference/api-methods/set-settings/?language=ruby)




### Manage indices

- [List indexes](https://algolia.com/doc/api-reference/api-methods/list-indices/?language=ruby)
- [Delete index](https://algolia.com/doc/api-reference/api-methods/delete-index/?language=ruby)
- [Copy index](https://algolia.com/doc/api-reference/api-methods/copy-index/?language=ruby)
- [Move index](https://algolia.com/doc/api-reference/api-methods/move-index/?language=ruby)
- [Clear index](https://algolia.com/doc/api-reference/api-methods/clear-index/?language=ruby)




### API Keys

- [Create secured API Key](https://algolia.com/doc/api-reference/api-methods/generate-secured-api-key/?language=ruby)
- [Add API Key](https://algolia.com/doc/api-reference/api-methods/add-api-key/?language=ruby)
- [Update API Key](https://algolia.com/doc/api-reference/api-methods/update-api-key/?language=ruby)
- [Delete API Key](https://algolia.com/doc/api-reference/api-methods/delete-api-key/?language=ruby)
- [Get API Key permissions](https://algolia.com/doc/api-reference/api-methods/get-api-key/?language=ruby)
- [List API Keys](https://algolia.com/doc/api-reference/api-methods/list-api-keys/?language=ruby)




### Synonyms

- [Save synonym](https://algolia.com/doc/api-reference/api-methods/save-synonym/?language=ruby)
- [Batch synonyms](https://algolia.com/doc/api-reference/api-methods/batch-synonyms/?language=ruby)
- [Delete synonym](https://algolia.com/doc/api-reference/api-methods/delete-synonym/?language=ruby)
- [Clear all synonyms](https://algolia.com/doc/api-reference/api-methods/clear-synonyms/?language=ruby)
- [Get synonym](https://algolia.com/doc/api-reference/api-methods/get-synonym/?language=ruby)
- [Search synonyms](https://algolia.com/doc/api-reference/api-methods/search-synonyms/?language=ruby)
- [Export Synonyms](https://algolia.com/doc/api-reference/api-methods/export-synonyms/?language=ruby)




### Query rules

- [Save rule](https://algolia.com/doc/api-reference/api-methods/rules-save/?language=ruby)
- [Batch rules](https://algolia.com/doc/api-reference/api-methods/rules-save-batch/?language=ruby)
- [Get rule](https://algolia.com/doc/api-reference/api-methods/rules-get/?language=ruby)
- [Delete rule](https://algolia.com/doc/api-reference/api-methods/rules-delete/?language=ruby)
- [Clear rules](https://algolia.com/doc/api-reference/api-methods/rules-clear/?language=ruby)
- [Search rules](https://algolia.com/doc/api-reference/api-methods/rules-search/?language=ruby)
- [Export rules](https://algolia.com/doc/api-reference/api-methods/rules-export/?language=ruby)




### A/B Test

- [Add A/B test](https://algolia.com/doc/api-reference/api-methods/add-ab-test/?language=ruby)
- [Get A/B test](https://algolia.com/doc/api-reference/api-methods/get-ab-test/?language=ruby)
- [List A/B tests](https://algolia.com/doc/api-reference/api-methods/list-ab-tests/?language=ruby)
- [Stop A/B test](https://algolia.com/doc/api-reference/api-methods/stop-ab-test/?language=ruby)
- [Delete A/B test](https://algolia.com/doc/api-reference/api-methods/delete-ab-test/?language=ruby)




### MultiClusters

- [Assign or Move userID](https://algolia.com/doc/api-reference/api-methods/assign-user-id/?language=ruby)
- [Get top userID](https://algolia.com/doc/api-reference/api-methods/get-top-user-id/?language=ruby)
- [Get userID](https://algolia.com/doc/api-reference/api-methods/get-user-id/?language=ruby)
- [List clusters](https://algolia.com/doc/api-reference/api-methods/list-clusters/?language=ruby)
- [List userIDs](https://algolia.com/doc/api-reference/api-methods/list-user-id/?language=ruby)
- [Remove userID](https://algolia.com/doc/api-reference/api-methods/remove-user-id/?language=ruby)
- [Search userID](https://algolia.com/doc/api-reference/api-methods/search-user-id/?language=ruby)




### Advanced

- [Get logs](https://algolia.com/doc/api-reference/api-methods/get-logs/?language=ruby)
- [Configuring timeouts](https://algolia.com/doc/api-reference/api-methods/configuring-timeouts/?language=ruby)
- [Set extra header](https://algolia.com/doc/api-reference/api-methods/set-extra-header/?language=ruby)
- [Wait for operations](https://algolia.com/doc/api-reference/api-methods/wait-task/?language=ruby)





## Getting Help

- **Need help**? Ask a question to the [Algolia Community](https://discourse.algolia.com/) or on [Stack Overflow](http://stackoverflow.com/questions/tagged/algolia).
- **Found a bug?** You can open a [GitHub issue](https://github.com/algolia/algoliasearch-client-ruby/issues).

