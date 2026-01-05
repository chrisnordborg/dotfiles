export PATH=/usr/lib/qt6/bin:/usr/lib/qt6/bin:/home/archer/.config/scripts:/usr/local/sbin:/usr/local/bin:/usr/bin:/opt/android-sdk/platform-tools:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
     
# source global shell alias & variables files
#[ -f "$XDG_CONFIG_HOME/shell/aliases" ] && source "$XDG_CONFIG_HOME/shell/aliases"
#[ -f "$XDG_CONFIG_HOME/shell/vars" ] && source "$XDG_CONFIG_HOME/shell/vars"

# cmp opts
zstyle ':completion:*' menu select # tab opens cmp menu
zstyle ':completion:*' special-dirs true # force . and .. to show in cmp menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33 # colorize cmp menu
#zstyle ':completion:*' file-list true # more detailed list
zstyle ':completion:*' squeeze-slashes false # explicit disable to allow /*/ expansion

# main opts
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


# History file location and limits
HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000          # Number of commands kept in memory
SAVEHIST=1000          # Number of commands saved to file
# You may have to run the following to enable saving to the file.
# mkdir -p ~/.config/zsh
# touch ~/.config/zsh/.histfile
# chmod 600 ~/.config/zsh/.histfile

# History behavior options
setopt append_history         # Append to history file instead of overwriting
setopt inc_append_history     # Save each command to the history file immediately
setopt share_history          # Share command history across all zsh sessions
# on exit, history appends rather than overwrites; history is appended as soon as cmds executed; history shared across sessions

# Better filtering and usability
setopt hist_ignore_all_dups   # Remove older duplicate commands
setopt hist_ignore_dups       # Ignore consecutive duplicates
setopt hist_save_no_dups      # Don't write duplicate commands to the file
setopt hist_reduce_blanks     # Remove extra whitespace before saving
setopt hist_ignore_space      # Don't save commands starting with a space
setopt hist_verify            # Show the command before executing when expanded from history


# -e to bind to EMACS mode, and -v to bind to vim mode (but thit changes ESC and TAB behaviour to break tab completion among other things.
bindkey -e
# bind DEL button to delete-char instead of ~
bindkey '\e[3~' delete-char

## Run fastfetch as welcome message
fastfetch

# Set up prompt
# fallback prompt is 'hostname%' in case of something wrong with the statement below.
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
#bindkey '^R' fzf-history-widget

# Load fzf key bindings (Arch Linux default path)
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh

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
alias zshconf="nvim ~/.config/zsh/.zshrc"
#alias zshconf="nvim ~/.zshrc"
#alias zshsource="source ~/.zshrc"
alias zshsource="source ~/.config/zsh/.zshrc"
alias dmconf="nvim ~/dmenu/config.def.h"
alias dmmake="sudo make --directory=/home/archer/dmenu/ clean install"
alias nvimconf="nvim ~/.config/nvim/init.lua"
alias dunstconf="nvim ~/.config/dunst/dunstrc"
alias kittyconf="nvim ~/.config/kitty/kitty.conf"
alias picomconf="nvim ~/.config/picom/picom.conf"
#alias aliases="nvim ~/.config/shell/aliases"
#alias wp='feh --bg-scale "$(find ~/dotfiles/wallpapers/ -type f | shuf -n 1)"'
alias wp="bash ~/dotfiles/.config/scripts/random_wallpaper.sh"
alias i3conf="nvim ~/.config/i3/config"
alias i3statusconf="nvim ~/.config/i3/i3status.conf"
alias polybarconf="nvim ~/.config/polybar/config.ini"
alias launchpoly="~/.config/polybar/launch.sh"
alias hyprconf="nvim ~/.config/hypr/hyprland.conf"
alias mangoconf="nvim ~/.config/mango/config.conf"
alias waybarconf="nvim ~/.config/waybar/config.jsonc"
alias waybarhyprconf="nvim ~/.config/waybar/config_hyprland.jsonc"
alias waybarstyle="nvim ~/.config/waybar/style.css"
alias tbh="bash ~/dotfiles/.config/scripts/toggle_bluetooth_headsets_OnOff.sh"
alias backupdot="bash ~/dotfiles/.config/scripts/backupdotfiles.sh"
alias backupmusic="bash ~/dotfiles/.config/scripts/backupmusic.sh"
alias backupall="bash ~/dotfiles/.config/scripts/backup.sh" 
alias cppoefilter="cp ~/Downloads/*.filter ~/.local/share/Steam/steamapps/compatdata/238960/pfx/drive_c/users/steamuser/My\ Documents/My\ Games/Path\ of\ Exile/"

export QT_QPA_PLATFORM=xcb
