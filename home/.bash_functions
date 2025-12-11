# ======================================================================
# FUNCTIONS - FILE OPERATIONS
# ======================================================================\n
# Create directory and enter it
mkcd() {
    [[ $# -eq 0 ]] && { echo "Usage: mkcd <directory>"; return 1; }
    mkdir -p "$1" && cd "$1"
}

# Create backup of file
backup() {
    [[ $# -eq 0 ]] && { echo "Usage: backup <file>"; return 1; }
    cp "$1"{,.bak} && echo "Backed up: $1 → $1.bak"
}

# Find files by name
f() {
    [[ $# -eq 0 ]] && { echo "Usage: f <pattern>"; return 1; }
    find . -name "*$1*" 2>/dev/null
}

# Search text in files
ftext() {
    [[ $# -eq 0 ]] && { echo "Usage: ftext <pattern>"; return 1; }
    grep -rnw . -e "$1" 2>/dev/null
}

# Extract various archive formats
extract() {
    [[ $# -eq 0 ]] && { echo "Usage: extract <archive>"; return 1; }
    [[ ! -f "$1" ]] && { echo "Error: '$1' not found"; return 1; }

    case "$1" in
        *.tar.bz2)  tar xjf "$1" ;;
        *.tar.gz)   tar xzf "$1" ;;
        *.tar.xz)   tar xf "$1" ;;
        *.tar.zst)  tar xf "$1" ;;
        *.tar)      tar xf "$1" ;;
        *.tgz)      tar xzf "$1" ;;
        *.bz2)      bunzip2 "$1" ;;
        *.gz)       gunzip "$1" ;;
        *.rar)      unrar x "$1" ;;
        *.zip)      unzip "$1" ;;
        *.7z)       7z x "$1" ;;
        *.deb)      ar x "$1" ;;
        *)          echo "Error: Unsupported format '$1'" ;;
    esac
}

# ====================================================================== 
# FUNCTIONS - SSH
# ====================================================================== 

# Quick SSH connections
sssh() {
    case "$1" in
        server) ssh semyon@server ;;
        nas)     ssh server@nas ;;
        "" )      echo "Usage: sssh <server|hostname>"; return 1 ;; 
        *)       ssh "$1" ;;
    esac
}

# Completion for sssh
_sssh_complete() {
    local hosts custom_hosts
    custom_hosts="server1 server2 nas"
    hosts=$(grep "^Host" ~/.ssh/config 2>/dev/null | grep -v "[?*]" | awk '{print $2}')
    COMPREPLY=($(compgen -W "$hosts $custom_hosts" -- "${COMP_WORDS[COMP_CWORD]}"))
}
complete -F _sssh_complete sssh

# ====================================================================== 
# FUNCTIONS - SYSTEM MAINTENANCE
# ====================================================================== 

