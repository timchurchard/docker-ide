#!/bin/bash

# Get standard USER_ID variable
USER_ID=${HOST_USER_ID:-9001}
GROUP_ID=${HOST_GROUP_ID:-9001} # Change 'ubuntu' uid to host user's uid
if [ ! -z "$USER_ID" ] && [ "$(id -u ubuntu)" != "$USER_ID" ]; then
    # Create the user group if it does not exist
    groupadd --non-unique -g "$GROUP_ID" group    # Set the user's uid and gid
    usermod --non-unique --uid "$USER_ID" --gid "$GROUP_ID" ubuntu
fi

# Setting permissions on /home/ubuntu config
chown -R ubuntu: /home/ubuntu/.??* &

# Step down to ubuntu user
gosu ubuntu sh -c "nvim -s /tmp/gib.txt ; if [ ! -z \"$GIT_USER_NAME\" ]; then git config --global user.name \"$GIT_USER_NAME\"; git config --global user.email \"$GIT_USER_EMAIL\"; fi; cd /workspace ; mkdir -p .vim-tmp ; tmux -u -2 $@"