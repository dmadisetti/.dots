function start-daemon
  uname -a | grep -iq nixos && {
    echo "nix-daemon should be running on os..."
    exit 1
  }

  set -l tmux (which tmux)
  set -l nix_daemon (which nix-daemon) || { echo "no nix"; exit 1;}
  set -l subs (cat ~/.config/nix/nix.conf | grep "substituters =" | cut -d= -f2)
  set -l start_cmd (echo $nix_daemon --option substituters \"$subs\") 

  sudo $tmux new-session -d -s nix-daemon $start_cmd

  # Give it a chance to fail
  sleep 0.1

  # Check if it's running
  sudo $tmux list-sessions | grep -q "nix-daemon:" && \
       echo -e "[\xE2\x9C\x94] daemon started..." || \
       { echo -e "[\xE2\x9D\x8C] daemon failed..."; exit 1 }
end
