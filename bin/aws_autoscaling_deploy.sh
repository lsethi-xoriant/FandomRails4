#!/bin/bash

AWS_REMOTE_UPDATE_COMMAND="bash -l ~/bin/aws_remote_update.sh"

ruby $(dirname $0)/aws_autoscaling_execute.rb app "$AWS_REMOTE_UPDATE_COMMAND"