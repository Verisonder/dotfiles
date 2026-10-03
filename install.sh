#!/usr/bin/env bash
# SR dotfiles installer — Fedora + Hyprland (Lua config).
# Installs the packages, links every config into place with GNU Stow and applies a theme.
# Existing files that would be replaced are moved to ~/dotfiles-backup-<time>/ first.
set -e
DOT="$(cd "$(dirname "$0")" && pwd)"
BK="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
PACKAGES=(hypr waybar walker elephant mako kitty fish starship fastfetch wiremix autostart bin fonts)

echo "==> Repositories (Hyprland, Walker)"
sudo dnf copr enable -y sdegler/hyprland
sudo dnf copr enable -y errornointernet/walker

echo "==> Packages"
sudo dnf install -y --skip-unavailable \
    hyprland hyprlock hypridle uwsm xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    waybar mako swaybg kitty fish starship fastfetch stow lua git curl python3 \
    walker elephant elephant-desktopapplications elephant-calc elephant-clipboard elephant-files \
    elephant-menus elephant-providerlist elephant-runner elephant-symbols elephant-websearch \
    wiremix btop cliphist wl-clipboard grim slurp playerctl wireplumber libnotify \
    polkit-kde dolphin kate mpv yaru-icon-theme cargo dbus-devel pkgconf-pkg-config

echo "==> Bluetooth and Wi-Fi panels (built with cargo, takes a few minutes)"
mkdir -p "$HOME/.local/bin"
for t in bluetui wlctl; do
    command -v "$t" > /dev/null || cargo install --locked "$t"
    [ -x "$HOME/.cargo/bin/$t" ] && ln -sf "$HOME/.cargo/bin/$t" "$HOME/.local/bin/$t"
done

echo "==> Omarchy themes and logo font (MIT, github.com/basecamp/omarchy)"
SRC="$HOME/.cache/omarchy-src"
[ -d "$SRC" ] || git clone --depth 1 --branch v3.8.4 https://github.com/basecamp/omarchy.git "$SRC"
mkdir -p "$HOME/.local/share/fonts"
cp "$SRC/config/omarchy.ttf" "$HOME/.local/share/fonts/omarchy.ttf"
cp "$SRC/config/wiremix/wiremix.toml" /dev/null 2>&1 || true

if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "==> JetBrainsMono Nerd Font"
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/jbm.tar.xz" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
    mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNerd"
    tar -xf "$tmp/jbm.tar.xz" -C "$HOME/.local/share/fonts/JetBrainsMonoNerd"
    rm -rf "$tmp"
fi

echo "==> Linking configs"
cd "$DOT"
for pkg in "${PACKAGES[@]}"; do
    while IFS= read -r f; do
        rel="${f#./$pkg/}"
        if [ -e "$HOME/$rel" ] && [ ! -L "$HOME/$rel" ]; then
            mkdir -p "$BK/$(dirname "$rel")"
            mv "$HOME/$rel" "$BK/$rel"
        fi
    done < <(find "./$pkg" -type f)
done
stow --no-folding -d "$DOT" -t "$HOME" "${PACKAGES[@]}"
[ -d "$BK" ] && echo "    replaced files saved in $BK"

fc-cache -f > /dev/null
systemctl --user daemon-reload
elephant service enable 2>/dev/null || true
mkdir -p "$HOME/Pictures/wallpaper" "$HOME/Pictures/ScreenTrash"
fish -c 'set -U fish_greeting' 2>/dev/null || true

echo "==> Login screen (SDDM)"
sudo install -d -o "$USER" -g "$USER" /usr/share/sddm/themes/sr
cp "$DOT"/sddm/sr/* /usr/share/sddm/themes/sr/
f=$(fc-match -f '%{file}' 'JetBrainsMono Nerd Font'); [ -f "$f" ] && cp "$f" /usr/share/sddm/themes/sr/font.ttf
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]
Current=sr
' | sudo tee /etc/sddm.conf.d/zz-sr-theme.conf > /dev/null

echo "==> Theme"
"$HOME/.local/bin/sr-theme-set" "$(cat "$HOME/.config/sr/theme" 2>/dev/null || echo gruvbox)" || true

echo
echo "Done. Log out and pick \"Hyprland (uwsm)\" at the login screen."
