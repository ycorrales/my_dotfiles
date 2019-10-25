if [ -n $BASH_VERSION ]; then
# this is specific to the location of the current version of git, installed by homebrew
[[ $(uname) =~ "Darwin" ]] && \
  git_path="/usr/local/etc/bash_completion.d"

echo ${git_path:=/usr/share/git-core/contrib/completion} > /dev/null

[[ -f $git_path/"git-prompt.sh"  ]]  && source $git_path/"git-prompt.sh"
[[ -f $git_path/"git-completion.bash" ]] && source $git_path/"git-completion.bash"

unset git_path

# remove trailing slash in folder name completation
# bind 'set mark-directories off'
function __my_pwd()
{
  __pwd=$PWD
  [[ "$__pwd" =~ ^"$HOME"(/|$) ]] && __pwd="~${__pwd#$HOME}"
  let WIDTH=${COLUMNS}/3
  while [[ ${#__pwd} -gt $WIDTH && ${__pwd} != ${PWD##*/} ]]; do
    __pwd=${__pwd#*/};
    local PRE='.../'
  done
  echo -en "${PRE:=""}${__pwd}"
}

# indicate a job (for example, vim) has been backgrounded
# If there is a job in the background, display a ✱
__suspended_jobs()
{
  local __sj __msg
  __sj=$(jobs 2>/dev/null | tail -n 1)
  local __msg
  if [[ $__sj == "" ]]; then
    __msg=' '
  else
    __msg='*'
  fi

  printf "%-10s" "$__msg"
}

position_get_cursor_position()
{
    # based on a script from http://invisible-island.net/xterm/xterm.faq.html
    exec < /dev/tty
    oldstty=$(stty -g)
    stty raw -echo min 0
    # on my system, the following line can be replaced by the line below it
    echo -en "\033[6n" > /dev/tty
    # tput u7 > /dev/tty    # when TERM=xterm (and relatives)
    IFS=';' read -r -d R -a pos
    stty $oldstty
    # change from one-based to zero based so they work with: tput cup $row $col
    position_row=$((${pos[0]:2} - 1))    # strip off the esc-[
    position_col=$((${pos[1]} - 1))
}

position_write_end_of_line()
{
    local end_of_line fixed_str
    position_get_cursor_position

    # delete scape characters for count
#    echo ${#1}
#    fixed_str=$(echo -en $1 | sed 's/^[\[[0-9\;]*m//g')
    end_of_line=$((`tput cols`-${1}))
    tput sc                   #Save the cursor position&attributes
    tput cup $position_row $end_of_line
    echo -en $2
    tput rc
}

safe_append_prompt_command() {
  local prompt_re
  # Set OS dependent exact match regular expression
  if [[ ${OSTYPE} == darwin* ]]; then
    # macOS
    prompt_re="[[:<:]]${1}[[:>:]]"
  else
    # Linux, FreeBSD, etc.
    prompt_re="\<${1}\>"
  fi

  if [[ ${PROMPT_COMMAND} =~ ${prompt_re} ]]; then
    return
  elif [[ -z ${PROMPT_COMMAND} ]]; then
    PROMPT_COMMAND="${1}"
  else
    PROMPT_COMMAND="${PROMPT_COMMAND};${1}"
  fi
}

__parse_git_dirty()
{
  local IS_DIRTY=${COLOR_LIGHTGREEN}
  [[ -n  "$(git status -s 2> /dev/null)" ]] && IS_DIRTY=${COLOR_RED}
  echo -e $IS_DIRTY
}

__my_prompt() {
  local last_cmd="$?"
  # unicode "?"
  local fancyx="\342\234\227"
  # unicode "?"
  local checkmark="\342\234\223"
  local PROMPT_SYMBOL='\\$ '
  local logo_ch=''
  if [[ "$OSTYPE" == darwin* ]]; then
    logo_ch='\033[1m  \033[0m'
  elif [[ "$OSTYPE" == linux* ]]; then
    logo_ch=${SINGULARITY_NAME:+'\033[1m\342\223\242  \033[0m'}
    logo_ch=${logo_ch:-${_ALIDOCK_ENV:+'\033[1m\360\237\220\263  \033[0m'}}
    logo_ch=${logo_ch:-'\033[1m\360\237\220\247  \033[0m'}
  fi
  local __ps1_start __ps1_end
  __ps1_start="\[${logo_ch}\]\[${COLOR_LIGHTGREEN}\]\[\u\] [\[${COLOR_YELLOW}\]$(__my_pwd)\[${COLOR_LIGHTGREEN}\]]"
  __ps1_start+="\[$(__suspended_jobs)\]"
  if [[ $last_cmd == "0" ]]; then
    __ps1_start+="\[${COLOR_WHITE}\]($last_cmd) \[${COLOR_LIGHTGREEN}\]${checkmark} \[${COLOR_NONE}\]"
  else
    __ps1_start+="\[${COLOR_WHITE}\]($last_cmd) \[${COLOR_LIGHTRED}\]${fancyx} \[${COLOR_NONE}\]"
  fi
  __ps1_start+="\n"
  __ps1_end="\[${COLOR_LIGHTGREEN}\]${PROMPT_SYMBOL}\[${COLOR_NONE}\]"
  __git_ps1 "$__ps1_start" "$__ps1_end" "\[$(__parse_git_dirty)\](%s)\[${COLOR_NONE}\]"
}

safe_append_prompt_command '__my_prompt'

fi
