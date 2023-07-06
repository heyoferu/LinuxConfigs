#!/bin/bash
# colors (installer ux)
#!/bin/bash

# Colores de texto
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Estilos de texto
BOLD='\033[1m'
UNDERLINE='\033[4m'
INVERSE='\033[7m'

# Colores de fondo
BG_BLACK='\033[0;40m'
BG_RED='\033[0;41m'
BG_GREEN='\033[0;42m'
BG_YELLOW='\033[0;43m'
BG_BLUE='\033[0;44m'
BG_MAGENTA='\033[0;45m'
BG_CYAN='\033[0;46m'
BG_WHITE='\033[0;47m'

# Color sin formato
NC='\033[0m'

    
echo -e "${BLUE}  █████╗ ██████╗  ██████╗██╗  ██╗██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗        ${NC}";
echo -e "${BLUE} ██╔══██╗██╔══██╗██╔════╝██║  ██║██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║        ${NC}";
echo -e "${BLUE} ███████║██████╔╝██║     ███████║██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║        ${NC}";
echo -e "${BLUE} ██╔══██║██╔══██╗██║     ██╔══██║██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║        ${NC}";
echo -e "${BLUE} ██║  ██║██║  ██║╚██████╗██║  ██║██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗   ${NC}";
echo -e "${BLUE} ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝   ${NC}";
                                                                                      
sleep 2

# CONFIGURACIÓN DE IDIOMA
echo "Selecione su idioma de preferencia"

read -p "$(echo -e "Idioma:\n1. Español(MX) \n2. English(US)\nEscriba 1 o 2 y presione Enter: ")" lang

while [ "$lang" -ne 1 ] && [ "$lang" -ne 2 ]; do
    echo -e "ADVERTENCIA!!\nSeleccione unicamente 1 o 2"
    read -p "$(echo -e "Idioma:\n1. Spanish(es) \n2. English(us)\nEscriba 1 o 2 y presione Enter: ")" lang
done
echo ""
echo "Idioma seleccionado: $lang"
sleep 2
clear

if [ $lang == "1" ]
then
    # CONFIGURACIÓN EN ESPAÑOL
    clear
    echo ""
    echo "Configurando el idioma a Español..."
    echo ""
    echo "es_MX.UTF-8 UTF-8" > /etc/locale.gen
    locale-gen
    echo "LANG=es_MX.UTF-8" > /etc/locale.conf
    export LANG=es_MX.UTF-8
    echo ""
    sleep 2

fi

if [ $lang == "2" ]
then
    # CONFIGURACIÓN EN INGLÉS
    clear
    echo ""
    echo "Configurando el idioma a Inglés..."
    echo ""
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    export LANG=en_US.UTF-8
    echo ""
    sleep 2

fi


# KEYRINGS AND MIRRORLIST
clear
pacman -Sy archlinux-keyring --noconfirm 
clear
pacman -Sy reflector python rsync --noconfirm 
clear
echo ""
echo "Actualizando MirrorList..."
echo ""
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
clear
cat /etc/pacman.d/mirrorlist
clear

