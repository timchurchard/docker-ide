# timchurchard/ide IDE for golang with neovim in docker
FROM ubuntu:23.10

# Install system tools
RUN apt-get update -y && apt-get upgrade -y && \
    apt install -y sudo gosu git curl zsh tmux apt-utils gnupg software-properties-common unzip locales build-essential cmake gettext htop

# Install Github CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
	chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
	apt update && \
	apt install -y gh

# Install aws cli v2
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip -L && \
    unzip awscliv2.zip && ./aws/install && \
    mkdir -p ~/.aws/ && touch ~/.aws/credentials && \
    /usr/local/bin/aws --version

# Install terraform
# Note: Version 1.4.5 is fixed due to licensing issues with newer versions
RUN curl -o- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt update && apt install -y terraform=1.4.5-*

# Install terragrunt
# Note: Version v0.45.4 is fixed due to compatibility with terraform
RUN curl -L -o terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.45.4/terragrunt_linux_amd64 && \
    chmod a+x terragrunt && install terragrunt /usr/local/bin/terragrunt && rm terragrunt

# Install python3 venv into /opt/venv
# Note: rexi is a terminal regex101 (https://github.com/royreznik/rexi)
RUN apt install -y python3 python3-venv && \
	python3 -m venv /opt/venv && \
	/opt/venv/bin/python3 -m pip install -U pip setuptools && \
	/opt/venv/bin/pip3 install neovim && \
	/opt/venv/bin/pip3 install pylint pytest yapf && \
	/opt/venv/bin/pip3 install rexi

ENV PATH=$PATH:/opt/venv/bin

# Install neovim: https://github.com/neovim/neovim/wiki/Installing-Neovim
ENV VIM_COMMIT=v0.9.5
RUN apt install -y lua-nvim luajit ruby-dev && \
	apt remove neovim neovim-runtime neovim-qt && \
	git clone https://github.com/neovim/neovim.git neovim.git && \
	cd neovim.git && \
	git reset --hard ${VIM_COMMIT} && \
	echo "building neovim ${VIM_COMMIT}... this will take a while" && \
	make CMAKE_BUILD_TYPE=RelWithDebInfo >build.log 2>&1 && make install && \
    ln -sfv /usr/local/bin/nvim /usr/bin/vim && \
    ln -sf /usr/local/bin/nvim /usr/bin/vi

# Ruby neovim. dep
RUN gem install neovim

# Deps of telescope
RUN apt install -y ripgrep fd-find

# Free (apt) space - No more apt after this
RUN apt-get autoclean -y && apt-get autoremove -y && apt-get clean -y

# Install golang
ENV GOLANG_URL=https://golang.org/dl/go1.21.7.linux-amd64.tar.gz
ENV GOLANG_SHA256=13b76a9b2a26823e53062fa841b07087d48ae2ef2936445dc34c4ae03293702c

RUN curl -o golang.tgz -L ${GOLANG_URL} && \
    echo "$GOLANG_SHA256 golang.tgz" > golang.tgz.sha256 && \
    sha256sum --check golang.tgz.sha256 && \
    tar -C /opt -zxf golang.tgz

# tree-sitter
RUN curl -OL https://github.com/tree-sitter/tree-sitter/releases/download/v0.20.9/tree-sitter-linux-x64.gz && \
	gunzip tree-sitter-linux-x64.gz && \
	chmod a+x tree-sitter-linux-x64 && \
	mv tree-sitter-linux-x64 /usr/bin/tree-sitter && \
	tree-sitter --version

# Setup normal user (ubuntu -> /home/ubuntu) and /workspace for mount
RUN mkdir /workspace && \
    echo "dev       ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers

# Setup locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Note: entrypoint.sh will attempt to update UID/GID to match host!
ENV GROUP=ubuntu
ENV USER=ubuntu
ENV UID=1000

RUN chsh -s /usr/bin/zsh ubuntu

WORKDIR /home/ubuntu

# Switch to normal user for home build
USER ubuntu:ubuntu

# Install font: https://www.nerdfonts.com/
RUN mkdir -p ~/.fonts && cd ~/.fonts && \
	curl -o Go-Mono.zip -L https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Go-Mono.zip && \
	unzip Go-Mono.zip

