#!/bin/bash

# Setup git
if [ ! -z "$GIT_USER_NAME" ]; then
	git config --global user.name "$GIT_USER_NAME"
	git config --global user.email "$GIT_USER_EMAIL"
fi

# If .gnupg directory exists then start the agent
if [ -d /home/ubuntu/.gnupg ]; then
	gpg-agent --daemon
fi

# If .ssh directory exists then

mkdir -p .vim-tmp

cd /workspace
tmux -u -2 $@