# user && password
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
echo "print devices" | parted | grep /dev/ | awk '{if (NR!=1) {print}}'
echo ''
read -p "$(echo -e "\e[96mIntroduce tu disco a instalar Arch: \e[0m")" disco
echo ""
read -p "$(echo -e "\e[92mIntroduce NOMBRE DEL EQUIPO (host): \e[0m")" hostname
echo ""
read -p "$(echo -e "\e[92mIntroduce Nombre de USUARIO Nuevo: \e[0m")" user
echo ""
read -p "$(echo -e "\e[91mIntroduce la CLAVE de $user: \e[0m")" userpasswd
echo ""
read -p "$(echo -e "\e[96mIntroduce tu ubicación, Ejemplo (es_PE.UTF-8 / es_MX.UTF-8 / es_AR.UTF-8): \e[0m")" userpais
echo ""
read -p "$(echo -e "\e[96mIntroduce la distribucion de tu teclado, Ejemplo (es / latam / us): \e[0m")" teclado
echo ""
echo "Selección de Disco: $disco"
echo ''
echo "USUARIO: $user"
echo ''
echo "CLAVE DE USUARIO: $userpasswd"
echo ''
sleep 2
echo ''
clear
echo "Sistema UEFI"
echo ""
#---METODO CON EFI - SWAP - ROOT-----------------------------------
sgdisk --zap-all ${disco}
parted ${disco} mklabel gpt
sgdisk ${disco} -n=1:0:+300M -t=1:ef00
sgdisk ${disco} -n=2:0:0
echo ""
sleep 2


echo "$(ls ${disco}* | sed -n "2p")" > boot-efi
echo "$(ls ${disco}* | sed -n "3p")" > root-efi

echo ""
echo "Partición EFI es:" 
cat boot-efi
echo ""
echo "Partición ROOT es:"
cat root-efi
echo ""
sleep 5

clear
echo ""
echo "Formateando Particiones"
echo ""
mkfs.btrfs -f -L "root" -n 32k $(cat root-efi) 
mount $(cat root-efi) /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@var_tmp
btrfs subvolume create /mnt/@snapshots
btrfs subvolume list -p /mnt

mount -o noatime,compress=lzo,space_cache,subvol=@ $(cat root-efi)
mkdir -p /mnt/{boot,home,var/{log,tmp},.snapshots} 

mount -o noatime,compress=lzo,space_cache,subvol=@home $(cat root-efi) /mnt/home
mount -o noatime,compress=lzo,space_cache,subvol=@var_log $(cat root-efi) /mnt/var/log
mount -o noatime,compress=lzo,space_cache,subvol=@var_tmp $(cat root-efi) /mnt/var/tmp
mount -o noatime,compress=lzo,space_cache,subvol=@snapshots $(cat root-efi) /mnt/.snapshots
 
btrfs subvolume list -p /mnt
mount -o noatime,compress=lzo,space_cache,subvol=@ $(cat root-efi)

mkdir -p /mnt/efi 
mkfs.fat -F 32 $(cat boot-efi) 
mount $(cat boot-efi) /mnt/efi 

clear
echo ""
echo "Revise en punto de montaje en MOUNTPOINT"
echo ""
lsblk -l
sleep 2

echo ""
echo "Instalando Sistema base"
echo ""
pacstrap /mnt base base-devel nano reflector python rsync zsh
clear

echo ""
echo "Actualizando lista de MirrorList"
echo ""
arch-chroot /mnt /bin/bash -c "reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist"
clear
cat /mnt/etc/pacman.d/mirrorlist
sleep 1
clear

echo ""
echo "Archivo FSTAB"
echo ""
echo "genfstab -U -p /mnt >> /mnt/etc/fstab"
echo ""

genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 1
clear

#CONFIGURANDO PACMAN
sed -i 's/#Color/Color/g' /mnt/etc/pacman.conf
sed -i 's/#TotalDownload/TotalDownload/g' /mnt/etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/g' /mnt/etc/pacman.conf

sed -i "37i ILoveCandy" /mnt/etc/pacman.conf

sed -i '93d' /mnt/etc/pacman.conf
sed -i '94d' /mnt/etc/pacman.conf
sed -i "93i [multilib]" /mnt/etc/pacman.conf
sed -i "94i Include = /etc/pacman.d/mirrorlist" /mnt/etc/pacman.conf
clear

#HOST
clear
#NOMBRE DEL COMPUTADOR
echo "$hostname" > /mnt/etc/hostname
echo "127.0.1.1 $hostname.localdomain $hostname" > /mnt/etc/hosts
clear
echo "Hostname: $(cat /mnt/etc/hostname)"
echo ""
echo "Hosts: $(cat /mnt/etc/hosts)"
echo ""
clear

#USUARIO Y ADMIN
arch-chroot /mnt /bin/bash -c "(echo $rootpasswd ; echo $userpasswd) | passwd root"
arch-chroot /mnt /bin/bash -c "useradd -m -g users -G wheel -s /bin/zsh $user"
arch-chroot /mnt /bin/bash -c "(echo $userpasswd ; echo $userpasswd) | passwd $user"

sed -i "82c %wheel ALL=(ALL) NOPASSWD: ALL"  /mnt/etc/sudoers

#ACTUALIZACIÓN DE IDIOMA Y ZONA HORARIA
echo "" 
echo -e ""
echo -e "\t\t\t| Actualizando Idioma del Sistema |"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
echo -e ""

echo "$userpais UTF-8" > /mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen" 
echo "LANG=$userpais" > /mnt/etc/locale.conf
echo ""
cat /mnt/etc/locale.conf 
cat /mnt/etc/locale.gen
sleep 3
echo ""
arch-chroot /mnt /bin/bash -c "export $(cat /mnt/etc/locale.conf)" 
export $(cat /mnt/etc/locale.conf)
arch-chroot /mnt /bin/bash -c "sudo -u $user export $(cat /etc/locale.conf)"
export $(cat /mnt/etc/locale.conf)
sleep 2

clear
arch-chroot /mnt /bin/bash -c "pacman -Sy curl --noconfirm"
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime"

#AJUSTE RELOJ 

arch-chroot /mnt /bin/bash -c "timedatectl set-timezone $(curl https://ipapi.co/timezone)"
arch-chroot /mnt /bin/bash -c "pacman -S ntp --noconfirm"
clear
arch-chroot /mnt /bin/bash -c "ntpd -qg"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"
sleep 2

clear

#INSTALACION DE KERNEL
#arch-chroot /mnt /bin/bash -c "pacman -S linux-lts linux-firmware linux-lts-headers mkinitcpio --noconfirm"
arch-chroot /mnt /bin/bash -c "pacman -S linux linux-firmware linux-headers mkinitcpio --noconfirm"

clear

##INSTALACION DEL GRUB-EFI

arch-chroot /mnt /bin/bash -c "pacman -S grub efibootmgr os-prober dosfstools ntfs-3g --noconfirm"
echo '' 
echo 'Instalando EFI System >> bootx64.efi' 
arch-chroot /mnt /bin/bash -c 'grub-install --target=x86_64-efi --efi-directory=/efi --removable' 
echo '' 
echo 'Instalando UEFI System >> grubx64.efi' 
arch-chroot /mnt /bin/bash -c 'grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Arch'

### ENVIAR PARAMETROS AL GRUB
######
sed -i "6iGRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"" /mnt/etc/default/grub
sed -i "2i GRUB_DISABLE_OS_PROBER=false" /mnt/etc/default/grub
sed -i '7d' /mnt/etc/default/grub
######

echo ''
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
echo '' 
echo 'ls -l /mnt/efi' 
ls -l /mnt/efi 
echo '' 
echo 'Lea bien que no tenga ningún error marcado' 
echo '> Confirme tener las IMG de linux para el arranque' 
echo '> Confirme tener la carpeta de GRUB para el arranque' 
sleep 2

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

#ESTABLECER FORMATO DE TECLADO
clear
        
case $teclado in
 
	latam) teclado_tty="la-latin1"
	;;  
  
	*) teclado_tty=$teclado
	;;
	
esac
 
echo "KEYMAP=$teclado_tty" > /mnt/etc/vconsole.conf
cat /mnt/etc/vconsole.conf 
clear
 
      arch-chroot /mnt /bin/bash -c "localectl --no-convert set-x11-keymap "$teclado"" 
      
      echo -e 'Section "InputClass"' > /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
      echo -e 'Identifier "system-keyboard"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
      echo -e 'MatchIsKeyboard "on"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
      echo -e 'Option "XkbLayout" "'$teclado'"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
      echo -e 'EndSection' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf           
      echo ""
      cat /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
      sleep 2
      clear
      
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

#DESMONTAR Y REINICIAR
umount -R /mnt


