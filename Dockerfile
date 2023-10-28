# timchurchard/ide IDE for golang with neovim in docker
# Based on ubuntu 22.04 (LTS until 2027)
FROM ubuntu:22.04

# Install system tools
RUN apt-get update -y && apt-get upgrade -y && \
    apt install -y sudo gosu git curl zsh tmux apt-utils gnupg software-properties-common unzip locales build-essential cmake gettext

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

# Install python3 venv into /opt/venv
RUN apt install -y python3 python3-venv && \
	python3 -m venv /opt/venv && \
	/opt/venv/bin/python3 -m pip install -U pip setuptools && \
	/opt/venv/bin/pip3 install neovim && \
	/opt/venv/bin/pip3 install pylint pytest yapf

ENV PATH=$PATH:/opt/venv/bin

# Install neovim: https://github.com/neovim/neovim/wiki/Installing-Neovim
ENV VIM_COMMIT=v0.9.4
RUN apt install -y lua-nvim luajit ruby-dev && \
	apt remove neovim neovim-runtime neovim-qt && \
	git clone https://github.com/neovim/neovim.git neovim.git && \
	cd neovim.git && \
	git reset --hard ${VIM_COMMIT} && \
	echo "building neovim ${VIM_COMMIT}... this will take a while" && \
	make CMAKE_BUILD_TYPE=RelWithDebInfo >build.log 2>&1 && make install

# Use nvim for everything
#RUN update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60 && update-alternatives --config vi && \
#	update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60 &&update-alternatives --config vim && \
#	update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60 && update-alternatives --config editor

# Ruby neovim. dep
RUN gem install neovim

# Deps of telescope
RUN apt install -y ripgrep fd-find

# Free (apt) space - No more apt after this
RUN apt-get autoclean -y && apt-get autoremove -y && apt-get clean -y

# Install golang
ENV GOLANG_URL=https://golang.org/dl/go1.21.3.linux-amd64.tar.gz
ENV GOLANG_SHA256=1241381b2843fae5a9707eec1f8fb2ef94d827990582c7c7c32f5bdfbfd420c8

RUN curl -o golang.tgz -L ${GOLANG_URL} && \
    echo "$GOLANG_SHA256 golang.tgz" > golang.tgz.sha256 && \
    sha256sum --check golang.tgz.sha256 && \
    tar -C /opt -zxf golang.tgz

# tree-sitter
RUN curl -OL https://github.com/tree-sitter/tree-sitter/releases/download/v0.20.4/tree-sitter-linux-x64.gz && \
	gunzip tree-sitter-linux-x64.gz && \
	chmod a+x tree-sitter-linux-x64 && \
	mv tree-sitter-linux-x64 /usr/bin/tree-sitter && \
	tree-sitter --version

# Setup normal user (dev -> /home/dev) and /workspace for mount
RUN mkdir /workspace && \
    echo "dev       ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers

# Setup locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Note: entrypoint.sh will attempt to update UID/GID to match host!
ENV GROUP=dev
ENV USER=dev
ENV UID=1000

# Add a user!
# NOTE! This docker will start as root and entrypoint.sh will step down to user
# This is because we'll chown the home files depending on UID/GID of the host on startup
RUN groupadd ${GROUP} && \
    useradd -rm -d /home/dev -s /bin/zsh -g ${GROUP} -G sudo -u ${UID} ${USER}

WORKDIR /home/dev

# Switch to normal user for home build
USER dev:dev

# Install font: https://www.nerdfonts.com/
RUN mkdir -p ~/.fonts && cd ~/.fonts && \
	curl -o Go-Mono.zip -L https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Go-Mono.zip && \
	unzip Go-Mono.zip

# Install Oh my zsh
RUN curl -o- -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash

# Install nvm and node stable
ENV NVM_DIR="/home/dev/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash && \
	zsh -c ". $NVM_DIR/nvm.sh && nvm install stable && npm install -g neovim"

# Install vim-plug
RUN curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install go tools
ENV GO111MODULE=on
ENV CGO_ENABLED=0

ENV PATH=$PATH:/opt/go/bin:/home/dev/go/bin

