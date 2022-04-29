function stop-daemon
  uname -a | grep -iq nixos && {
    echo "nix-daemon should be running on os..."
    exit 1
  }

  set -l tmux (which tmux)
  sudo $tmux kill-session -t nix-daemon;

  # Give it a chance to fail
  sleep 0.1

  # Check if it's running
  sudo $tmux list-sessions | grep -q "nix-daemon:" && \
       echo -e "[\xE2\x9D\x8C] daemon still running?!" || \
       echo -e "[\xE2\x9C\x94] daemon stopped";
end
