export PATH=/opt/bin:/opt/go/bin:/opt/venv/bin:$PATH

export ZSH="/home/dev/.oh-my-zsh"

export ZSH_THEME="agnoster"

export DISABLE_AUTO_UPDATE="true"
export DISABLE_UPDATE_PROMPT="true"

export EDITOR="vim"

export GOROOT=/opt/go

plugins=(git history )

source $ZSH/oh-my-zsh.sh

#
# tmux alias from https://gist.github.com/lucaspiller/3377737
#
tm() {
  [[ -z "$1" ]] && { echo "usage: tm <session>" >&2; return 1; }
    tmux has -t $1 && tmux attach -d -t $1 || tmux new -s $1
}

# Source the users extra env
source ~/.env

alias vim='/opt/scripts/runvim.sh'

alias pylint='/opt/venv/bin/pylint --rcfile=/home/dev/.pylintrc'
alias py-fmt='/opt/scripts/py-fmt.sh'

alias gofmt='gofumpt'

