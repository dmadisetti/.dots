# A hack to have both sub modules and raw content in the monorepo.
function ungit
  find ~/phd/writings -name ".git" -type d -exec mv {} {}.hidden \; 2>/dev/null
  cd ~/phd/
  git status
end

function regit
  find ~/phd/writings -name ".git.hidden" -type d -exec sh -c 'mv "$1" "$(dirname "$1")/.git"' _ {} \; 2>/dev/null
  cd ~/phd/
  git status
end

function phd --wraps='cd ~/phd'
  _home ~/phd $argv
end

complete -f -c phd -a '(_complete ~/phd)'
