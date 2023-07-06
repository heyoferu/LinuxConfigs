#INSTALACION GNOME MINIMAL
arch-chroot /mnt /bin/bash -c "pacman -S gnome-shell gdm gnome-control-center gnome-backgrounds gnome-disk-utility gnome-terminal nautilus gnome-tweaks  gnome-software gnome-software-packagekit-plugin rtkit polkit-gnome qt5-wayland xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-gnome --noconfirm"
arch-chroot /mnt /bin/bash -c "systemctl enable gdm"
echo "GNOME INSTALADO"
sleep 10
# INSTALACIÓN DE PLASMA
arch-chroot /mnt /bin/bash -c "sudo pacman -S sddm plasma konsole dolphin ark spectacle partitionmanager packagekit-qt5 --noconfirm --needed"
sleep 10
#INSTALACION DE WIFI
arch-chroot /mnt /bin/bash -c "pacman -S dhcpcd networkmanager net-tools ifplugd --noconfirm"

#INSTALACION DE DRIVERS WIFI
arch-chroot /mnt /bin/bash -c "pacman -S wireless_tools wpa_supplicant wireless-regdb --noconfirm"

#INSTALACION DE DRIVERS BLUETOOTH
arch-chroot /mnt /bin/bash -c "pacman -S bluez bluez-utils --noconfirm"

#ACTIVAR SERVICIOS
arch-chroot /mnt /bin/bash -c "systemctl enable dhcpcd NetworkManager ntpd"
arch-chroot /mnt /bin/bash -c "systemctl enable bluetooth.service"

echo "noipv6rs" >> /mnt/etc/dhcpcd.conf
echo "noipv6" >> /mnt/etc/dhcpcd.conf

#SHELL
arch-chroot /mnt /bin/bash -c "pacman -S zsh-autosuggestions zsh-history-substring-search zsh-completions zsh-syntax-highlighting --noconfirm"

#INSTALACION DE SERVIDOR X
arch-chroot /mnt /bin/bash -c "pacman -S xorg-server xorg-apps xorg-xinit --noconfirm"

#UTILIDADES
arch-chroot /mnt /bin/bash -c "pacman -S neofetch p7zip unrar zip unzip gzip bzip2 lzop git wget neofetch lsb-release xdg-user-dirs android-tools android-udev libmtp libcddb gvfs gvfs-afc gvfs-smb gvfs-gphoto2 gvfs-mtp gvfs-goa gvfs-nfs dosfstools jfsutils f2fs-tools btrfs-progs exfat-utils ntfs-3g reiserfsprogs xfsprogs nilfs-utils polkit gpart mtools ffmpeg aom libde265 x265 x264 libmpeg2 xvidcore libtheora libvpx schroedinger sdl gstreamer gst-plugins-bad gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-ugly xine-lib lame --noconfirm"#UTILIDADES

arch-chroot /mnt /bin/bash -c "sudo pacman -S usbutils ntfs-3g flatpak pacman-contrib xdg-user-dirs --noconfirm --needed"
arch-chroot /mnt /bin/bash -c "sudo pacman -S git make gcc curl wget nvtop htop vim fuse less man --noconfirm --needed "


arch-chroot /mnt /bin/bash -c "xdg-user-dirs-update"
clear
echo ""
arch-chroot /mnt /bin/bash -c "ls -l /home/$user"
sleep 2

#AUDIO
arch-chroot /mnt /bin/bash -c "pacman -S pipewire gst-plugin-pipewire pipewire-alsa pipewire-jack pipewire-media-session pipewire-pulse pipewire-zeroconf --noconfirm"

#FONTS (TIPOGRAFIAS)
arch-chroot /mnt /bin/bash -c "pacman -S ttf-dejavu ttf-liberation xorg-fonts-type1 ttf-bitstream-vera gnu-free-fonts --noconfirm"

# INSTALAR PARU	(AUR HELPER)
echo "cd && git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si --noconfirm && cd && rm -rf paru-bin" | arch-chroot /mnt /bin/bash -c "su $user"
sed -i "82c %wheel ALL=(ALL) ALL"  /mnt/etc/sudoers

#INSTALACION DE DRIVERS DE VIDEO

case $(systemd-detect-virt) in
        oracle)
            grafica="virtualbox-guest-utils xf86-video-vmware virtualbox-host-modules-arch mesa"
        ;;
        vmware)
            grafica="xf86-video-vmware xf86-input-vmmouse open-vm-tools net-tools gtkmm mesa"
        ;;
        qemu)
            grafica="spice-vdagent xf86-video-fbdev mesa mesa-libgl qemu-guest-agent"
        ;;
        kvm)
            grafica="spice-vdagent xf86-video-fbdev mesa mesa-libgl qemu-guest-agent"
        ;;
        microsoft)
            grafica="xf86-video-fbdev mesa-libgl"
        ;;
        xen)
            grafica="xf86-video-fbdev mesa-libgl"
        ;;
        *)
            if (lspci | grep VGA | grep "NVIDIA\|nVidia" &>/dev/null); then
                grafica="xf86-video-nouveau mesa lib32-mesa mesa-vdpau libva-mesa-driver"
                
            elif (lspci | grep VGA | grep "Radeon R\|R2/R3/R4/R5" &>/dev/null); then
                grafica="xf86-video-amdgpu mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon mesa-vdpau libva-mesa-driver lib32-mesa-vdpau lib32-libva-mesa-driver libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo opencl-mesa clinfo ocl-icd lib32-ocl-icd opencl-headers"

            elif (lspci | grep VGA | grep "ATI\|AMD/ATI" &>/dev/null); then
                grafica="xf86-video-ati mesa lib32-mesa mesa-vdpau libva-mesa-driver lib32-mesa-vdpau lib32-libva-mesa-driver libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo opencl-mesa clinfo ocl-icd lib32-ocl-icd opencl-headers"

             elif (lspci | grep VGA | grep "Intel" &>/dev/null); then
                grafica="xf86-video-intel vulkan-intel mesa lib32-mesa intel-media-driver libva-intel-driver libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo intel-compute-runtime clinfo ocl-icd lib32-ocl-icd opencl-headers"
                
             else
                grafica="xf86-video-vesa"
            
        fi
        ;;
    esac

arch-chroot /mnt /bin/bash -c "pacman -S $grafica --noconfirm --needed"

clear
arch-chroot /mnt /bin/bash -c "neofetch"
sleep 5
uname -r 
sleep 3
clear 
echo "Arch Linux instalado"
sleep 5