# Comprehensive system cleanup for Arch Linux
cleanup() {
    local before after freed

    echo -e "\n\e[96m╭─────────────────────────────────────────────────╮\e[0m"
    echo -e "\e[96m│\e[0m  \e[1;97mSystem Cleanup\e[0m                              \e[96m│\e[0m"
    echo -e "\e[96m╰─────────────────────────────────────────────────╯\e[0m\n"

    before=$(df --output=used / | tail -1 | tr -d ' ')

    echo -e "\e[93m[1/7]\e[0m Clearing pacman cache (keeping last 3)..."
    sudo paccache -rk3 2>/dev/null || sudo pacman -Sc --noconfirm

    echo -e "\e[93m[2/7]\e[0m Removing orphaned packages..."
    if orphans=$(pacman -Qtdq 2>/dev/null); then
        echo "$orphans" | sudo pacman -Rns --noconfirm -
    else
        echo "      No orphaned packages found"
    fi

    echo -e "\e[93m[3/7]\e[0m Clearing yay cache..."
    if command -v yay &>/dev/null; then
        yay -Sc --noconfirm 2>/dev/null
    else
        echo "      yay not installed, skipping"
    fi

    echo -e "\e[93m[4/7]\e[0m Clearing user cache..."
    rm -rf ~/.cache/* 2>/dev/null

    echo -e "\e[93m[5/7]\e[0m Clearing systemd journal (keeping 3 days)..."
    sudo journalctl --vacuum-time=3d 2>/dev/null

    echo -e "\e[93m[6/7]\e[0m Clearing temporary files..."
    sudo rm -rf /tmp/* 2>/dev/null

    echo -e "\e[93m[7/7]\e[0m Clearing thumbnails and trash..."
    rm -rf ~/.thumbnails/* ~/.local/share/Trash/* 2>/dev/null

    after=$(df --output=used / | tail -1 | tr -d ' ')
    freed=$((before - after))

    echo -e "\n\e[96m╭─────────────────────────────────────────────────╮\e[0m"
    echo -e "\e[96m│\e[0m  \e[92mCleanup Complete!\e[0m                           \e[96m│\e[0m"
    if [[ $freed -gt 0 ]]; then
        printf "\e[96m│\e[0m  \e[92mSpace freed: %-33s\e[96m│\e[0m\n" "$(numfmt --to=iec --suffix=B $((freed * 1024)))"
    else
        echo -e "\e[96m│\e[0m  \e[93mSpace freed: 0B (or negligible)\e[0m            \e[96m│\e[0m"
    fi
    echo -e "\e[96m╰─────────────────────────────────────────────────╯\e[0m\n"

    echo -e "\e[93mTop 10 largest directories:\e[0m\n"
    du -h --max-depth=2 ~/ 2>/dev/null | sort -rh | head -11 | tail -10 | nl -w2 -s'. ' 
    echo
}

# ====================================================================== 
# FUNCTIONS - WELCOME MESSAGE
# ====================================================================== 

_welcome_bar() {
    # Get CPU load (1-minute average)
    local cpu_load
    cpu_load=$(cut -d " " -f1 /proc/loadavg)

    # Calculate CPU percentage (assuming 4 cores, adjust as needed)
    local cpu_cores
    cpu_cores=$(nproc)
    local cpu_pct
    cpu_pct=$(awk -v loadavg="$cpu_load" -v cores="$cpu_cores" 'BEGIN {printf "%.0f", (loadavg/cores)*100}')
    [[ $cpu_pct -gt 100 ]] && cpu_pct=100

    # Get memory usage
    local mem_total mem_available mem_used mem_pct
    mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    mem_used=$((mem_total - mem_available))
    mem_pct=$((mem_used * 100 / mem_total))

    # Create progress bars (handle empty/zero values)
    local cpu_filled mem_filled
    cpu_filled=$((cpu_pct / 5))
    mem_filled=$((mem_pct / 5))
    [[ $cpu_filled -lt 1 ]] && cpu_filled=0
    [[ $mem_filled -lt 1 ]] && mem_filled=0

    local cpu_bar cpu_empty mem_bar mem_empty
    cpu_bar=$([ "$cpu_filled" -gt 0 ] && printf "\e[92m%0.s█\e[90m" $(seq 1 "$cpu_filled") || echo "")
    cpu_empty=$(printf "%0.s░" $(seq 1 $((20 - cpu_filled))))
    mem_bar=$([ "$mem_filled" -gt 0 ] && printf "\e[94m%0.s█\e[90m" $(seq 1 "$mem_filled") || echo "")
    mem_empty=$(printf "%0.s░" $(seq 1 $((20 - mem_filled))))

    # Display welcome message
    echo
    echo -e "\e[96m╭─────────────────────────────────────────────────╮\e[0m"
    printf "\e[96m│\e[0m  \e[1;97mWelcome back, %s\e[0m%*s\e[96m│\e[0m\n" "$USER" $((32 - ${#USER})) ""
    echo -e "\e[96m├─────────────────────────────────────────────────┤\e[0m"
    printf "\e[96m│\e[0m  \e[97mCPU\e[0m  [%s%s\e[0m] \e[92m%-4s%%\e[0m       \e[96m│\e[0m\n" "$cpu_bar" "$cpu_empty" "$cpu_pct"
    printf "\e[96m│\e[0m  \e[97mRAM\e[0m  [%s%s\e[0m] \e[94m%-4s%%\e[0m       \e[96m│\e[0m\n" "$mem_bar" "$mem_empty" "$mem_pct"
    echo -e "\e[96m╰─────────────────────────────────────────────────╯\e[0m"
    echo
}
