This guide shows our recommended recommended way of installing Docker on your OS X machine. 

## Install docker

First install Docker using [Homebrew](https://brew.sh/)
```
$ brew install docker
```

You can install [Docker Desktop](https://docs.docker.com/get-docker/) if you wish, or use the `docker-machine` command to work with your Docker containers. This guide assumes you use the `docker-machine` command.

## Setup your Docker

Install `docker-machine`
```
$ brew install docker-machine
```

Then install [VirtualBox](https://www.virtualbox.org/) using [Homebrew Cask](https://github.com/Homebrew/homebrew-cask) to get a driver for your Docker machine
```
$ brew cask install virtualbox
```

You may need to enter your password and authorize the application through `System Settings` > `Security & Privacy`.

Create a new machine, and set it up as default, and connect your shell to the machine with the following commands:

```
$ docker-machine create --driver virtualbox default
$ docker-machine env default
$ eval "$(docker-machine env default)"
```

Now you're all setup to use our provided Docker image!

## Build the image

```bash
docker build -t algolia-ruby .
```

## Run the image

You need to provide few environment variables at runtime to be able to run the [Common Test Suite](https://github.com/algolia/algoliasearch-client-specs/tree/master/common-test-suite).
You can set them up directly in the command

```bash
docker run -it --rm --env ALGOLIA_APPLICATION_ID_1=XXXXXX [...] -v $PWD:/app -w /app algolia-ruby bash
```

But we advise you export them in your `.bashrc` or `.zshrc`. That way, you can use [Docker's shorten syntax](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file) to retrieve your variables.

```bash
### For external contributors, only the following env variables should be enough
docker run -it --rm --env ALGOLIA_APPLICATION_ID_1 \
                    --env ALGOLIA_ADMIN_KEY_1 \
                    --env ALGOLIA_SEARCH_KEY_1 \
-v $PWD:/app -w /app algolia-ruby bash

### This is needed only to run the full test suite
docker run -it --rm --env ALGOLIA_APPLICATION_ID_1 \
                    --env ALGOLIA_ADMIN_KEY_1 \
                    --env ALGOLIA_SEARCH_KEY_1 \
                    --env ALGOLIA_APPLICATION_ID_2 \
                    --env ALGOLIA_ADMIN_KEY_2 \
                    --env ALGOLIA_APPLICATION_ID_MCM \
                    --env ALGOLIA_ADMIN_KEY_MCM \
-v $PWD:/app -w /app algolia-ruby bash
```

Once the container is up, you can edit files directly in your IDE: changes will be mirrored in the image.

Lastly to launch the tests, you can use one of the following commands
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

Feel free to contact us if you have any questions.
