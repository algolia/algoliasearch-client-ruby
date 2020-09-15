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
Renamed to `clear_objects`.

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

### `list_indexes
No change.

### `delete_index`
Instead of calling the `delete_index` method on the client, you should call the `delete` method directly on the index object.

```ruby
index = client.init_index('foo')
index.delete
```

### `copy_index`
No change.

### `browse`
Renamed to `browse_objects`.

### `move_index`
No change.

### `index.exists?`
No change.

### `generate_secured_api_key`
This method is moved to the `Algolia::Search::Client` class.
```ruby
secured_api_key = Algolia::Search::Client.generate_secured_api_key('api_key', {
  validUntil: now - (10 * 60)
})
```

### `add_api_key`
`acl` is still the first parameter. The other parameters have been moved to the `reuqestOptions`.

```ruby
client.add_api_key(['search'], {
  description: 'A description',
  indexes: ['index']
})
```

### `update_api_key`
This method is moved to the `Algolia::Search::Client` class.
```ruby
client.update_api_key('api_key', { maxHitsPerQuery: 42 })
```

### `delete_api_key`
No change.

### `restore_api_key`
No change.

### `get_api_key`
No change.

### `list_api_keys`
No change.

### `get_secured_api_key_remaining_validity`
This method is moved to the `Algolia::Search::Client` class.
```ruby
Algolia::Search::Client.get_secured_api_key_remaining_validity('api_key')
```

### `save_synonym`
The `objectID` parameter has been removed, and should be part of the synonym hash.
```ruby
index.save_synonym({ objectID: 'one', type: 'synonym', synonyms: %w(one two) })
```

### `batch_synonyms`
Renamed to `save_synonyms`. `forwardToReplicas` and `replaceExistingSynonyms` parmameters are now part of `requestOptions`.
```ruby
synonym = synonym2 = {}
index.save_synonyms([synonym, synonym2], { forwardToReplicas: true, replaceExistingSynonyms: true })
```

### `delete_synonym`
No change.

### `clear_synonyms`
No change.

### `get_synonym`
No change.

### `search_synonyms`
No change.

### `replace_all_synonyms`
No change.

### `copy_synonyms`
No change.

### `export_synonyms`
Renamed to `browse_synonyms`.

### `save_rule`
The `objectID` parameter has been removed, and should be part of the Rule object.
```ruby
index.save_rule({
  objectID: 'one',
  condition: { anchoring: 'is', pattern: 'pattern' },
  consequence: {
   params: {
      query: {
        edits: [
          { type: 'remove', delete: 'pattern' }
        ]
      }
    }
  }
})
```

### `batch_rules`
Renamed to `save_rules`. The `forwardToReplicas` and `clearExistingRules` parameters should now be part of the `requestOptions`.
```ruby
rules = []
index.save_rules(rules, { forwardToReplicas: true, clearExistingRules: true })
```

### `get_rule`
No change.

### `delete_rule`
The `forwardToReplicas` parameter is now part of the `requestOptions`.
```ruby
index.delete_rule('rule-id', { forwardToReplicas: true })
```

### `clear_rules`
The `forwardToReplicas` parameter is now part of the `requestOptions`.
```ruby
index.clear_rules({ forwardToReplicas: true })
```

### `search_rules`
No change.

### `replace_all_rules`
No change.

### `copy_rules`
No change.

### `export_rules`
Renamed to `browse_rules`.

### `add_ab_test`
No change.

### `get_ab_test`
No change.

### `get_ab_tests`
No change.

### `stop_ab_test`
No change.

### `delete_ab_test`
No change.

