# Some useful aliases.
alias texclean='rm -f *.toc *.aux *.log *.cp *.fn *.tp *.vr *.pg *.ky'
alias clean='echo -n "Really clean this directory?";
	read yorn;
	if test "$yorn" = "y"; then
	   rm -f \#* *~ .*~ *.bak .*.bak  *.tmp .*.tmp core a.out;
	   echo "Cleaned.";
	else
	   echo "Not cleaned.";
	fi'
alias h='history'
alias j="jobs -l"
alias l="ls -la "
alias ll="ls -la"
alias ls="ls -F"
alias pu="pushd"
alias po="popd"

# Personal Aliases
alias startmedia='docker-compose -f ~/docker/docker-compose.yml up -d'
alias stopmedia='docker-compose -f ~/docker/docker-compose.yml down'

alias gitkraken='nohup /usr/bin/gitkraken &'
alias mra='nohup /home/luis/workspace/neptus/neptus mra &'
alias auv='/home/luis/workspace/neptus/neptus'

alias codeD="code -n /home/luis/workspace/dune/dune/"
alias codeH="code -n ~/docker/homeassistant/"

alias lsts_vpn="cd ~/workspace/scripts/feup_vpn/openvpn && sudo openvpn client.conf"

# Personal Paths
export DUNE="/home/luis/workspace/dune/build"
export DUNEC="/home/luis/workspace/dune/dune"
export NEPTUS="/home/luis/workspace/neptus"
export GLUED="/home/luis/workspace/glued"

# Command history for tmux
# avoid duplicates..
export HISTCONTROL=ignoredups:erasedups
# append history entries..
shopt -s histappend
# After each command, save and reload history
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

#
# Csh compatability:
#
alias unsetenv=unset
function setenv () {
  export $1="$2"
}

# Function which adds an alias to the current shell and to
# the ~/.bash_aliases file.
add-alias ()
{
   local name=$1 value="$2"
   echo alias $name=\'$value\' >>~/.bash_aliases
   eval alias $name=\'$value\'
   alias $name
}

# "repeat" command.  Like:
#
#	repeat 10 echo foo
repeat ()
{ 
    local count="$1" i;
    shift;
    for i in $(_seq 1 "$count");
    do
        eval "$@";
    done
}

# Subfunction needed by `repeat'.
_seq ()
{ 
    local lower upper output;
    lower=$1 upper=$2;

    if [ $lower -ge $upper ]; then return; fi
    while [ $lower -lt $upper ];
    do
	echo -n "$lower "
        lower=$(($lower + 1))
    done
    echo "$lower"
}