# Install Oh my zsh
RUN curl -o- -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash

# Install nvm and node stable
ENV NVM_DIR="/home/ubuntu/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash && \
	zsh -c ". $NVM_DIR/nvm.sh && nvm install stable && npm install -g neovim"

# Install vim-plug
RUN curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Fetch nvim plugins (notice fixed versions)
RUN mkdir -p ~/.config/nvim/plugged && cd ~/.config/nvim/plugged && \
	git clone --depth 1 https://github.com/stevearc/aerial.nvim.git && \
	git clone --depth 1 https://github.com/nvim-lua/plenary.nvim.git && \
	git clone --branch 0.1.5 --depth 1 https://github.com/nvim-telescope/telescope.nvim.git && \
	git clone --depth 1 https://github.com/windwp/nvim-autopairs.git && \
	git clone --depth 1 https://github.com/ntpeters/vim-better-whitespace.git && \
	git clone --depth 1 https://github.com/neovim/nvim-lspconfig.git && \
	git clone --branch v0.9.1 --depth 1 https://github.com/nvim-treesitter/nvim-treesitter.git && \
	git clone --branch 0.7.0 --depth 1 https://github.com/mfussenegger/nvim-dap.git && \
	git clone --branch v3.9.3 --depth 1 https://github.com/rcarriga/nvim-dap-ui.git && \
	git clone --depth 1 https://github.com/theHamsta/nvim-dap-virtual-text.git && \
	git clone --depth 1 https://github.com/ray-x/guihua.lua.git && \
	git clone --depth 1 https://github.com/ray-x/lsp_signature.nvim.git && \
	git clone --depth 1 https://github.com/ray-x/go.nvim.git && \
	git clone --depth 1 https://github.com/neoclide/coc.nvim.git && \
	git clone --depth 1 https://github.com/kyazdani42/nvim-web-devicons.git && \
	git clone --depth 1 https://github.com/kyazdani42/nvim-tree.lua.git && \
	git clone --depth 1 https://github.com/vim-airline/vim-airline.git && \
	git clone --depth 1 https://github.com/vim-airline/vim-airline-themes.git && \
	git clone --depth 1 https://github.com/akinsho/toggleterm.nvim.git && \
	git clone --depth 1 https://github.com/preservim/nerdcommenter.git && \
	git clone --depth 1 https://github.com/tpope/vim-fugitive.git && \
	git clone --depth 1 https://github.com/hashivim/vim-terraform.git && \
	git clone --depth 1 https://github.com/EdenEast/nightfox.nvim.git

# Install go tools
ENV GO111MODULE=on
ENV CGO_ENABLED=0

ENV PATH=$PATH:/opt/go/bin:/home/ubuntu/go/bin

COPY files/install-gotools.sh /tmp/install-gotools.sh
RUN /bin/bash /tmp/install-gotools.sh

# Install neovim plugins and go tools
COPY files/vimrc .config/nvim/
COPY files/init.vim .config/nvim/
COPY files/coc-settings.json .config/nvim/

RUN zsh -c ". $NVM_DIR/nvm.sh && cd ~/.config/nvim/plugged/coc.nvim && npm ci"

RUN echo ':PlugInstall' > /tmp/gib.txt && \
	echo ':GoInstallBinaries' >> /tmp/gib.txt && \
    echo ':TSInstall go' >> /tmp/gib.txt && \
	echo ':q' >> /tmp/gib.txt && \
	echo ':q' >> /tmp/gib.txt && \
    echo ':q' >> /tmp/gib.txt && \
	zsh -c ". $NVM_DIR/nvm.sh && nvim -s /tmp/gib.txt"

# Copy in final bits for /opt
COPY files/entrypoint.sh /opt/

COPY files/zshrc .zshrc
COPY files/gitconfig .gitconfig
COPY files/tmux.conf .tmux.conf
COPY files/pylintrc .pylintrc

# Switch back to root and setup entrypoint
USER root:root

#CMD ["/bin/bash"]
CMD ["/opt/entrypoint.sh"]
