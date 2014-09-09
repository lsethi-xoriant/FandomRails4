#!/bin/bash

set -e
set -x

#
# Configuration
#

POSTGRESQL_VERSION=9.3
# this is just the version of the ubuntu package, the actual ruby version is installed with RVM
RUBY_VERSION=1.9.1

#
# Timezone
#

echo "Europe/Rome" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

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
  libmagickwand-dev \
  whois \
  unzip \
  memcached \
  awscli \
  cloud-utils \
  default-jdk
  
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

cp etc/nginx.conf /etc/nginx/
cp etc/nginx-default /etc/nginx/sites-available/default
service nginx restart

#
# Setup logrotate
# 

cp etc/logrotate-rails /etc/logrotate.d/rails

#
# Setup init scripts
#

cp etc/railsweb-init.d /etc/init.d/railsweb
chmod a+x /etc/init.d/railsweb
mkdir /etc/railsweb
cp etc/railsweb-unicorn.conf /etc/railsweb/unicorn.conf
update-rc.d railsweb defaults

cp etc/fandomplay-init.d /etc/init.d/fandomplay
chmod a+x /etc/init.d/fandomplay
update-rc.d fandomplay defaults


#
# Setup log_daemon
#
cp etc/log_daemon-init.d /etc/init.d/log_daemon
chmod a+x /etc/init.d/log_daemon
update-rc.d log_daemon defaults

#
# Run the other commands as user "app"
#

sudo -u app -i bash $(pwd)/app-doit.sh 

