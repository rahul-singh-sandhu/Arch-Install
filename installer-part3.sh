sudo pacman --noconfirm -S git curl wget
git clone https://aur.archlinux.org/yay && cd yay
makepkg -si && cd ..
rm -rf yay
sudo pacman --noconfirm -S gnome gnome-themes-extra gnome-tweaks flatpak firefox vlc libreoffice-fresh man sway swaybg swaylock waybar blueberry wofi alacritty kitty
git clone https://github.com/ryanoasis/nerd-fonts && cd nerd-fonts
./install
sudo systemctl enable gdm
wget https://github.com/lassekongo83/adw-gtk3/releases/download/v4.0/adw-gtk3v4-0.tar.xz
tar -xfv adw-gtk3v4-0.tar.xz
mkdir -pv ~/.local/share/themes
cp -r adw-gtk3 ~/.local/share/themes
cp -r adw-gtk3-dark ~/.local/share/themes
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
cd ~/ && mkdir Applications
mkdir Development
echo "Done."
