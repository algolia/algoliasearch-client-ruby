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
  <a href="https://www.algolia.com/doc/libraries/ruby/" target="_blank">Documentation</a>  •
  <a href="https://github.com/algolia/algoliasearch-rails" target="_blank">Rails</a>  •
  <a href="https://discourse.algolia.com" target="_blank">Community Forum</a>  •
  <a href="http://stackoverflow.com/questions/tagged/algolia" target="_blank">Stack Overflow</a>  •
  <a href="https://github.com/algolia/algoliasearch-client-ruby/issues" target="_blank">Report a bug</a>  •
  <a href="https://www.algolia.com/doc/api-client/troubleshooting/faq/ruby/" target="_blank">FAQ</a>  •
  <a href="https://alg.li/support" target="_blank">Support</a>
</p>

## ✨ Features

Thin & minimal low-level HTTP client to interact with Algolia's API

## 💡 Getting Started

First, install Algolia Ruby API Client via the [RubyGems](https://rubygems.org/) package manager:
```bash
gem install algolia
```

Then, create objects on your index:


```ruby
client = Algolia::SearchClient.create('YourApplicationID', 'YourAPIKey')

client.save_object('your_index_name', {objectID: 1, name: 'Foo'})
```

Finally, you may begin searching a object using the `search` method:
```ruby
objects = client.search_single_index('your_index_name', 'Foo')
```

For full documentation, visit the **[Algolia Ruby API Client](https://www.algolia.com/doc/libraries/ruby/)**.

## ❓ Troubleshooting

Encountering an issue? Before reaching out to support, we recommend heading to our [FAQ](https://www.algolia.com/doc/api-client/troubleshooting/faq/ruby/) where you will find answers for the most common issues and gotchas with the client. You can also open [a GitHub issue](https://github.com/algolia/api-clients-automation/issues/new?assignees=&labels=&projects=&template=Bug_report.md)

## Contributing

This repository hosts the code of the generated Algolia API client for Ruby, if you'd like to contribute, head over to the [main repository](https://github.com/algolia/api-clients-automation). You can also find contributing guides on [our documentation website](https://api-clients-automation.netlify.app/docs/introduction).

## 📄 License

The Algolia Ruby API Client is an open-sourced software licensed under the [MIT license](LICENSE).
