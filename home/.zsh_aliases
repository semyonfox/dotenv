# ======================================================================
# ALIASES - NAVIGATION
# ======================================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# ======================================================================
# ALIASES - FILE LISTING
# ======================================================================
# Use eza if available, otherwise fallback to ls
if command -v eza &>/dev/null; then
    alias ls='eza --icons --git'
    alias ll='eza --icons --git -lha'
    alias la='eza --icons --git -a'
    alias l='eza --icons --git'
    alias lt='eza --icons --git -lha --sort=modified'
    alias tree='eza --icons --git --tree'
else
    alias ls='ls --color=auto'
    alias ll='ls -lha --color=auto'
    alias la='ls -A --color=auto'
    alias l='ls -CF --color=auto'
    alias lt='ls -lhtra --color=auto'
    alias tree='tree -C'
fi

# Use bat if available
command -v bat &>/dev/null && alias cat='bat'

# ======================================================================
# ALIASES - UTILITIES
# ======================================================================
alias c='clear'
alias h='history'
alias ports='ss -tulanp'
alias myip='curl -s ifconfig.me'
alias localip="ip -o -4 addr show | awk '{print \$4}' | cut -d/ -f1"
alias df='df -h'
alias du='du -h'
alias update='sudo pacman -Syu'

# Safe operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# App shortcuts
alias todo='dooit'
alias pomodoro='pomodoro-tui'

# ======================================================================
# ALIASES - DOCKER
# ======================================================================
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'
alias dstop='docker stop'
alias drm='docker rm'
alias dprune='docker system prune -af'

# ======================================================================
# ALIASES - GIT
# ======================================================================
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add -p'
alias gb='git branch'
alias gbr='git branch -r'
alias gba='git branch -a'
alias gc='git commit -m'
alias gca='git commit -am'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gl='git log --oneline --graph --decorate'
alias gll='git log --graph --pretty=format:"%C(yellow)%h%C(reset) -%C(auto)%d%C(reset) %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)"'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpo='git push origin'
alias gpu='git push --set-upstream origin'
alias gr='git rebase'
alias gri='git rebase -i'
alias grs='git reset'
alias grh='git reset --hard'
alias gs='git status -sb'
alias gst='git status'
alias gsh='git show'
alias gss='git stash'
alias gsp='git stash pop'
alias gsa='git stash apply'
alias gsl='git stash list'
alias gsu='git submodule update --init --recursive'
alias gt='git tag'
