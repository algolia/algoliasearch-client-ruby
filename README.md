# Algolia Search API Client for Ruby

[Algolia Search](https://www.algolia.com) is a hosted full-text, numerical, and faceted search engine capable of delivering realtime results from the first keystroke.
The **Algolia Search API Client for Ruby** lets you easily use the [Algolia Search REST API](https://www.algolia.com/doc/rest-api/search) from your Ruby code.

[![Build Status](https://travis-ci.org/algolia/algoliasearch-client-ruby.svg?branch=master)](https://travis-ci.org/algolia/algoliasearch-client-ruby) [![Gem Version](https://badge.fury.io/rb/algoliasearch.svg)](http://badge.fury.io/rb/algoliasearch) [![Code Climate](https://codeclimate.com/github/algolia/algoliasearch-client-ruby.svg)](https://codeclimate.com/github/algolia/algoliasearch-client-ruby) [![Coverage Status](https://coveralls.io/repos/algolia/algoliasearch-client-ruby/badge.svg)](https://coveralls.io/r/algolia/algoliasearch-client-ruby)


If you are a **Ruby on Rails** user, you are probably looking for the [algoliasearch-rails](https://github.com/algolia/algoliasearch-rails) gem.




## API Documentation

You can find the full reference on [Algolia's website](https://www.algolia.com/doc/api-client/ruby/).


## Table of Contents


1. **[Install](#install)**

    * [Ruby on Rails](#ruby-on-rails)

1. **[Quick Start](#quick-start)**

    * [Initialize the client](#initialize-the-client)
    * [Push data](#push-data)
    * [Search](#search)
    * [Configure](#configure)
    * [Frontend search](#frontend-search)

1. **[Getting Help](#getting-help)**





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

You first need to initialize the client. For that you need your **Application ID** and **API Key**.
You can find both of them on [your Algolia account](https://www.algolia.com/api-keys).

```ruby
require 'rubygems'
require 'algoliasearch'

Algolia.init :application_id => "YourApplicationID",
             :api_key        => "YourAPIKey"
```

### Push data

Without any prior configuration, you can start indexing [500 contacts](https://github.com/algolia/algoliasearch-client-csharp/blob/master/contacts.json) in the ```contacts``` index using the following code:
```ruby
index = Algolia::Index.new("contacts")
batch = JSON.parse(File.read("contacts.json"))
index.add_objects(batch)
```

### Search

You can now search for contacts using firstname, lastname, company, etc. (even with typos):

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

### Configure

Settings can be customized to tune the search behavior. For example, you can add a custom sort by number of followers to the already great built-in relevance:

```ruby
index.set_settings({"customRanking" => ["desc(followers)"]})
```

You can also configure the list of attributes you want to index by order of importance (first = most important):

**Note:** Since the engine is designed to suggest results as you type, you'll generally search by prefix.
In this case the order of attributes is very important to decide which hit is the best:

```ruby
index.set_settings({"searchableAttributes" => ["lastname", "firstname", "company",
                                            "email", "city", "address"]})
```

### Frontend search

**Note:** If you are building a web application, you may be more interested in using our [JavaScript client](https://github.com/algolia/algoliasearch-client-javascript) to perform queries.

It brings two benefits:
  * Your users get a better response time by not going through your servers
  * It will offload unnecessary tasks from your servers

```html
<script src="https://cdn.jsdelivr.net/algoliasearch/3/algoliasearch.min.js"></script>
<script>
var client = algoliasearch('ApplicationID', 'apiKey');
var index = client.initIndex('indexName');

// perform query "jim"
index.search('jim', searchCallback);

// the last optional argument can be used to add search parameters
index.search(
  'jim', {
    hitsPerPage: 5,
    facets: '*',
    maxValuesPerFacet: 10
  },
  searchCallback
);

function searchCallback(err, content) {
  if (err) {
    console.error(err);
    return;
  }

  console.log(content);
}
</script>
```

## Getting Help

- **Need help**? Ask a question to the [Algolia Community](https://discourse.algolia.com/) or on [Stack Overflow](http://stackoverflow.com/questions/tagged/algolia).
- **Found a bug?** You can open a [GitHub issue](https://github.com/algolia/algoliasearch-client-ruby/issues).



