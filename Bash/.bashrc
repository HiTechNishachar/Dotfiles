
# Addition to bashrc

# Heavily influenced from
# https://gitlab.com/dwt1/dotfiles/-/blob/master/.bashrc
# https://github.com/ChrisTitusTech/mybash/blob/main/.bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

### EXPORT
export TERM="xterm-256color"                        # getting proper colors
export HISTCONTROL=erasedups:ignoredups:ignorespace # no duplicate entries or spaced commands
export HISTTIMEFORMAT=" %d/%m/%y %T "               # history to show date and time
# export ALTERNATE_EDITOR=""                        	# setting for emacsclient
# export EDITOR="emacsclient -t -a ''"              	# $EDITOR use Emacs in terminal
# export VISUAL="emacsclient -c -a emacs"           	# $VISUAL use Emacs in GUI mode

### SET MANPAGER
### Uncomment only one of these!

### "nvim" as manpager
export MANPAGER="nvim +Man!"

### "less" as manpager
# export MANPAGER="less"

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

### SET VI MODE ###
# Comment this line out to enable default emacs-like bindings
set -o vi
bind -m vi-command 'Control-l: clear-screen'
bind -m vi-insert 'Control-l: clear-screen'

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

### PATH
if [ -d "$HOME/.bin" ]; then
	PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
	PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.cargo/bin" ]; then
	PATH="$HOME/.cargo/bin:$PATH"
fi

# if [ -d "$HOME/.emacs.d/bin" ] ;
#   then PATH="$HOME/.emacs.d/bin:$PATH"
# fi

# if [ -d "$HOME/Applications" ] ;
#   then PATH="$HOME/Applications:$PATH"
# fi

if [ -d "/var/lib/flatpak/exports/bin/" ]; then
	PATH="/var/lib/flatpak/exports/bin/:$PATH"
fi

if [ -d "/.local/share/flatpak/exports/bin" ]; then
	PATH="/.local/share/flatpak/exports/bin:$PATH"
fi

# if [ -d "$HOME/.config/emacs/bin/" ] ;
#   then PATH="$HOME/.config/emacs/bin/:$PATH"
# fi

# export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin:/var/lib/flatpak/exports/bin:/.local/share/flatpak/exports/bin"

#ignore upper and lowercase when TAB completion
bind "set completion-ignore-case on"

### COUNTDOWN

cdown() {
	N=$1
	while [[ $((--N)) > 0 ]]; do
		echo "$N" | figlet -c | lolcat && sleep 1
	done
}

### ARCHIVE EXTRACTION
# usage: ex <file>
ex() {
	if [ -f "$1" ]; then
		case $1 in
		*.tar.bz2) tar xjf $1 ;;
		*.tar.gz) tar xzf $1 ;;
		*.bz2) bunzip2 $1 ;;
		*.rar) unrar x $1 ;;
		*.gz) gunzip $1 ;;
		*.tar) tar xf $1 ;;
		*.tbz2) tar xjf $1 ;;
		*.tgz) tar xzf $1 ;;
		*.zip) unzip $1 ;;
		*.Z) uncompress $1 ;;
		*.7z) 7z x $1 ;;
		*.deb) ar x $1 ;;
		*.tar.xz) tar xf $1 ;;
		*.tar.zst) unzstd $1 ;;
		*) echo "'$1' cannot be extracted via ex()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

