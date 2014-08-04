#!/bin/bash

# This script output the value of the tag "Name" of the currently running instance.
# It requires awscli and cloud-utils pacakges.
# In case some command fails, the hostname is printed instead

name=$(echo print $(aws ec2 describe-tags --filters "Name=resource-id,Values=$(ec2metadata --instance-id)") '["Tags"][0]["Value"]' | python)

if [ -z $name ]; then
	hostname
else
	echo $name
fi