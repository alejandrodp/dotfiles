# PATH custom dirs

export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$PATH:$HOME/.local/bin"

# Virtualenvwrapper things

source /usr/bin/virtualenvwrapper_lazy.sh

# General vars

export DEFAULT_USER=$(whoami)
export EDITOR=nano

terminals=(xterm-kitty)

if [[ -n "$SSH_CLIENT" ]] || 
   [[ -n "$SSH_TTY" ]] && 
   [[ "${terminals[@]}" =~ "$TERM" ]]; then

  export TERM="xterm-256color"

fi

# XDG vars

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

# General config

setopt autocd 
setopt extendedglob 
setopt notify
setopt EXTENDED_HISTORY
setopt GLOB_COMPLETE
setopt SHARE_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt CORRECT
setopt PROMPT_SUBST
setopt ZLE

# Icons set for tty and emulator

GIT_STATUS_INDICATOR=*
PROMPT_ARROW=">"

if [[ $TTY == /dev/pts/* ]] || [[ "$TERM" == "xterm-256color" ]]; then

 GIT_STATUS_INDICATOR=✱
 PROMPT_ARROW=❱

fi

# Completion config

zstyle :compinstall filename '$ZDOTDIR/.zshrc'

autoload -Uz compinit;
compinit
_comp_options+=(globdots)
source $ZDOTDIR/completion.zsh

# GIT config

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )

zstyle ':vcs_info:*' disable bzr cdv darcs mtn svk tla cvs svn
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' stagedstr "%F{green}$GIT_STATUS_INDICATOR%f"
zstyle ':vcs_info:*' unstagedstr "%F{cyan}$GIT_STATUS_INDICATOR%f"
#zstyle ':vcs_info:git:*' formats '%B%F{green}[%b]%%b'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git+set-message:*' hooks format_msg

function +vi-format_msg {

 local status_str=""

 if output=$(git status --porcelain) && [ ! -z "$output" ];
 then

  local sta=${hook_com[staged]}
  local uns=${hook_com[unstaged]}
  local unt=""

  if [[ $(git status --porcelain 2>/dev/null | grep "^??" | wc -l) > 0 ]];
  then

   unt="%F{red}$GIT_STATUS_INDICATOR%f"

  fi

  status_str="%F{green}[$sta$uns$unt%F{green}]%f"
  
 fi

 local module_name=$(git rev-parse --show-superproject-working-tree --show-toplevel | head -1 | {read p; echo ${p##*/}})
 local module_tree=""

 if [[ $module_name != ${hook_com[base-name]} ]];
 then

  module_tree="%F{green}[${module_name}/${hook_com[base-name]}]%f"

 fi

 local branch=$(git branch --show-current)
 
 if [[ -z "$branch" ]] ; then
  branch=$(git rev-parse --short HEAD)
 fi
  
 ret=1
 hook_com[message]="%B$module_tree%F{green}[$branch]$status_str%b"

 return 0
}

# Prompt config

if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    PS1='%B%F{red}[%n@%M]%f%B%F{blue}[%(4~|%-1~/…/%2~|%4~)]%f${vcs_info_msg_0_}%(?.%F{green}.%F{red}[%?])%F{green}%(!.#.${PROMPT_ARROW})%f%b '

else

    PS1='%B%F{blue}[%(4~|%-1~/…/%2~|%4~)]%f${vcs_info_msg_0_}%F{green}%(?.%F{green}.%F{red}[%?])%(!.#.${PROMPT_ARROW})%f%b '
fi

# Widgets binding

bindkey -e

bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^H' backward-delete-word
bindkey '^[[3;5~' delete-word
bindkey '^[[2~' bracketed-paste

# Aliases

alias l="ls --all --color --file-type --human-readable -l -tr"
alias ec="$EDITOR $ZDOTDIR/.zshrc"
alias sc="source $ZDOTDIR/.zshrc"
alias cl="clear"
alias eci3="$EDITOR $XDG_CONFIG_HOME/i3/config"
alias ecpolybar="$EDITOR $XDG_CONFIG_HOME/polybar/config"


# External plugins load

local os_type=$(( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1)

if [[ $os_type == *"Arch Linux"* || $os_type == *"Parabola"* ]]; then

 source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
 source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

fi

if [[ $os_type == *"Ubuntu"* ]]; then

 source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
 source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

fi

# zsh parameter completion for the dotnet CLI

_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  reply=( "${(ps:\n:)completions}" )
}

compctl -K _dotnet_zsh_complete dotnet

# man colored pages

man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

# spawn desktop apps command
spawn () {
        if [ ! -x "$(command -v $1)" ]
        then
                echo "spawn: no such shit: $1" >&2
                return 1
        fi
        $@ > /dev/null 0>&1 2>&1 &
        disown
}
