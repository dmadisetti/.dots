function _home
  if test (count $argv) -eq 1
    cd $argv[1]
  else
    cd $argv[1]/$argv[2]
  end
end
