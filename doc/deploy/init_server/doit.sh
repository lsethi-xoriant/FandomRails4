#!/bin/bash

set -e
set -x

#
# Configuration
#

export POSTGRESQL_VERSION=9.3

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
  default-jdk \
  supervisor \
  traceroute \
  autoconf \
  bison \
  libreadline-dev \
  ntp

  
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
cp etc/nginx-courtesy_page /etc/nginx/sites-available/courtesy_page
ln -s /etc/nginx/sites-available/courtesy_page /etc/nginx/sites-enabled
service nginx restart

#
# Setup logrotate
# 

cp etc/logrotate-rails /etc/logrotate.d/rails

#
# Supervisor
# 

cp etc/supervisor/supervisord.conf /etc/supervisor
cp etc/supervisor/log_daemon.conf /etc/supervisor/conf.d
service supervisor restart

#
# Setup init scripts
#

mkdir /etc/railsweb
cp etc/railsweb-unicorn.conf /etc/railsweb/unicorn.conf

chmod a+x etc/init.d/* 
cp etc/init.d/* /etc/init.d/

update-rc.d fandomplay defaults 50
update-rc.d railsweb defaults 60

#
# Security updates
#

cp etc/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/
cp etc/apt.conf.d/50unattended-upgrades /etc/apt/apt.conf.d/

#
# Run the other commands as user "app"
#

sudo -u app -i bash $(pwd)/app-doit.sh 

