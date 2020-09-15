## Initialize the client
There's a slight change in how you initialize the client.
```ruby
client = Algolia::Search::Client.create('APP_ID', 'API_KEY')
# OR
search_config = Algolia::Search::Config.new(app_id: app_id, api_key: api_key)
client = Algolia::Search::Client.new(search_config)
```

## Initialize an index
```ruby
client.init_index
```

## Search parameters and request options
The search parameters and request options are still optional, but they are combined into a single hash instead of two. 
For example:
```ruby
opts = {
  :headers => {
    'X-Algolia-UserToken': 'user123'
  },
  :params => {
    hitsPerPage: 50
  }
}
index.search('query', opts)
```

## Methods

### `search` 
* `searchParameters` and `requestOptions` are a single parameter now. 

### `search_for_facet_values`
* `searchParameters` and `requestOptions` are a single parameter now.

### `multiple_queries`
* The `strategy` parameter is no longer a string, but a key in the `requestOptions`.

```ruby
client.multiple_queries([
        { indexName: 'index_name1', params: to_query_string({ query: '', hitsPerPage: 2 }) },
        { indexName: 'index_name2', params: to_query_string({ query: '', hitsPerPage: 2 }) }
      ], { strategy: 'none' })
```

### `find_object`
* The method takes a lambda, proc or block as the first argument (anything that responds to `call`), and the `requestOptions` as the second
```ruby
index.find_object(-> (hit) { h.yes? }, { query: '', paginate: true })
```

### `get_object_position`
* The classname has changed, not the method itself.
```ruby
objects = []
position = Algolia::Search::Index.find_object_position(objects, 'objectID-to-find')
```