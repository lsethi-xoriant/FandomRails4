#!/bin/bash

#
# updates Fandom installation by pulling a remote archive
#

STAGE_ENVIRONMENT="app@stage.fandomlab.com"

echo "checking for new Fandom releases..."

# acquire a lock so that only one instance of this script at time will run
lockfile="$HOME/railsapps/Fandom/remote_update.lock"
tempfile=$(mktemp)
mv -n $tempfile $lockfile > /dev/null 2>&1
if [ -e $tempfile ]; then
    echo "lock acquisition failed: $lockfile"
    echo "something bad happened (perhaps another remote update is running concurrently), please check it manually... I'm bailing out!"
    exit 1
else
    echo "acquired lock: $lockfile"
fi

set -e

# check if the current release is the same as the stage environment
remote_current=$(ssh -o "StrictHostKeyChecking no" $STAGE_ENVIRONMENT "readlink ~/railsapps/Fandom/current")
current=$(readlink ~/railsapps/Fandom/current)
if [ "$current" == "$remote_current" ]; then
    echo "Fandom release is up to date"
else
    echo "updating current Fandom release to: $remote_current"

    # check if the required release already exists; if not, downloads it
    cd ~/railsapps/Fandom/
    if [ ! -d $remote_current ]; then
        for filename in current current_assets; do
            archive="$STAGE_ENVIRONMENT:~/railsapps/Fandom/$filename.tgz"
            echo "downloading $archive"
            scp -o "StrictHostKeyChecking no" $archive .
            tar --overwrite -xhzf $filename.tgz
        done
    fi

    # sets the current link and restart rails
    ln -nfs $remote_current current
    service railsweb restart
    /etc/init.d/log_daemon restart	
fi

# release lock
rm $lockfile