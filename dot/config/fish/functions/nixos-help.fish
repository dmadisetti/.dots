function nixos-help
  # If display is not set up, nixos-help will otherwise crash.
  set help (type -f -p nixos-help)
  nix-shell -p w3m --command "BROWSER=w3m $help"
  echo "see 'dots-help' for more information"
end
