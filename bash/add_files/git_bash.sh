# this is specific to the location of the current version of git, installed by homebrew
git_path="/usr/local/etc/bash_completion.d"
[[ $HOSTNAME =~ $SPHENIX_RCF ]] && \
  git_path=/usr/share/git-core/contrib/completion

[[ -f $git_path/"git-prompt.sh"  ]]  && source $git_path/"git-prompt.sh"
[[ -f $git_path/"git-completion.bash" ]] && source $git_path/"git-completion.bash"

unset git_path
