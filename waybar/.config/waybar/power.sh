#!/usr/bin/env bash
choice=$(printf 'Lock\nLogout\nSuspend\nReboot\nShutdown' | walker --dmenu)
case "$choice" in
    Lock)     pidof hyprlock || hyprlock ;;
    Logout)   uwsm stop || loginctl terminate-session "$XDG_SESSION_ID" ;;
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
