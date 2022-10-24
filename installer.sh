lsblk
echo "Please enter your drive for installation: "
read drive
echo "Please enter the size of your swap partition in GB: "
read swap
echo "Please enter your luks password: "
read luksPassword

pacman -Sy --needed --noconfirm archlinux-keyring
sgdisk -Z $drive
wipefs -a $drive
sgdisk -o -n 1::+500M -t 1:EF00 -c 1:"boot" -n 2::+${swap}gb -t 2:8200 -c 2:"swap" -n 3::: -t 3:8300 -c 3:"root" -p $drive
mkswap ${drive}p2
swapon ${drive}p2
mkfs.vfat -F32 ${drive}p1
echo -en $luksPassword | cryptsetup -q luksFormat ${drive}p3
echo -en $luksPassword | cryptsetup open ${drive}p3 luks

mkfs.btrfs /dev/mapper/luks
mount /dev/mapper/luks /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
umount /mnt
mount -o noatime,nodiratime,compress=zstd:1,space_cache,ssd,subvol=@ /dev/mapper/luks /mnt
mount -o noatime,nodiratime,compress=zstd:1,space_cache,ssd,subvol=@,clear_cache /dev/mapper/luks /mnt
mkdir -p /mnt/{boot,home}
mount -o noatime,nodiratime,compress=zstd:1,space_cache,ssd,subvol=@home /dev/mapper/luks /mnt/home
mount ${drive}p1 /mnt/boot

pacstrap /mnt linux linux-headers linux-firmware sof-firmware base base-devel btrfs-progs intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab
cp installer-part2.sh /mnt/root/installer-part2.sh
cp mkinitcpio.conf /mnt/root/mkinitcpio.conf

arch-chroot /mnt/ chmod +x /root/installer-part2.sh
arch-chroot /mnt/ ./root/installer-part2.sh

umount -a
