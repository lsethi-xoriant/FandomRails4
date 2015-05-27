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
# Setup the maintenance pages
#
cp -a etc/public_html ~

#
# Setup bin dir
#
mkdir ~/bin
cp etc/aws_remote_update.sh ~/bin
ln -s ~/railsapps/Fandom/current/bin/events.rb ~/bin

#
# create a default database.yml file on the server
#
mkdir -p ~/railsapps/Fandom/shared/config/
cp etc/database.yml ~/railsapps/Fandom/shared/config/

#
# install RVM and the base gems 
#
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

\curl -sSL https://get.rvm.io | bash -s -- --version latest

source "$HOME/.rvm/scripts/rvm"

rvm install ruby-2.2-head --autolibs=disable
gem install bundler
gem install rmagick
gem install rails
gem install activerecord-postgresql-adapter
gem install sys-proctable
gem install aws-ses