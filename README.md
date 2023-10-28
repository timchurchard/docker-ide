# docker-ide

Portable IDE for golang with neovim, tmux, &amp; zsh in docker.

Based on Ubuntu 22.04 image. Extra tools:
- aws cli v2
- terraform (1.4.5)
- github cli (gh)

**Note** I built a docker image full of useful tools and setup for me. I do not care about size. Be aware the build and final image is large.

## Build

`docker build -t timchurchard/ide .`

## Run

Run the docker container and mount the project to edit onto /workspace.  The entrypoint.sh will attempt to update the built-in user to match the host UID/GID.  The entrypoint will also set git user/pass.  Also it may be convenient to mount ~/.ssh as the openssh-client is installed.

```shell
docker run -it --rm \
    -v $(pwd):/workspace \
    -v ~/.ssh:/home/dev/.ssh \
    -v ~/.$(whoami).env:/home/dev/.env \
    -e HOST_USER_ID=$(id -u $USER) \
    -e HOST_GROUP_ID=$(id -g $USER) \
    -e GIT_USER_NAME="My Name" \
    -e GIT_USER_EMAIL="me@email.com" \
    timchurchard/ide
```

### tmux

tmux is using ctrl+h and vim mode eg ctrl+h h j k l to move between splits.  ctrl+h | or - to split V or H.  ctrl+h H J K L to resize.

### neovim

Neovim is installed with vim-sensible so search with / and gruvbox dark default colorscheme.  .vim-tmp is written to each /workspace for my sanity.

Nerdtree built in using ctrl+n to toggle.

Fugitive using :G and :Git

vim-go is installed with gofumpt as the default formatter.

### golang


