In this page you will find our recommended way of installing Docker on your machine. 
This guide is made for OSX users.

## Install docker

First install Docker using [Homebrew](https://brew.sh/)
```
$ brew install docker
```

You can then install [Docker Desktop](https://docs.docker.com/get-docker/) if you wish, or use `docker-machine`. As we prefer the second option, we will only document this one.

## Setup your docker

Install `docker-machine`
```
$ brew install docker-machine
```

Then install [VirtualBox](https://www.virtualbox.org/) with [Homebrew Cask](https://github.com/Homebrew/homebrew-cask) to get a driver for your Docker machine
```
$ brew cask install virtualbox
```

You may need to enter your password and authorize the application in your `System Settings` > `Security & Privacy`.

Create now a new machine, set it up as default and connect your shell to it (here we use zsh. The commands should anyway be displayed in each steps' output)

```
$ docker-machine create --driver virtualbox default
$ docker-machine env default
$ eval "$(docker-machine env default)"
```

Now you're all setup to use our provided Docker image!


