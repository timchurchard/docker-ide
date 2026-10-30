#!/bin/bash

. /home/ubuntu/.nvm/nvm.sh

# Note! This step in the Dockerfile was not working. It would execute the command and immediately quit without waiting
#RUN nvim +:PlugInstall +:qa \
#	nvim +:GoInstallBinaries +:qa \
#	nvim "+:TSInstall go" +:qa \
#	nvim "+:CocInstall coc-json coc-tsserver coc-go" +:qa
#
# Note! This script does not work from the Dockerfile. Until I have time to investigate I've made a tgz of the downloaded files.
# The script works on an interactive shell inside the docker container so I've run it and zipped the files for now.
# tar czfvp install-nvim-extras.tar.gz /home/ubuntu/.config/nvim/plugged/nvim-treesitter /home/ubuntu/.config/coc
# (After bumping build versions rerun this script in a fresh container & regenerate the tarball!)

# Start the plug install & go binaries, although this should be covered by the git clone & install-gotools.sh script already
screen -d -m nvim "+:PlugInstall"
screen -d -m nvim "+:GoInstallBinaries"

# Start the treesitter install for go
screen -d -m nvim "+:TSInstall go python"

while [ ! -f /home/ubuntu/.config/nvim/plugged/nvim-treesitter/parser/go.so ]; do
	sleep 0.5
done

while [ ! -f /home/ubuntu/.config/nvim/plugged/nvim-treesitter/parser/python.so ]; do
	sleep 0.5
done

# Start the coc install for go
screen -d -m nvim "+:CocInstall coc-json coc-tsserver coc-go coc-python"

while [ ! -d /home/ubuntu/.config/coc/extensions/node_modules/coc-go ]; do
	sleep 0.5
done

while [ ! -d /home/ubuntu/.config/coc/extensions/node_modules/coc-python ]; do
	sleep 0.5
done

while [ ! -d /home/ubuntu/.config/coc/extensions/node_modules/coc-tsserver ]; do
	sleep 0.5
done

while [ ! -d /home/ubuntu/.config/coc/extensions/node_modules/coc-json ]; do
	sleep 0.5
done
