#!/usr/bin/env bash

THEME="-theme $HOME/.config/rofi/powermenu/powermenu.rasi"

rofi_command="rofi -no-config $THEME -i"


# Options
shutdown="shutdown"
reboot="restart"
lock="lock"
suspend="suspend"
logout="logout"

# Variable passed to rofi
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

chosen="$(echo -e "$options" | $rofi_command -p ">" -dmenu)"
case $chosen in
    $shutdown)
      systemctl poweroff
        ;;
    $reboot)
		  systemctl reboot
        ;;
    $lock)
			betterlockscreen -l
        ;;
    $suspend)
		  systemctl suspend
        ;;
    $logout)
      bspc quit
        ;;
esac
