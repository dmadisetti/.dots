function dots-help
  set -l system "no nix"
  if type -q nix
    test -n "$LIVE" && set system "live" || begin
      uname -a | grep -iq nixos && \
        set system "system" || \
        set system "home";
    end
  end

  set -l display "none"
  type -q xmonad && set display "xmonad"
  type -q sway && set display "sway"
  type -q i3 && set display "i3"
  type -q fbterm && set display "fb"

  set -l keybase "\n\n✗ Keybase is not set up. See the keybase section for more details."
  [ (ls ~/keybase/ | wc -l) -gt 2 ] && set keybase "\n\n✓ Keybase is set up (nice)."

  set -l cachix "\n✗ Cachix is not set up. See the cachix section for more details."
  cat ~/.config/nix/nix.conf | grep -q cachix && set cachix "\n✓ Cachix is set up."

  set -l print "cat $DOTFILES/scripts/messages/help.md"
  if type -q prettyprint
    set print "prettyprint help"
  end
  eval $print | sed "s/{{user}}/$USER/g;
                          s/{{type}}/$system/g;
                          s/{{machine}}/$(hostname)/g;
                          s/{{keybase}}/$keybase/g;
                          s/{{cachix}}/$cachix/g;
                          s/$display/$(echo \u001b\[1m)$display/g;
                          s/{{display}}/$display/g;" | less
end
