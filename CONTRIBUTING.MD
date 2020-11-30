# algolia gem contributing guide

Hello and welcome to the contributing guide for algolia gem. Thanks for considering participating in our project 🙇

If this guide does not contain what you are looking for and thus prevents you from contributing, don't hesitate to leave a message on the [community forum](https://discourse.algolia.com/) or to [open an issue](https://github.com/algolia/algoliasearch-client-ruby/issues).

## Reporting an issue

Opening an issue is very effective way to contribute because many users might also be impacted. We'll make sure to fix it quickly if it's technically feasible and doesn't have important side effects for other users.

Before reporting an issue, first check that there is not an already open issue for the same topic using the [issues page](https://github.com/algolia/algoliasearch-client-ruby/issues). Don't hesitate to thumb up an issue that corresponds to the problem you have.

Another element that will help us go faster at solving the issue is to provide a reproducible test case.

## The code contribution process

algolia gem is developed in Ruby. For any code contribution, you need to:

- Fork and clone the project
- Create a new branch for what you want to solve (fix/_issue-number_, feat/_name-of-the-feature_)
- Make your changes
- Open a pull request

Depending on what you're working on, you might consider different [base branches](#branch-organization).

Then:

- Peer review of the pull request (by at least one of the core contributors)
- Automatic checks (tests, [commits](#commit-conventions), [linters](#linting))
- When everything is green, your contribution is merged 🚀

## Working with Docker

If you want to contribute to this project without installing all its dependencies, you can use our Docker image. Please check our [dedicated guide](DOCKER_README.MD) to learn more.

## Commit conventions

This project follows the [conventional changelog](https://conventionalcommits.org/) approach. This means that all commit messages should be formatted using the following scheme:

```
type(scope): description
```

In most cases, we use the following types:

- `fix`: for any resolution of an issue (identified or not)
- `feat`: for any new feature
- `refactor`: for any code change that neither adds a feature nor fixes an issue
- `docs`: for any documentation change or addition
- `chore`: for anything that is not related to the library itself (doc, tooling)

Even though the scope is optional, we try to fill it in as it helps us better understand the impact of a change. We either use the name of the widget/connector/component impacted or we use impact topic (e.g. `docs`, `tooling`, `deps`, `ci`).

Finally, if your work is based on an issue on GitHub, please add it in the dedicated `Related Issue` line of the Pull Request Template (read "[Closing issues using keywords](https://help.github.com/en/articles/closing-issues-using-keywords)").

Some examples of valid commit messages (used as first lines):

> - fix(searchbox): increase magnifying glass size
> - chore(deps): update dependency rollup-plugin-babel to v3.0.7
> - fix(connectRefinementList): set default value for limit
> - chore: reword contributions guides

## Branch organization

The project is based on the classic GitHub flow:

- `master` for the current version being worked on – Pull requests for bugs and feature related to the current major version should be created against this branch
- `vX` for each major version (`X` being a number) – Pull requests for critical bug fixes should be created against this branch

Most of the time, your pull requests should target the `master` branch.

_Note that no new features will be developed or backported for the `vX` branches._

## Requirements

To run this project, you will need:

- Ruby ≥ 2.2 

## Linting

Linters are static checkers for code. They help us maintain a consistent code base.

If your editor support them, then you will see the errors directly there. You can also run them using your command line:

```sh
rake rubocop
```

However, we recommend that you use in your workflow pre-commit hooks, to avoid submitting code that might not pass the linting task setup in the CI. To use them,
first download the gem `git-precommit`

```sh
gem install git-precommit
```

Then copy-paste the following content in a file called `pre-commit` in `.git/hooks/` 

```sh
#!/usr/bin/env sh

function unstaged_changes {
    ! git diff --quiet
}

if unstaged_changes; then
    git stash save --keep-index "Performing partial commit against `git rev-parse HEAD`"
fi

exec time bundle exec rake precommit
```


## Release

### Main version

To release a stable version, [generate a personal Github token](https://github.com/settings/tokens/new) with the `repo` scope from your logged-in Github account, go on the `master` branch (`git checkout master`) and use:

```sh
export GITHUB_TOKEN=XXX # You can add this to your .env or .bashrc/.zshrc configuration file.
yarn release
```

This will create a new Github PR proposing a PR to be made. Once merged, the CI will take care of publishing the new version on NPM registry.

If you're part of the Algolia team, you can read more details [here](https://algolia.atlassian.net/wiki/spaces/DX/pages/2034925622/JavaScript+v4+release+process).
