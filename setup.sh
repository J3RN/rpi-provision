#!/bin/sh

# Ensure basic stuff set up
echo "I assume you have already run 'raspi-config'"

# Adjust the 'pi' user
read -p "New username: " $usern
$new_home = /home/$usern
usermod -l $usern -md $new_home pi

# Update sudoers file
sed -i s/pi/$usern/ /etc/sudoers

# Wireless setup
read -p "SSID: " ssid
read -p "PSK: " psk

wpa_passphrase "$ssid" "$psk" | tee -a /etc/wpa_supplicant/wpa_supplicant.conf

# Restart WiFi interface
ifdown wlan0
ifup wlan0

# Wait for WiFi
while ! ping -c1 google.com > /dev/null; do
  echo "Waiting for network..."
  sleep 5
done

# Update system
apt-get update && apt-get -y upgrade

# Install software
apt-get -y zsh vim xorg rxvt-unicode weechat
# Install build libraries
apt-get -y libevent-dev libx11-dev libxft-dev libxinerama-dev

cd $new_home

## Suckless tools
mkdir sl && cd sl

# Install DWM
wget dl.suckless.org/dwm/dwm-6.1.tar.gz
tar -xf dwm-6.1.tar.gz
cd dwm-6.1
sed -i 's/FREETYPEINC = \$/#FREETYPEINC = \$/'
make clean install
cd ..

# Install dmenu
wget dl.suckless.org/tools/dmenu-4.6.tar.gz
tar -xf dmenu-4.6.tar.gz
cd dmenu-4.6
sed -i 's/FREETYPEINC = \$/#FREETYPEINC = \$/'
make clean install
cd ..

# Return to user's new directory
cd $new_home

## Clone repos
mkdir workspace && cd workspace

# Clone and install vim-config
git clone https://github.com/J3RN/vim-config
cd vim-config
./install.sh
cd ..

# Clone and install dotfiles
git clone https://github.com/J3RN/dotfiles
cd dotfiles
./install.sh
cd ..
