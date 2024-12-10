if [ "cat /etc/pacman.conf | grep multilib" = "#multilib" ] ; then
    sudo cp /etc/pacman.conf /etc/pacman.conf.bak
    sudo sed -i 's/#\[multilib\]/\[multilib\]/g' /etc/pacman.conf
fi

if [ "cat /etc/pacman.conf | grep Include = /etc/pacman.d/mirrorlist" = "#Include = /etc/pacman.d/mirrorlist
" ] ; then
    sudo cp /etc/pacman.conf /etc/pacman.conf.bak
    sudo sed -i 's/#\[Include = /etc/pacman.d/mirrorlist\]/\[Include = /etc/pacman.d/mirrorlist\]/g' /etc/pacman.conf



fi


echo "You have a backup of your original pacman.conf in /etc/pacman.conf.bak"


if [ 'lspci | lspci -vnn | grep -i "intel" | grep -i "vga"' = "05:00.0 VGA compatible controller [0300]: Intel Corporation DG2 [Arc A770] [8086:56a0] (rev 08) (prog-if 00 [VGA controller])" ] ; then 
    echo "Installing required dependencies for Intel ARC/Xe Dedicated GPUs"
    sudo pacman -Syy intel-compute-runtime intel-media-driver lib32-mesa vulkan-intel lib32-vulkan-intel   
fi
