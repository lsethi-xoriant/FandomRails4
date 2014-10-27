#!/bin/bash

COMMAND="sudo -i ruby /home/app/railsapps/Fandom/current/bin/toggle_nginx_courtesy_page.rb"

ruby $(dirname $0)/aws_autoscaling_execute.rb ubuntu "$COMMAND"