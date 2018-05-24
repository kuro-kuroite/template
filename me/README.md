# Rails with Postgres on Vagrant

# Getting Started


## install VirtualBox

<http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html?ssSourceSiteId=otnjp>


## install Vagrant

<https://www.vagrantup.com/downloads.html>


# TL; DR


## setup Virtual environment

```sh
$ vagrant init ubuntu/xenial64
```


## edit Vagrantfile

* Vagrantfile

```sh
$ diff Vagrantfile_orig Vagrantfile
35c35
<   # config.vm.network "private_network", ip: "192.168.33.10"
---
>   config.vm.network "private_network", ip: "192.168.33.10"
69a70,71
>   config.vm.provision :shell, privileged: false, path: "./vagrant/setup_rails.sh"
>   config.vm.provision :shell, privileged: false, path: "./vagrant/generate_rails_app.sh"
```


## add setup script in vagrant directory

+ ./vagrant/setup_rails.sh
+ ./vagrant/generate_rails_app.sh


# custom settings


## add environment settings for Rails app

you can set any environment in /vagrant/.env

### setting environment

like `APP_NAME="sample_app"`

* ~~RUBY_VERSION~~
* ~~NODE_VERSION~~
* ~~RAILS_VERSION~~
* ~~POSTGRESQL_VERSION~~
* ~~DATABASE_USERNAME~~
* SHARED_DIR
* APP_NAME
* APP_ROOT
* DATABASE_USERNAME
* DATABASE_PASSWORD
* DATABASE_TEMPLATE


## make Rails environment

```sh
$ vagrant up
$ vagrant provision
```
