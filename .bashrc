[[ $- == *i* ]] || return
[[ -r /etc/bashrc ]] && source /etc/bashrc

case ":$PATH:" in
    *":$HOME/bin:"*) ;;
    *) PATH="$HOME/bin:$PATH" ;;
esac
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH

shopt -s cdspell globstar histappend

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:ignorespace

case ${PROMPT_COMMAND-} in
    *'history -a; history -n'*) ;;
    *) PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac

PS1='\[\e[38;5;249m\]\u@\h\[\e[0m\]:\[\e[38;5;111m\]\w\[\e[0m\]\$ '

umask 022
export EDITOR=nvim
export VISUAL=nvim

[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias tree='tree -C'

alias ..='cd ..'
alias ...='cd ../..'
alias du='du -h'
alias df='df -h'
alias l='ls -lh'
alias la='ls -Alh'
alias c='clear'

alias phonewifi="nmcli connection up id 'phone'"
alias homewifi="nmcli connection up id 'Mohsen'"

proxy() {
    local proxy_http='http://127.0.0.1:12334'
    local proxy_socks='socks5h://127.0.0.1:12334'

    export http_proxy="$proxy_http"
    export https_proxy="$proxy_http"
    export all_proxy="$proxy_socks"
    export HTTP_PROXY="$http_proxy"
    export HTTPS_PROXY="$https_proxy"
    export ALL_PROXY="$all_proxy"

    export no_proxy='localhost,127.0.0.1,::1,10.0.0.0/8,192.168.0.0/16'
    export NO_PROXY="$no_proxy"
}

noproxy() {
    unset http_proxy https_proxy all_proxy no_proxy \
          HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
}

myip() {
    curl -4 -fsS --connect-timeout 3 --max-time 5 \
        https://ipv4.icanhazip.com
}

mypath() {
    printf '%s\n' "${PATH//:/$'\n'}"
}
