#!/usr/bin/env bash

ruby ./vagrant/set_env.rb

${SHARED_DIR:=/vagrant}
${APP_NAME:=sample_app}
${APP_ROOT:=${SHARED_DIR}/${APP_NAME}}
# ${DATABASE:=postgresql}
${DATABASE_USERNAME:=vagrant}
${DATABASE_PASSWORD:=vagrant}
${DATABASE_TEMPLATE:=template0}


# change iterative mode on Bash. Bash mode is non-intaractive in Vagrant
# by http://ta2gch.hateblo.jp/entry/2016/08/17/110959
set -i
source ~/.bashrc
source ~/.bash_profile


# FIXME: APP_NAMEを環境変数から持ってこれるようにする
# ${APP_NAME:=sample_app}
cd ${SHARED_DIR}

if ! [ -d ${APP_NAME} ]; then
  ## make rails app

  rails new ${APP_NAME} -d postgresql --skip-test


  ## setting for postgresql in rails app

  cd ${APP_ROOT}
  cat <<EOF > tmp_ruby_script.rb
    f = File.open("./config/database.yml", "r")
    str = f.read
    f.close

    original_str = "  pool: <%= ENV.fetch(\"RAILS_MAX_THREADS\") { 5 } %>"
    translate_str = <<-EOL
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: ${DATABASE_USERNAME}
  password: ${DATABASE_PASSWORD}
  template: ${DATABASE_TEMPLATE}
EOL

    str.sub!(original_str, translate_str)

    f = File.open("./config/database.yml", "w")
    f.write(str)
    f.close
EOF

  ruby tmp_ruby_script.rb
  rm -f ./tmp_ruby_script.rb
  trap "
    rm -f ./tmp_ruby_script.rb
  " 0
  # by https://qiita.com/m-yamashita/items/889c116b92dc0bf4ea7d

  ## make template app

  # rails g scaffold blog title:text status:boolean

  # FIXME: role 'vagrant' does not ... のエラーに対処するため
  sudo -u postgres createuser ${DATABASE_USERNAME} -s

  cd ${APP_ROOT}
  rails db:create
fi

# FIXME: role 'vagrant' does not ... のエラーに対処するため
sudo -u postgres createuser ${DATABASE_USERNAME} -s
rails db:migrate


## start rails app

# rails s