cpg() {
	if [ -d "$2" ]; then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
mvg() {
	if [ -d "$2" ]; then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
mkdirg() {
	mkdir -p "$1"
	cd "$1"
}

# Show the current distribution
distribution() {
	local dtype
	# Assume unknown
	dtype="unknown"

	# First test against Fedora / RHEL / CentOS / generic Redhat derivative
	if [ -r /etc/rc.d/init.d/functions ]; then
		source /etc/rc.d/init.d/functions
		[ zz$(type -t passed 2>/dev/null) == "zzfunction" ] && dtype="redhat"

	# Then test against SUSE (must be after Redhat,
	# I've seen rc.status on Ubuntu I think? TODO: Recheck that)
	elif [ -r /etc/rc.status ]; then
		source /etc/rc.status
		[ zz$(type -t rc_reset 2>/dev/null) == "zzfunction" ] && dtype="suse"

	# Then test against Debian, Ubuntu and friends
	elif [ -r /lib/lsb/init-functions ]; then
		source /lib/lsb/init-functions
		[ zz$(type -t log_begin_msg 2>/dev/null) == "zzfunction" ] && dtype="debian"

	# Then test against Gentoo
	elif [ -r /etc/init.d/functions.sh ]; then
		source /etc/init.d/functions.sh
		[ zz$(type -t ebegin 2>/dev/null) == "zzfunction" ] && dtype="gentoo"

	# For Mandriva we currently just test if /etc/mandriva-release exists
	# and isn't empty (TODO: Find a better way :)
	elif [ -s /etc/mandriva-release ]; then
		dtype="mandriva"

	# For Slackware we currently just test if /etc/slackware-version exists
	elif [ -s /etc/slackware-version ]; then
		dtype="slackware"

	fi
	echo $dtype
}

# Show the current version of the operating system
ver() {
	local dtype
	dtype=$(distribution)

	if [ $dtype == "redhat" ]; then
		if [ -s /etc/redhat-release ]; then
			cat /etc/redhat-release && uname -a
		else
			cat /etc/issue && uname -a
		fi
	elif [ $dtype == "suse" ]; then
		cat /etc/SuSE-release
	elif [ $dtype == "debian" ]; then
		lsb_release -a
		# sudo cat /etc/issue && sudo cat /etc/issue.net && sudo cat /etc/lsb_release && sudo cat /etc/os-release # Linux Mint option 2
	elif [ $dtype == "gentoo" ]; then
		cat /etc/gentoo-release
	elif [ $dtype == "mandriva" ]; then
		cat /etc/mandriva-release
	elif [ $dtype == "slackware" ]; then
		cat /etc/slackware-version
	else
		if [ -s /etc/issue ]; then
			cat /etc/issue
		else
			echo "Error: Unknown distribution"
			exit 1
		fi
	fi
}

#Variables
#History

# Install Starship - curl -sS https://starship.rs/install.sh | sh

eval "$(starship init bash)"

#Autojump

if [ -f "/usr/share/autojump/autojump.sh" ]; then
	. /usr/share/autojump/autojump.sh
elif [ -f "/usr/share/autojump/autojump.bash" ]; then
	. /usr/share/autojump/autojump.bash
else
	echo "can't found the autojump script"
fi

### ALIASES ###
# navigation
up() {
	local d=""
	local limit="$1"

	# Default to limit of 1
	if [ -z "$limit" ] || [ "$limit" -le 0 ]; then
		limit=1
	fi

	for ((i = 1; i <= limit; i++)); do
		d="../$d"
	done

	# perform cd. Show error if cd fails
	if ! cd "$d"; then
		echo "Couldn't go up $limit dirs."
	fi
}

# vim and emacs
alias vim="nvim"

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# adding flags
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB

# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# gpg encryption
# verify signature for isos
alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
# receive the key of a developer
alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

# Play audio files in current dir by type
alias playwav='vlc *.wav'
alias playogg='vlc *.ogg'
alias playmp3='vlc *.mp3'

# Play video files in current dir by type
alias playavi='vlc *.avi'
alias playmov='vlc *.mov'
alias playmp4='vlc *.mp4'

# Display image files in current dir by type
alias showjpg='feh *.jpg'
alias showjpeg='feh *.jpeg'
alias showpng='feh *.png'

# Alias's to modified commands
alias cp='cp -i'
alias mv='mv -i'
alias rm="rm -rf"
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 5'
alias less='less -R'
alias cls='clear'
alias multitail='multitail --no-repeat -c'
# multitail displays the bottoms of files and new lines as they are being added
# alias freshclam='sudo freshclam'
# freshclam is a virus database update tool for ClamAV. Options. Freshclam reads its configuration from freshclam.conf
alias vi='nvim'
alias svi='sudo vi'
alias vis='nvim "+set si"'

# cd into the old directory
alias bd='cd "$OLDPWD"'

# Remove a directory and all files
alias rmd='/bin/rm  --recursive --force --verbose '

# Alias's for multiple directory listing commands
alias la='ls -Alh'                # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias lx='ls -lXBh'               # sort by extension
alias lk='ls -lSrh'               # sort by size
alias lc='ls -lcrh'               # sort by change time
alias lu='ls -lurh'               # sort by access time
alias lr='ls -lRh'                # recursive ls
alias lt='ls -ltrh'               # sort by date
alias lm='ls -alh |more'          # pipe through 'more'
alias lw='ls -xAh'                # wide listing format
alias ll='ls -Fls'                # long listing format
alias labc='ls -lap'              #alphabetical sort
alias lf="ls -l | egrep -v '^d'"  # files only
alias ldir="ls -l | egrep '^d'"   # directories only

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Show weather
alias wttr='curl wttr.in/Lucknow?1'

# Edit and source new bashrc
alias ebrc="vim .bashrc && source .bashrc"
alias sbrc="source .bashrc"

# Search command line history
alias h="history | grep "

# Search files in the current folder
alias f="find . | grep "

alias btop='bpytop'

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# Apt alias
alias aptud='sudo apt update '
alias aptug='sudo apt upgrade '
alias apts='apt search '
alias apti='sudo apt install '
alias aptp='sudo apt purge '
alias aptp='sudo apt remove '
alias aptg='sudo apt-get'

# To see if a command is aliased, a file, or a built-in command
alias checkcommand="type -t"

# Show open ports
alias openports='netstat -nape --inet'

# Alias's for safe and forced reboots and shutdown
alias reboot='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'
alias shutdown='sudo shutdown -h now'

# Alias's for graphics and power
# github link for envycontrol https://github.com/bayasdev/envycontrol/releases
alias graphics-integrated='sudo envycontrol -s integrated'
alias graphics-hybrid='sudo envycontrol -s hybrid --rtd3'
alias graphics-nvidia='sudo envycontrol -s nvidia --force-comp --coolbits 24'
alias graphics-reset='sudo envycontrol --reset'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"

alias clickpaste='sleep 3; xdotool type "$(xclip -o -selection clipboard)"'

fastfetch
date "+%d/%B - %r"
