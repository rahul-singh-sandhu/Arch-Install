echo "Please enter your root password: "
read rootPassword
echo "Please enter your username to be created: "
read sudo_userUsername
echo "Please enter your username's password: "
read sudo_userPasswd
echo "Please enter your hostname: "
read machinehostname
echo "Please enter your keymap: "
read keymap
echo "Please enter your disk identifier:"
read disk
echo "Please enter your timezone region: "
read region
echo "Please enter your timezone zone: "
read zone
echo "Please enter your UTF-8 locale: "
read LOCALE_UTF8

echo -en "$rootPassword\n$rootPassword" | passwd
useradd -mG wheel $sudo_userUsername
sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//' /etc/sudoers
echo -en "$sudo_userPasswd\n$sudo_userPasswd" | passwd $sudo_userUsername
echo $machinehostname > /etc/hostname

sed "/$LOCALE_UTF8/s/^#//g" -i /etc/locale.gen
locale-gen
echo -en LANG=$LOCALE_UTF8 > testfile
ln -sf /usr/share/zoneinfo/$region/$zone /etc/localtime
hwclock --systohc
echo -en "127.0.0.1 localhost" >> /etc/hosts
echo -en "::1 localhost" >> /etc/hosts
echo -en "127.0.1.1 ${machinehostname}.localdomain $machinehostname"
echo -en "KEYMAP=${keymap}" > /etc/vconsole.conf

cp /root/mkinitcpio.conf /etc/mkinitcpio.conf
mkinitcpio -P

pacman --noconfirm -S zsh networkmanager dialog wpa_supplicant mtools dosfstools git xdg-utils xdg-user-dirs alsa-utils pipewire pipewire-alsa pipewire-pulse btop neofetch htop exa bat procs duf fd ripgrep bluez bluez-utils cups hplip network-manager-applet

systemctl enable NetworkManager bluetooth cups
bootctl --path=/boot install
disk_uuid=$(blkid -s UUID -o value ${disk}p3)
echo "title Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo -en "options rd.luks.name=$disk_uuid=luks root=/dev/mapper/luks rootflags=subvol=@ rd.luks.options=$disk_uuid=discard rw"
sed "/timeout/s/^#//g" -i /boot/loader/loader.conf
sed -i '1s/^/default arch.conf\n/' /boot/loader/loader.conf
exit

