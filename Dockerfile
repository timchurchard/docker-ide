#
#
#
FROM amd64/debian:9-slim as builder

# vim git repo commit or tag
ENV VIM_COMMIT=v8.2.2558

# python tgz (tested with 3.8)
ENV PYTHON_URL=https://github.com/deadsnakes/python3.8/archive/upstream/3.8.8.tar.gz
ENV PYTHON_SHA256=a0a80a1f6c7018b1b665052249db1d7b457cd5cb0b4d74ec1f53a400a6747e12

# golang binaries
ENV GOLANG_URL=https://golang.org/dl/go1.15.8.linux-amd64.tar.gz
ENV GOLANG_SHA256=d3379c32a90fdf9382166f8f48034c459a8cc433730bc9476d39d9082c94583b

# github cli
ENV GITHUB_URL=https://github.com/cli/cli/releases/download/v1.6.2/gh_1.6.2_linux_amd64.tar.gz
ENV GITHUB_SHA256=f7d858ff84b2f60793a989399ec12d0d7d8067192e87cf59bd74b1196ac0f5fa

# make -j $WORKERS
ENV WORKERS=4

ENV GOROOT=/opt/go

WORKDIR /tmp

RUN apt-get update -y && \
    apt-get install -y git wget \
                       ncurses-dev \
                       zlib1g-dev libssl-dev \
                       build-essential

# Build and install vim in /opt
RUN git clone https://github.com/vim/vim.git && \
    cd vim && \
    git reset --hard ${VIM_COMMIT} && \
    ./configure --prefix=/opt \
                --enable-python3interp=yes && \
    make -j ${WORKERS} && make install

# Build and install python in /opt
RUN wget -q -O python.tgz ${PYTHON_URL} && \
		mkdir python && \
    echo "$PYTHON_SHA256 python.tgz" > python.tgz.sha256 && \
    sha256sum --check python.tgz.sha256 && \
    tar zxf python.tgz -C ./python --strip-components 1 && \
    cd python && \
    ./configure --prefix=/opt \
                --enable-optimizations \
								--with-system-ffi && \
    make -j ${WORKERS} && make install

# Install golang
RUN wget -q -O golang.tgz ${GOLANG_URL} && \
    echo "$GOLANG_SHA256 golang.tgz" > golang.tgz.sha256 && \
    sha256sum --check golang.tgz.sha256 && \
    tar -C /opt -zxf golang.tgz

# Install go tools
RUN GO111MODULE=on /opt/go/bin/go get mvdan.cc/gofumpt

# Install github cli
RUN wget -q -O github.tgz ${GITHUB_URL} && \
		echo "$GITHUB_SHA256 github.tgz" > github.tgz.sha256 && \
    sha256sum --check github.tgz.sha256 && \
    tar -C /opt -zxf github.tgz

# Grab the oh-my-zsh files (no releases so we'll use top of master)
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git /opt/ohmyzsh.git

# Build python venv used by vim (for pylint etc)
COPY vim_py_reqs.txt /opt/
RUN /opt/bin/python3 -mvenv /opt/venv && \
    /opt/venv/bin/python3 -mpip install -U pip setuptools && \
    /opt/venv/bin/pip3 install -r /opt/vim_py_reqs.txt

# Copy in final bits for /opt
COPY entrypoint.sh /opt/
COPY vim-files /opt/vim-files
COPY scripts /opt/scripts

#
# Start on the final image
#
FROM amd64/debian:9-slim

COPY --from=builder /opt /opt

RUN mkdir /workspace && \
    apt-get update -y && \
    apt-get install -y sudo git curl zsh tmux gosu \
                       locales \
                       openssh-client

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

# Setup oh-my-zsh
RUN ln -sf /opt/ohmyzsh.git /home/dev/.oh-my-zsh

# Setup vim autoload/bundle
RUN mkdir /home/dev/.vim && \
    ln -sf /opt/vim-files/autoload /home/dev/.vim/autoload && \
    ln -sf /opt/vim-files/bundle /home/dev/.vim/bundle

# Copy in user files
COPY vimrc /home/dev/.vim/
COPY zshrc /home/dev/.zshrc
COPY gitconfig /home/dev/.gitconfig
COPY tmux.conf /home/dev/.tmux.conf
COPY pylintrc /home/dev/.pylintrc

# Install vim-go binaries
RUN echo ':GoInstallBinaries' > /tmp/gib.txt && \
    echo ':q' >> /tmp/gib.txt && \
    gosu dev sh -c "PATH=$PATH:/opt/go/bin GOROOT=/opt/go /opt/bin/vim -s /tmp/gib.txt" /dev/null /dev/null

# Default command, can be overridden
CMD ["/opt/entrypoint.sh"]
