#!/usr/bin/env zsh
# ~/.zshrc - Zsh configuration for interactive shells

# ======================================================================
# INTERACTIVE SHELL CHECK
# ======================================================================
[[ $- != *i* ]] && return

# ======================================================================
# ENVIRONMENT VARIABLES
# ======================================================================
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='vim'
export VISUAL='vim'

# ======================================================================
# HISTORY CONFIGURATION
# ======================================================================
HISTSIZE=50000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS     # Remove older duplicate entries from history
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks from history items
setopt HIST_VERIFY              # Don't execute immediately upon history expansion
setopt SHARE_HISTORY            # Share history between all sessions
setopt EXTENDED_HISTORY         # Record timestamp of command in HISTFILE
setopt HIST_IGNORE_SPACE        # Don't record commands starting with space
setopt INC_APPEND_HISTORY       # Write to history file immediately

# ======================================================================
# ZSH OPTIONS
# ======================================================================
setopt AUTO_CD              # Auto cd when typing directory name
setopt AUTO_PUSHD           # Push old directory onto stack on cd
setopt PUSHD_IGNORE_DUPS    # Don't push multiple copies
setopt PUSHD_SILENT         # Don't print directory stack
setopt CORRECT              # Spelling correction for commands
setopt EXTENDED_GLOB        # Extended globbing features
setopt NO_BEEP              # Disable beep on error
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell

# ======================================================================
# ZSH COMPLETION SYSTEM
# ======================================================================
autoload -Uz compinit
compinit

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' squeeze-slashes true

# Cache completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# ======================================================================
# KEY BINDINGS
# ======================================================================
# Use emacs keybindings
bindkey -e

# Better history navigation
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search    # Up arrow
bindkey "^[[B" down-line-or-beginning-search  # Down arrow
bindkey "^P" up-line-or-beginning-search
bindkey "^N" down-line-or-beginning-search

# Other useful bindings
bindkey "^[[H" beginning-of-line  # Home
bindkey "^[[F" end-of-line        # End
bindkey "^[[3~" delete-char       # Delete
bindkey "^[[1;5C" forward-word    # Ctrl+Right
bindkey "^[[1;5D" backward-word   # Ctrl+Left

# ======================================================================
# COLOR SUPPORT
# ======================================================================
if [[ -x /usr/bin/dircolors ]]; then
    if [[ -r ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi

[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# ======================================================================
# TOOL INTEGRATIONS
# ======================================================================

# Node Version Manager
if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

# Rust/Cargo
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Zoxide - Smarter cd
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias cdi='zi'

    # Override cd to use zoxide when appropriate
    cd() {
        if [[ $# -eq 0 ]]; then
            builtin cd ~
        elif [[ $# -eq 1 ]] && zoxide query -- "$1" &>/dev/null; then
            builtin cd "$(zoxide query -- "$1")"
        else
            builtin cd "$@"
        fi
    }
fi

# FZF - Fuzzy Finder
if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh

    export FZF_DEFAULT_OPTS="
        --height 40%
        --layout=reverse
        --border
        --inline-info
        --color=fg:#e0e0e0,bg:#1a1a2e,hl:#3282b8
        --color=fg+:#ffffff,bg+:#16213e,hl+:#00d9ff
        --color=info:#a8a8a8,prompt:#3282b8,pointer:#00d9ff
        --color=marker:#00d9ff,spinner:#3282b8,header:#3282b8
    "

    # Use fd if available for better performance
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
fi

# TheFuck - Command corrector
if command -v thefuck &>/dev/null; then
    eval "$(thefuck --alias)"
    eval "$(thefuck --alias f)"
fi

# Starship Prompt
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ======================================================================
# SSH AGENT MANAGEMENT
# ======================================================================
_ssh_agent_env="$HOME/.ssh/agent-environment"

_start_ssh_agent() {
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "$_ssh_agent_env"
    chmod 600 "$_ssh_agent_env"
    source "$_ssh_agent_env" &>/dev/null
}

if [[ -f "$_ssh_agent_env" ]]; then
    source "$_ssh_agent_env" &>/dev/null
    ps -p "$SSH_AGENT_PID" 2>/dev/null | grep -q ssh-agent || _start_ssh_agent
else
    _start_ssh_agent
fi

# ======================================================================
# ALIASES
# ======================================================================
if [[ -f ~/.zsh_aliases ]]; then
    source ~/.zsh_aliases
fi

# ======================================================================
# FUNCTIONS
# ======================================================================
if [[ -f ~/.zsh_functions ]]; then
    source ~/.zsh_functions
fi

# Show welcome message on shell start
_welcome_bar

# ======================================================================
# LOCAL OVERRIDES
# ======================================================================
# Source local zshrc if it exists (for machine-specific configs)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
