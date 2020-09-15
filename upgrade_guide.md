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
`searchParameters` and `requestOptions` are a single parameter now. 

### `search_for_facet_values`
`searchParameters` and `requestOptions` are a single parameter now.

### `multiple_queries`
The `strategy` parameter is no longer a string, but a key in the `requestOptions`.

```ruby
client.multiple_queries([
        { indexName: 'index_name1', params: to_query_string({ query: '', hitsPerPage: 2 }) },
        { indexName: 'index_name2', params: to_query_string({ query: '', hitsPerPage: 2 }) }
      ], { strategy: 'none' })
```

### `find_object`
The method takes a lambda, proc or block as the first argument (anything that responds to `call`), and the `requestOptions` as the second
```ruby
index.find_object(-> (hit) { h.yes? }, { query: '', paginate: true })
```

### `get_object_position`
The classname has changed, not the method itself.
```ruby
objects = []
position = Algolia::Search::Index.find_object_position(objects, 'objectID-to-find')
```

### `add_object` and `add_objects`
These methods have been removed in favor of `save_object` and `save_objects`.

### `save_object` and `save_objects`
No change.

### `partial_update_object`
The `objectID` parameter is removed. `create_if_not_exists` is now part of the `requestOptions` parameter.

```ruby
obj = { objectID: '1234', prop: 'value' }
index.partial_update_object(obj, { createIfNotExists: true })
```

### `partial_update_objects`
The `create_if_not_exists` parameter is now part of the `requestOptions` parameter.

```ruby
objects = []
index.partial_update_objects(objects, { createIfNotExists: true })
```

### `delete_object` and `delete_objects`
No change.

### `replace_all_objects`
No change.

### `delete_by`
No change.

### `clear_index`
Renamed to `clear_objects`

### `get_object` and `get_objects`
The `attributesToRetrieve` parameter is now part of the `requestOptions`.
```ruby
index.get_object('1234', { attributesToRetrieve: ['title'] })
index.get_objects([1,2,3], { attributesToRetrieve: ['title'] })
```

### `multiple_get_objects`
No change.

### `batch`
No change.

### `get_settings`
No change.

### set_settings
No change.

### `copy_settings`
No change.

