#!/usr/bin/env bash

# FIXME: この段階では、まだRubyがはいっていないため、
#   環境変数の設定をshで書く必要がある
# ruby ./vagrant/set_env.rb

${RUBY_VERSION:=2.5.1}
${NODE_VERSION:=8.11.1}
${RAILS_VERSION:=5.1.6}
${POSTGRESQL_VERSION:=9.3}
${DATABASE_USERNAME:=vagrant}

# change iterative mode on Bash. Bash mode is non-intaractive in Vagrant
# by http://ta2gch.hateblo.jp/entry/2016/08/17/110959
set -i
source ~/.bashrc
source ~/.bash_profile

# update apt
sudo apt update -y
# kernel のドライバをインストールするときに、ディスク容量越えか何かで落ちるためコメントアウト
# sudo apt upgrade -y

# install libraries in ubuntu for ruby
sudo apt install -y build-essential libssl-dev libreadline-dev zlib1g-dev
sudo apt install -y git

# install ruby through rbenv
if ! [ -d ~/.rbenv ]; then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  # コメントインすると、Rubyがインストールできないバグがあるため
  # source ~/.bashrc

  ## install rbenv-build for rbenv
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  # 最新(18-0424)のREADMEではこの記述がないため削除
  # echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
  rbenv -v

  ## install ruby
  # RUBY_VERSION=2.5.1
  rbenv install $RUBY_VERSION
  rbenv global $RUBY_VERSION
  rbenv rehash
  rbenv versions
  ruby -v
fi

# install Rails 5

## install nodejs for Rails JS Runtime
if ! [ -d ~/.nodenv ]; then
  # curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  # sudo apt install -y nodejs

  ## install nodejs through nodenv
  git clone https://github.com/nodenv/nodenv.git ~/.nodenv
  ~/.nodenv/src/configure && make -C ~/.nodenv/src
  echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >>  ~/.bashrc
  echo 'eval "$(nodenv init -)"' >> ~/.bashrc
  source ~/.bashrc
  nodenv -v

  ### install node-build for nodenv
  git clone https://github.com/nodenv/node-build.git ~/.nodenv/plugins/node-build

  # NODE_VERSION=8.11.1
  nodenv install $NODE_VERSION
  nodenv global $NODE_VERSION
  nodenv rehash
  nodenv versions
  node -v
fi

## install libraries in ubuntu for rails
sudo apt install -y sqlite3 libsqlite3-dev

### add no rdoc and ri in gem command
echo 'install: --no-document' >> ~/.gemrc
echo 'update: --no-document' >> ~/.gemrc

## install rails throught gem
if ! [ which rails ]; then
  # RAILS_VERSION=5.1.6
  rbenv rehash
  gem install rails -v $RAILS_VERSION
  rails -v
fi


## install postgresql

if ! [ which psql ]; then
  # echo deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main > /etc/apt/sources.list.d/pgdg.list
  # apt install -y wget ca-certificates
  # wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  # apt -yV install postgresql-9.4 postgresql-common postgresql-client-common

  # sudo apt install -y postgresql libpq-dev

  sudo apt install -y wget
  sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
  wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
  sudo apt -y update
  sudo apt -y install postgresql-common
  sudo apt -y install postgresql-${POSTGRESQL_VERSION} libpq-dev


  ### setting postgres in ubuntu

  # fix permissions
  echo "-------------------- fixing listen_addresses on postgresql.conf"
  sudo sed -i "s/#listen_address.*/listen_addresses = '*'/" /etc/postgresql/${POSTGRESQL_VERSION}/main/postgresql.conf

  echo "-------------------- fixing postgres pg_hba.conf file"
  # replace the ipv4 host line with the above line
  cat <<-EOF | sudo tee -a /etc/postgresql/${POSTGRESQL_VERSION}9.3/main/pg_hba.conf >/dev/null
# Accept all IPv4 connections - FOR DEVELOPMENT ONLY!!!
host    all         all         0.0.0.0/0             md5
EOF

  sudo apt install -y expect
  # linuxのpostgresユーザーにパスワード付与
  expect -c "
  spawn sudo passwd postgres
  expect Enter\ ;  send pass\n;
  expect Retype\ ; send pass\n;
  expect eof exit 0
  "

  # vagrantユーザを追加
  # FIXME: provision で設定が反映できていない
  #        generate_rails_app.sh で同じコマンドを追加
  sudo -u postgres createuser ${DATABASE_USERNAME} -s
  # linuxのpostgresでdbのpostgresのパスワード付与
  sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'pass';"
fi

sudo /etc/init.d/postgresql restart
