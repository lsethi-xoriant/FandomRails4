#!/bin/bash

set -e
set -x

#
# Configuration
#

POSTGRESQL_VERSION=9.1
# this is just the version of the ubuntu package, the actual ruby version is installed with RVM
RUBY_VERSION=1.9.1

#
# System update
#

apt-get update
apt-get upgrade -y
apt-get install vim \
  openssh-server \
  build-essential \
  ruby-full \
  libmagickcore-dev \
  imagemagick libxml2-dev \
  libxslt1-dev \
  git-core \
  postgresql \
  postgresql-client \
  postgresql-server-dev-${POSTGRESQL_VERSION} \
  nginx \
  curl \
  libmagickwand-dev
apt-get build-dep ruby${RUBY_VERSION}

#
# Add the user running rails
#

adduser -gecos "User running Shado's apps" app
adduser app sudo

#
# Add the user to postgresql admins
#

sudo -u postgres psql <<EOF
CREATE USER app ;
ALTER USER app WITH SUPERUSER;
EOF

#
# Setup nginx
# 

cp etc/nginx-default /etc/nginx/sites-available/default
service nginx restart

#
# Run the other commands as user "app"
#

sudo -u app -i bash $(pwd)/app-doit.sh 

