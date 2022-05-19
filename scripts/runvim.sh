#!/bin/bash
export PYTHON3_HOST_PROG=/opt/venv/bin/python3
source /opt/venv/bin/activate

/opt/bin/vim -u ~/.vim/vimrc "$@"
