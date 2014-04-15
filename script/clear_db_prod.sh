#!/usr/bin/env bash
rake db:drop RAILS_ENV=production
rake db:create RAILS_ENV=production
rake db:migrate RAILS_ENV=production
rake db:seed RAILS_ENV=production
rake instant_win:generate_wins RAILS_ENV=production
