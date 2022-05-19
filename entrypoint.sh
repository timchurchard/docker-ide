#!/bin/bash

# Get standard USER_ID variable
USER_ID=${HOST_USER_ID:-9001}
GROUP_ID=${HOST_GROUP_ID:-9001} # Change 'dev' uid to host user's uid
if [ ! -z "$USER_ID" ] && [ "$(id -u dev)" != "$USER_ID" ]; then
    # Create the user group if it does not exist
    groupadd --non-unique -g "$GROUP_ID" group    # Set the user's uid and gid
    usermod --non-unique --uid "$USER_ID" --gid "$GROUP_ID" dev
fi

# Git config
if [ ! -z "$GIT_USER_NAME" ] && [ ! -z "$GIT_USER_EMAIL" ]; then
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Setting permissions on /home/dev config
chown -R dev: /home/dev/.??*

# Step down to dev user
gosu dev tmux -u -2 "$@"
