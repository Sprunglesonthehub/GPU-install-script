INTEL_GPU="Intel Dg2 (Gen12)"

intelgputesting() {
    if lsgpu | grep "$INTEL_GPU" >/dev/null 2>&1; then
        echo "Intel Dg2 (Gen12) GPU detected"
        intel_gpu_present=true  # Declare and assign the variable here
    else
        echo "Intel Dg2 (Gen12) GPU not detected"
        intel_gpu_present=false # Declare and assign the variable here
    fi
}

intelgputesting

echo "I noticed you are on Intel Arc, please wait while I configure your system for you"
echo "Installing Graphics drivers"


if $intel_gpu_present; then
    if [[ $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Ubuntu"* || $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Debian"* || $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Linux Mint"* ]] ; then
        echo "Detected that you are on a Debian-based distribution of some sort, installing packages:"
        if [[ $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Ubuntu" || $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Linux Mint" ]] && $lsb_release -rs == "24.10" ; then
            sudo apt install -y software-properties-common
            sudo add-apt-repository -y ppa:kobuk-team/intel-graphics
            sudo apt install -y libze-intel-gpu1 libze1 intel-ocloc intel-opencl-icd clinfo
            sudo apt install -y intel-media-va-driver-non-free libmfx1 libmfx-gen1.2 libvpl2 libvpl-tools libva-glx2 va-driver-all vainfo
        fi    

        if [[ $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Ubuntu" || $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Linux Mint" ]] && $lsb_release -rs == "24.04" ; then
          echo "Importing Keys"
          wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
          sudo gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg

          echo "Configuring repositories"
          echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble client" | \
          sudo tee /etc/apt/sources.list.d/intel-gpu-noble.list

          echo "Updating Repos"
          sudo apt update

          echo "Installing Intel GPU Drivers"
          sudo apt-get install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo
        fi

        if [[ $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Ubuntu" || $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Linux Mint" ]] && $lsb_release -rs == "22.04" ; then
          echo "Adding Intel GPG Key"
          wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
          sudo gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg

          echo "Setting up Package repository"
          echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy client" | \
          sudo tee /etc/apt/sources.list.d/intel-gpu-jammy.list

          echo "Updating package repositories"
          sudo apt update

          echo "Installing GPU Drivers"
          sudo apt-get install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo
        fi
          
        echo "Installing Required Packages for Intel GPUs"
        sudo apt install -y libigc1 libigdmm-dev libigdfci-dev libva-dev libze-dev intel-ocloc intel-oclock-dev intel-opencl-lcd libze-intel-gpu-dev libze-intel-gpu1 intel-compute-runtime intel-media-driver


        clinfo | grep "Device Name" > verification.txt
        cat verification.txt
    fi

    if [[ $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Arch Linux"* || $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Endeavour OS"* || $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Acreetion Linux"* || $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Manjaro"* ]]; then
        echo "Detected you are on an arch-based/similar distro, installing packages:"
        sudo pacman -Syy intel-media-driver vulkan-intel intel-compute-runtime lib32-mesa --noconfirm
        echo "Setting up GuC/HuC Firmware"
        sudo touch /etc/modprobe.d/i915.conf
        if [ $(cat /etc/modprobe.d/i915.conf) != "options i915 enable_guc=2" ]; then
            sudo echo "options i915 enable_guc=2" >> /etc/modprobe.d/i915.conf
        fi
        sudo mkinitcpio -P
        touch dmesg.txt
        sudo echo dmesg > dmesg.txt
        cat dmesg.txt
        sudo touch /etc/X11/xorg.conf.d/20-intel.conf
        echo "The Xe driver is unstable still, defaulting to i915."
        if [[ $(cat /etc/X11/xorg.conf.d/20-intel.conf) == *"Section \"Device\""* ]]; then
    
                                                         sudo echo "Section \"Device\"
                                                                     Identifier \"Intel Graphics\"
                                                                     Driver \"modesetting\"
                                                                      Option \"TearFree\" \"true\"
                                                                   EndSection" >> /etc/X11/xorg.conf.d/20-intel.conf
        fi
     clinfo | grep "Device Name" > verification.txt
     cat verification.txt 
    fi
    if [[ $(cat /etc/*release | grep -w NAME | cut -d= -f2 | tr -d '\"') == *"Fedora"* ]]; then
        echo "Detected you are on a fedora-based/similar distro, enabling RPM Fusion so I can pull the latest intel drivers, this will include nonfree firmware:"
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm -y
        sudo dnf groupupdate core -y
        sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
        sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
        sudo dnf install intel-media-driver -y
        echo "Installing other required firmware and packages:"
        sudo dnf install rpmfusion-nonfree-release-tainted -y
        sudo dnf --repo=rpmfusion-nonfree-tainted install "*-firmware" -y
        sudo dnf install intel-media-driver intel-level-zero intel-ocloc intel-ocloc-devel intel-opencl -y
     clinfo | grep "Device Name" > verification.txt
     cat verification.txt 
    fi
  echo "There is a file named verification.txt, please check it for the name of your GPU"
fi

AMD_GPU="lspci -v | grep -i "VGA" | awk '/VGA compatible controller:/{print $NF}' | xargs lshw -c video -C"
AMD_PRO_GPU="lspci -v | grep -i "VGA" | awk '/VGA compatible controller:/{print $NF}' | xargs lshw -c video -C"

amdgputesting() {
    if lsgpu | grep "$AMD_GPU" >/dev/null 2>&1; then
        echo "AMD GPU detected"
        amd_gpu_present=true  # Declare and assign the variable here
    else
        echo "AMD GPU not detected"
        amd_gpu_present=false # Declare and assign the variable here
    fi
}

amdgputesting

if $amd_gpu_present; then
    echo "Detected you are on an arch-based/similar distro, installing packages:"
    echo "Making sure that multilib repo is enabled:"
    sed -i '/^Multilib/ s/^#//' /etc/pacman.conf
    echo "Installing 32-bit libraries:"
    sudo pacman -Syy lib32-mesa --noconfirm
    read -p "Are you wanting 2D Acceleration/Vulkan? (y/n): " answer
    if [[ $answer == "y" ]]; then
        echo "Installing 32-bit vulkan libraries:"
        sudo pacman -Sy xf86-video-amdgpu --noconfirm
        AMD_GPU_TYPE=$(lspci -v | grep -i "VGA" | awk '/VGA compatible controller:/{print $NF}' | xargs lshw -c video -C)
        if [[ "$AMD_GPU_TYPE" == *"Radeon Technologies*" ]]; then
          echo "Your GPU Type is older AMD. Installing 'lib32-amdvlk' package."
          sudo pacman -Sy lib32-amdvlk --noconfirm
        else
          echo "Your GPU Type is modern AMD. Install 'lib32-vulkan-radeon' package."
          sudo pacman -Sy lib32-vulkan-radeon --noconfirm
        fi
    fi  
    sudo pacman -Sy vulkan-radeon --noconfirm
fi

if $amd_gpu_present ; then
    echo "Detected you are on an arch-based/similar distro, installing packages:"
    echo "Making sure that multilib repo is enabled:"
    sed -i '/^Multilib/ s/^#//' /etc/pacman.conf
fi

read -p "Would you like to install the latest drivers for AMD from source? (y/n): " answer
if [[ $answer == "y" ]]; then
    echo "Compiling the latest drivers for AMD from source"
    echo "grabbing an AUR helper"
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay  
    makepkg -si
    yay -Sy mesa-git  lib32-mesa-git --noconfirm
    echo "Installing 32-bit vulkan libraries:"
    yay -Sy xf86-video-amdgpu --noconfirm
    AMD_GPU_TYPE_GIT=$(lspci -v | grep -i "VGA" | awk '/VGA compatible controller:/{print $NF}' | xargs lshw -c video -C)
    if [[ "$AMD_GPU_TYPE_GIT" == *"Radeon Technologies*" ]]; then
      echo "Your GPU Type is older AMD. Installing 'lib32-amdvlk' package."
      yay -Sy lib32-amdvlk --noconfirm
    else
      echo "Your GPU Type is modern AMD. Install 'lib32-vulkan-radeon' package."
      yay -Sy lib32-vulkan-radeon --noconfirm
    fi
    yay -Sy vulkan-radeon --noconfirm
fi  