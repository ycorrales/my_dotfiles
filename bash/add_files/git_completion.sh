# this is specific to the location of the current version of git, installed by homebrew
#completion=/usr/local/Cellar/git/2.13.0/etc/bash_completion.d/git-completion.bash
completion=/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
if test -f $completion; then
  source $completion
fi