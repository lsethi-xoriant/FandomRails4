#!/bin/bash

set -e
set -x

# this script is called with sudo, passing the working directory as parameter
cd $(dirname $0)

#
# create postgresql database
#
createdb fandom

#
# create some configuration file for RVM
#
cp etc/app-gemrc ~/.gemrc
cp etc/app-rvmrc ~/.rvmrc
cp etc/app-bashrc ~/.bashrc

#
# setup SSH
#
cp -a etc/ssh ~/.ssh/
chmod 600 ~/.ssh/id_rsa

#
# Setup the maintenance pages
#
cp -a etc/public_html ~

#
# Setup bin dir
#
mkdir ~/bin
cp etc/aws_remote_update.sh ~/bin

#
# create a default database.yml file on the server
#
mkdir -p ~/railsapps/Fandom/shared/config/
cp etc/database.yml ~/railsapps/Fandom/shared/config/

#
# install RVM and the base gems 
#
\curl -sSL https://get.rvm.io | bash -s -- --version latest

source "$HOME/.rvm/scripts/rvm"

rvm install 1.9.3
gem install bundler
gem install rmagick -v '2.13.2'
gem install rails -v 3.2.17
gem install daemons
gem install activerecord-postgresql-adapter