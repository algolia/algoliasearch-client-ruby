<p align="center">
  <a href="https://www.algolia.com">
    <img alt="Algolia for Ruby" src="https://raw.githubusercontent.com/algolia/algoliasearch-client-common/master/banners/ruby.png" >
  </a>

  <h4 align="center">The perfect starting point to integrate <a href="https://algolia.com" target="_blank">Algolia</a> within your Ruby project</h4>

  <p align="center">
    <a href="https://circleci.com/gh/algolia/algoliasearch-client-ruby"><img src="https://circleci.com/gh/algolia/algoliasearch-client-ruby.svg?style=shield" alt="CircleCI" /></a>
    <a href="https://rubygems.org/gems/algolia"><img src="https://badge.fury.io/rb/algolia.svg" alt="Gem Version"></a>
    <a href="https://rubygems.org/gems/algolia"><img src="https://img.shields.io/badge/licence-MIT-blue.svg" alt="License"></a>
  </p>
</p>

<p align="center">
  <a href="https://www.algolia.com/doc/api-client/getting-started/install/ruby/" target="_blank">Documentation</a>  •
  <a href="https://github.com/algolia/algoliasearch-rails" target="_blank">Rails</a>  •
  <a href="https://discourse.algolia.com" target="_blank">Community Forum</a>  •
  <a href="http://stackoverflow.com/questions/tagged/algolia" target="_blank">Stack Overflow</a>  •
  <a href="https://github.com/algolia/algoliasearch-client-ruby/issues" target="_blank">Report a bug</a>  •
  <a href="https://www.algolia.com/doc/api-client/troubleshooting/faq/ruby/" target="_blank">FAQ</a>  •
  <a href="https://www.algolia.com/support" target="_blank">Support</a>
</p>

## ✨ Features

- Thin & minimal low-level HTTP client to interact with Algolia's API
- Supports Ruby `^2.2`.

## 💡 Getting Started

First, install Algolia Ruby API Client via the [RubyGems](https://rubygems.org/) package manager:
```bash
gem install algolia
```

Then, create objects on your index:


```ruby
client = Algolia::Search::Client.create('YourApplicationID', 'YourAPIKey')
index = client.init_index('your_index_name')

index.save_objects([objectID: 1, name: 'Foo'])
```

Finally, you may begin searching a object using the `search` method:
```ruby
objects = index.search('Foo')
```

For full documentation, visit the **[Algolia Ruby API Client](https://www.algolia.com/doc/api-client/getting-started/install/ruby/)**.

## ❓ Troubleshooting

Encountering an issue? Before reaching out to support, we recommend heading to our [FAQ](https://www.algolia.com/doc/api-client/troubleshooting/faq/ruby/) where you will find answers for the most common issues and gotchas with the client.

## Upgrade from V1 to V2

If you were using the v1 and wish to update to v2, please follow our [Upgrade Guide](upgrade_guide.md)

## Why is there a Dockerfile?

If you wish to contribute to the repository but would like to avoid installing all the dependencies locally, we provided you with a Docker image. You can build it with the following command
```.env
docker build -t algolia-ruby --build-arg ALGOLIA_APPLICATION_ID_1 \
--build-arg ALGOLIA_ADMIN_KEY_1 \
--build-arg ALGOLIA_SEARCH_KEY_1 \
--build-arg ALGOLIA_APPLICATION_ID_2 \
--build-arg ALGOLIA_ADMIN_KEY_2 \
--build-arg ALGOLIA_APPLICATION_ID_MCM \
--build-arg ALGOLIA_ADMIN_KEY_MCM .
```

and run it like this
```.env
docker run -it --rm -v $PWD:/app -w /app algolia-ruby bash
```

Once the container is up, you can edit files directly in your IDE: changes will be mirrored in the image.
To launch the tests, you have different choices
```shell script
# run only the unit tests
bundle exec rake test:unit

# run only the integration tests
bundle exec rake test:integration

# run the whole test suite
bundle exec rake test:all

# run a single test
bundle exec rake test TEST=/full/path/to/test.rb TESTOPTS="--name=test_name"
```

If you're an external contributor, you'll only need the `ALGOLIA_APPLICATION_ID_1`, `ALGOLIA_ADMIN_KEY_1` and `ALGOLIA_SEARCH_KEY_1`. The other variables are used to run the complete [Common Test Suite](https://github.com/algolia/algoliasearch-client-specs/tree/master/common-test-suite).
If you would like to use the docker image but are not familiar with Docker, please check our [dedicated guide](DOCKER_README.MD).

## 📄 License

Algolia Ruby API Client is an open-sourced software licensed under the [MIT license](LICENSE.md).
