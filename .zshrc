# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
     
# source global shell alias & variables files
[ -f "$XDG_CONFIG_HOME/shell/aliases" ] && source "$XDG_CONFIG_HOME/shell/aliases"
[ -f "$XDG_CONFIG_HOME/shell/vars" ] && source "$XDG_CONFIG_HOME/shell/vars"

# cmp opts
zstyle ':completion:*' menu select # tab opens cmp menu
zstyle ':completion:*' special-dirs true # force . and .. to show in cmp menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33 # colorize cmp menu
#zstyle ':completion:*' file-list true # more detailed list
zstyle ':completion:*' squeeze-slashes false # explicit disable to allow /*/ expansion

# main opts
setopt append_history inc_append_history share_history # better history
# on exit, history appends rather than overwrites; history is appended as soon as cmds executed; history shared across sessions
setopt auto_menu menu_complete # autocmp first menu match
setopt autocd # type a dir to cd
setopt auto_param_slash # when a dir is completed, add a / instead of a trailing space
setopt no_case_glob no_case_match # make cmp case insensitive
setopt globdots # include dotfiles
setopt extended_glob # match ~ # ^
setopt interactive_comments # allow comments in shell
unsetopt prompt_sp # don't autoclean blanklines
stty stop undef # disable accidental ctrl s


zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
zstyle :compinstall filename '/home/archer/.config/zsh/.zshrc'

autoload -Uz compinit
compinit


HISTFILE=~/.config/zsh/.histfile
HISTSIZE=100
SAVEHIST=100

# -e to bind to EMACS mode
bindkey -e
# -v to bind to vim mode (but thit changes ESC and TAB behaviour to break tab completion among other things.
#bindkey -v
HISTCONTROL=ignoreboth # consecutive duplicates & commands starting with space are not saved

# Set up prompt
NEWLINE=$'\n'
PROMPT="${NEWLINE}%K{#2E3440}%F{#E5E9F0}$(date +%_I:%M%P) %K{#3b4252}%F{#ECEFF4} %n %K{#4c566a} %~ %f%k ❯ "
# PROMPT="${NEWLINE}%K{$COL0}%F{$COL1}$(date +%_I:%M%P) %K{$COL0}%F{$COL2} %n %K{$COL3} %~ %f%k ❯ " # pywal colors, from postrun script
echo -e "${NEWLINE}\033[48;2;46;52;64;38;2;216;222;233m $0 \033[0m\033[48;2;59;66;82;38;2;216;222;233m $(uptime -p | cut -c 4-) \033[0m\033[48;2;76;86;106;38;2;216;222;233m $(uname -r) \033[0m"

#PS1='%F{blue}%B%~%b%f %F{green}❯%f '
#precmd () { print -Pn "\e]2;%-3~\a"; }

# Save current directory on shell exit
precmd() {
    echo "$PWD" > /tmp/last_terminal_dir
}

#####################
#####   BIND   #####
#####################
# ^ means ctrl
#bindkey "^i" beginning-of-line   #mixes up with kittys conf saying Ctrl + i means Tab
bindkey "^a" end-of-line
bindkey "^k" kill-line
bindkey "^b" backward-word
bindkey "^w" forward-word
bindkey "^J" history-search-forward
bindkey "^K" history-search-backward
bindkey '^R' fzf-history-widget


#####################
#####  ALIASES  #####
#####################


alias c="clear"
alias v="nvim"
alias f="fff"
alias cat="bat"
alias l="ls -lh --color=auto --group-directories-first"
alias ls="ls -h --color=auto --group-directories-first"
alias la="ls -lah --color=auto --group-directories-first"
alias diff='diff --color=auto'
alias grep="grep --color=auto"
alias ip='ip -c=auto'
alias shell="exec $SHELL -l"
alias fk="sudo !!"
alias mv="mv -i"
alias rm="rm -Iv"
alias df="df -h"
alias du="du -h -d 1"
alias k="killall"
alias p="ps aux | grep $1"
alias zshconf="nvim ~/.zshrc"
alias nvconf="nvim ~/.config/nvim/init.lua"
alias kittyconf="nvim ~/.config/kitty/kitty.conf"
alias picomconf="nvim ~/.config/picom/picom.conf"
#alias aliases="nvim ~/.config/shell/aliases"
alias zshalias="nvim ~/.oh-my-zsh/custom/aliases.zsh"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias wp='feh --bg-scale "$(find ~/dotfiles/wallpapers/ -type f | shuf -n 1)"'
alias i3conf="nvim ~/.config/i3/config"
alias i3statusconf="nvim ~/.config/i3/i3status.conf"
alias polybarconf="nvim ~/.config/polybar/config.ini"
alias launchpoly="~/.config/polybar/launch.sh"
alias zshconf="nvim ~/.config/zsh/.zshrc"
alias hyprconf="nvim ~/.config/hypr/hyprland.conf"
alias tbh="bash ~/dotfiles/.config/scripts/toggle_bluetooth_headsets_OnOff.sh"
alias backupdot="bash ~/dotfiles/.config/scripts/backupdotfiles.sh"
alias backupmusic="bash ~/dotfiles/.config/scripts/backupmusic.sh"
alias backupall="bash ~/dotfiles/.config/scripts/backup.sh" 

