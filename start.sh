$KEYMAP=us
package_install(){
  pacman -S --noconfirm --needed ${PKG}

}
MOUNTPOINT="/mnt"
loadkeys $KEYMAP
package_install "nano"
#Available countries are
#"Australia" "Austria" "Belarus" "Belgium" "Brazil" "Bulgaria" "Canada"
#"Chile" "China" "Colombia" "Czech Republic" "Denmark" "Estonia" "Finland"
#"France" "Germany" "Greece" "Hungary" "India" "Ireland" "Israel" "Italy"
#"Japan" "Kazakhstan" "Korea" "Latvia" "Luxembourg" "Macedonia" "Netherlands"
#"New Caledonia" "New Zealand" "Norway" "Poland" "Portugal" "Romania" "Russian"
#"Serbia" "Singapore" "Slovakia" "South Africa" "Spain" "Sri Lanka" "Sweden"
#"Switzerland" "Taiwan" "Turkey" "Ukraine" "United Kingdom" "United States" "Uzbekistan" "Viet Nam"

country_code=India
url="https://www.archlinux.org/mirrorlist/?country=${country_code}&use_mirror_status=on"

tmpfile=$(mktemp --suffix=-mirrorlist)

curl -so ${tmpfile} ${url}
sed -i 's/^#Server/Server/g' ${tmpfile}

# Get latest mirror list and save to tmpfile
if [[ -s ${tmpfile} ]]; then
   { echo " Backing up the original mirrorlist..."
     mv -i /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig; } &&
   { mv -i ${tmpfile} /etc/pacman.d/mirrorlist; }
  else
    echo " Unable to update, could not download list."
    exit
  fi

curl -so ${tmpfile} ${url}
sed -i 's/^#Server/Server/g' ${tmpfile}
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.tmp
rankmirrors /etc/pacman.d/mirrorlist.tmp > /etc/pacman.d/mirrorlist
rm /etc/pacman.d/mirrorlist.tmp
# allow global read access (required for non-root yaourt execution)
chmod +r /etc/pacman.d/mirrorlist

setup_alt_dns(){
  cat <<- EOF > /etc/resolv.conf.head
# OpenDNS IPv4 nameservers
nameserver 208.67.222.222
nameserver 208.67.220.220
# OpenDNS IPv6 nameservers
nameserver 2620:0:ccc::2
nameserver 2620:0:ccd::2

# Google IPv4 nameservers
nameserver 8.8.8.8
nameserver 8.8.4.4
# Google IPv6 nameservers
nameserver 2001:4860:4860::8888
nameserver 2001:4860:4860::8844

# Comodo nameservers
nameserver 8.26.56.26
nameserver 8.20.247.20

# Basic Yandex.DNS - Quick and reliable DNS
nameserver 77.88.8.8
nameserver 77.88.8.1
# Safe Yandex.DNS - Protection from virus and fraudulent content
nameserver 77.88.8.88
nameserver 77.88.8.2
# Family Yandex.DNS - Without adult content
nameserver 77.88.8.7
nameserver 77.88.8.3

# censurfridns.dk IPv4 nameservers
nameserver 91.239.100.100
nameserver 89.233.43.71
# censurfridns.dk IPv6 nameservers
nameserver 2001:67c:28a4::
nameserver 2002:d596:2a92:1:71:53::
EOF
}
umount_partitions(){
  mounted_partitions=(`lsblk | grep ${MOUNTPOINT} | awk '{print $7}' | sort -r`)
  swapoff -a
  for i in ${mounted_partitions[@]}; do
    umount $i
  done
}
umount_partitions
echo -e "Set up Partition"
cfdisk /dev/sda
clear
echo -e "Select root partition"
partitions=(`lsblk -l | grep sda[0-9] | awk '{print $1}'`)
select boot in "${partitions[@]}"
echo $boot
echo -e "setting filesystem"
