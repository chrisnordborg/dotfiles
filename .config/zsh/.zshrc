# Base file taken from shiroyasha9 on gihub, or Dreams of Autonomy on Youtube.

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Paths
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
#export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Source/Load NVM
#source $(brew --prefix nvm)/nvm.sh

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found


# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey '^[[Z' autosuggest-accept

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt correct

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias pn='pnpm'
alias c="clear"
alias v="nvim"
alias f="fff"
alias cat="bat"
alias l="ls -lh --color=auto --group-directories-first"
alias ls="ls -h --color=auto --group-directories-first"
alias la="ls -lah --color=auto --group-directories-first"
alias grep="grep --color=auto"
alias shell="exec $SHELL -l"
alias fk="sudo !!"
alias mv="mv -i"
alias rm="rm -Iv"
alias df="df -h"
alias du="du -h -d 1"
alias k="killall"
alias p="ps aux | grep $1"
alias zshsource="source ~/.config/zsh/.zshrc"
alias zshconf="nvim ~/.config/zsh/.zshrc"
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


# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval $(thefuck --alias)

# bun completions
#[ -s "/Users/shiroyasha/.bun/_bun" ] && source "/Users/shiroyasha/.bun/_bun"

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh


#key[F1]        = '^[[[A'
#key[F2]        = '^[[[B'
#key[F3]        = '^[[[C'
#key[F4]        = '^[[[D'
#key[F5]        = '^[[[E'
#key[F6]        = '^[[17~'
#key[F7]        = '^[[18~'
#key[F8]        = '^[[19~'
#key[F9]        = '^[[20~'
#key[F10]       = '^[[21~'
#key[F11]       = '^[[23~'
#key[F12]       = '^[[24~'
#
#key[Shift-F1]  = '^[[25~'
#key[Shift-F2]  = '^[[26~'
#key[Shift-F3]  = '^[[28~'
#key[Shift-F4]  = '^[[29~'
#key[Shift-F5]  = '^[[31~'
#key[Shift-F6]  = '^[[32~'
#key[Shift-F7]  = '^[[33~'
#key[Shift-F8]  = '^[[34~'
#
#key[Insert]    = '^[[2~'
#key[Delete]    = '^[[3~'
#key[Home]      = '^[[1~'
#key[End]       = '^[[4~'
#key[PageUp]    = '^[[5~'
#key[PageDown]  = '^[[6~'
#key[Up]        = '^[[A'
#key[Down]      = '^[[B'
#key[Right]     = '^[[C'
#key[Left]      = '^[[D'
#
#key[Bksp]      = '^?'
#key[Bksp-Alt]  = '^[^?'
#key[Bksp-Ctrl] = '^H'    console only.
#
#key[Esc]       = '^['
#key[Esc-Alt]   = '^[^['
#
#key[Enter]     = '^M'
#key[Enter-Alt] = '^[^M'
#
#key[Tab] = '^I' or '\t' unique form! can be bound, but does# not 'showkey -a'.
#key[Tab-Alt]   = '^[\t'
#
#
#COMBINATIONS USING THE WHITE KEYS:
#
#Anomalies:
#'Ctrl+`' == 'Ctrl+2', and 'Ctrl+1' == '1' in xterm.
#Several 'Ctrl+number' combinations are void at console, but# return codes in xterm. OTOH Ctrl+Bksp returns '^H' at cons#ole, but is identical to plain 'Bksp' in xterm. There are n#o doubt more of these little glitches however, in the main:
#
#White key codes are easy to understand, each of these 'norm#al' printing keys has six forms:
#
#A            = 'a'    (duhhh)
#A-Shift      = 'A'    (who would have guessed?)
#A-Alt        = '^[a'
#A-Ctrl       = '^A'
#A-Alt-Ctrl   = '^[^A'
#A-Alt-Shift  = '^[A'
#A-Ctrl-Shift = '^A'   (Shift has no effect)
#
#Don't forget that:
#
#/-Shift-Ctrl = Bksp      = '^?'
#[-Ctrl       = Esc       = '^['
#M-Ctrl       = Enter     = '^M'
#I-Ctrl       = Tab       = '^I' or '\t'