RUN go install golang.org/x/tools/...@latest && \
	go install golang.org/x/tools/gopls@latest && \
	go install mvdan.cc/gofumpt@latest && \
	go install golang.org/x/lint/golint@latest && \
	go install github.com/hotei/deadcode@latest && \
	go install github.com/go-critic/go-critic/cmd/gocritic@latest && \
	go install github.com/go-delve/delve/cmd/dlv@latest && \
	go install github.com/jstemmer/gotags@latest && \
	go install github.com/tommy-muehle/go-mnd/v2/cmd/mnd@latest && \
	go install github.com/securego/gosec/cmd/gosec@latest && \
	go install filippo.io/age/cmd/...@latest && \
	go install github.com/yagipy/maintidx/cmd/maintidx@latest && \
	go install golang.org/x/vuln/cmd/govulncheck@latest && \
	go install golang.org/x/perf/cmd/benchstat@latest && \
	go install honnef.co/go/tools/cmd/staticcheck@latest && \
	go install honnef.co/go/tools/cmd/keyify@latest && \
	go install honnef.co/go/tools/cmd/structlayout-pretty@latest && \
	go install honnef.co/go/tools/cmd/structlayout-optimize@latest && \
	go install honnef.co/go/tools/cmd/keyify@latest && \
	go install honnef.co/go/tools/cmd/structlayout@latest && \
	go install github.com/golang/mock/mockgen@latest && \
	go install github.com/fatih/gomodifytags@latest && \
	go install github.com/dotzero/git-profile@latest && \
	go install gotest.tools/gotestsum@latest && \
	go install github.com/maaslalani/slides@latest && \
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
	go install github.com/google/gops@latest

# Install neovim plugins and go tools
COPY files/vimrc /home/dev/.config/nvim/
COPY files/init.vim /home/dev/.config/nvim/
COPY files/coc-settings.json /home/dev/.config/nvim/

RUN mkdir -p ~/.config/nvim/plugged && cd ~/.config/nvim/plugged && \
	git clone https://github.com/stevearc/aerial.nvim.git && \
	git clone https://github.com/lewis6991/impatient.nvim.git && \
	git clone https://github.com/nvim-lua/plenary.nvim.git && \
	git clone https://github.com/nvim-telescope/telescope.nvim.git && \
	git clone https://github.com/windwp/nvim-autopairs.git && \
	git clone https://github.com/ntpeters/vim-better-whitespace.git && \
	git clone https://github.com/neovim/nvim-lspconfig.git && \
	git clone https://github.com/nvim-treesitter/nvim-treesitter.git && \
	git clone https://github.com/mfussenegger/nvim-dap.git && \
	git clone https://github.com/rcarriga/nvim-dap-ui.git && \
	git clone https://github.com/theHamsta/nvim-dap-virtual-text.git && \
	git clone https://github.com/ray-x/guihua.lua.git && \
	git clone https://github.com/ray-x/lsp_signature.nvim.git && \
	git clone https://github.com/ray-x/go.nvim.git && \
	git clone https://github.com/neoclide/coc.nvim.git && \
	git clone https://github.com/kyazdani42/nvim-web-devicons.git && \
	git clone https://github.com/kyazdani42/nvim-tree.lua.git && \
	git clone https://github.com/vim-airline/vim-airline.git && \
	git clone https://github.com/vim-airline/vim-airline-themes.git && \
	git clone https://github.com/akinsho/toggleterm.nvim.git && \
	git clone https://github.com/preservim/nerdcommenter.git && \
	git clone https://github.com/tpope/vim-fugitive.git && \
	git clone https://github.com/hashivim/vim-terraform.git && \
	git clone https://github.com/EdenEast/nightfox.nvim.git

RUN zsh -c ". $NVM_DIR/nvm.sh && cd ~/.config/nvim/plugged/coc.nvim && npm ci"

RUN echo ':PlugInstall' > /tmp/gib.txt && \
	echo ':GoUpdateBinaries' > /tmp/gib.txt && \
	echo ':GoUpdateBinaries' > /tmp/gib.txt && \
	echo ':q' >> /tmp/gib.txt && \
	echo ':q' >> /tmp/gib.txt && \
	echo ':q' >> /tmp/gib.txt && \
	zsh -c ". $NVM_DIR/nvm.sh && nvim -s /tmp/gib.txt"

# Copy in final bits for /opt
COPY files/entrypoint.sh /opt/

COPY files/zshrc /home/dev/.zshrc
COPY files/gitconfig /home/dev/.gitconfig
COPY files/tmux.conf /home/dev/.tmux.conf
COPY files/pylintrc /home/dev/.pylintrc

# Switch back to root and setup entrypoint
USER root:root

CMD ["/opt/entrypoint.sh"]
