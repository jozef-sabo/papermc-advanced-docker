#!/bin/bash

# Set nullstrings back to 'latest'
: ${TIMEZONE:='Europe/London'}

ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# CHANGE OWNER OF /PAPERMC TO RUNNER
chown -R runner:runner /papermc

# CREATE KEYS
ssh-keygen -A


# CREATE USERS
# Parse the user list and create users with passwords
IFS=',' # Set the delimiter
for userpass in $USER_LIST; do
    IFS=':' read -r username password <<< "$userpass"
    adduser -D "$username"
    echo "$username:$password" | chpasswd
    echo "User $username created"

done

/usr/sbin/sshd -D -e "$@" &

IFS=',' # Set the delimiter
for useracl in $ACL; do
    IFS=':' read -r username acl <<< "$useracl"
    # defined in dockerfile
    if (( acl & 2 ))
    then
        addgroup "$username" config
        echo "Added $username to config group"
    fi

    if (( acl & 4 ))
    then
        addgroup "$username" plugins
        echo "Added $username to plugins group"
    fi
done

for try in {1..50} ; do
    # server.properties generated always, even if eula failed
    if [ -f /papermc/server.properties ] ; then
        sleep 10  # to completely generate plugins with config files

        chown :config /papermc/server.properties
        chmod g+w /papermc/server.properties

        chown :config /papermc/bukkit.yml
        chmod g+w /papermc/bukkit.yml

        chown :config /papermc/spigot.yml
        chmod g+w /papermc/spigot.yml

        chown -R :config /papermc/config
        chmod -R g+w /papermc/config

        chown -R :plugins /papermc/plugins
        chmod -R g+w /papermc/plugins

        echo "Groups successfully set"
        break
    fi

    echo "Waiting for server.properties to generate (try $try/50)"
    sleep 1
done

echo "Privileged script finished"