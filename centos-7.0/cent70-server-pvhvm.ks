# CentOS 7.0 kickstart for XenServer (PVHVM MBR)
# branch: develop
##########################################

# Install, not upgrade
install

# Install from a friendly mirror and add updates
url --url http://dfw.mirror.rackspace.com/CentOS/7/os/x86_64/
repo --name=centos-updates --baseurl=http://dfw.mirror.rackspace.com/centos/7/os/x86_64
repo --name=epel --baseurl=http://dfw.mirror.rackspace.com/epel/7/x86_64
repo --name=epel-testing --baseurl=http://dfw.mirror.rackspace.com/epel/testing/7/x86_64

# Language and keyboard setup
lang en_US.UTF-8
keyboard us

# Configure networking without IPv6, firewall off

# for STATIC IP: uncomment and configure
# network --onboot=yes --device=eth0 --bootproto=static --ip=192.168.###.### --netmask=255.255.255.0 --gateway=192.168.###.### --nameserver=###.###.###.### --noipv6 --hostname=$$$

# for DHCP:
network --bootproto=dhcp --device=eth0 --onboot=on

firewall --disabled

# Set timezone
timezone --utc Etc/UTC

# Authentication
rootpw --sshenabled --iscrypted $6$rounds=100000$ErgueCvvAHyt4cDv$TMHl2Rz6MNxfWatC2EK1arCEnP9mbVYA2X4UfZ5aX1i0dr2pKwKIyjitC3w0UG3MZ8sss.j57mWmoEzLFmhXa0
# if you want to preset the root password in a public kickstart file, use SHA512crypt e.g.
# rootpw --iscrypted $6$9dC4m770Q1o$FCOvPxuqc1B22HM21M5WuUfhkiQntzMuAV7MY0qfVcvhwNQ2L86PcnDWfjDd12IFxWtRiTuvO/niB0Q3Xpf2I.
user --name=centos --password=enthought --plaintext --gecos="CentOS User" --shell=/bin/bash --groups=user,wheel
# if you want to preset the user password in a public kickstart file, use SHA512crypt e.g.
# user --name=centos --password=$6$9dC4m770Q1o$FCOvPxuqc1B22HM21M5WuUfhkiQntzMuAV7MY0qfVcvhwNQ2L86PcnDWfjDd12IFxWtRiTuvO/niB0Q3Xpf2I. --iscrypted --gecos="CentOS User" --shell=/bin/bash --groups=user,wheel
authconfig --enableshadow --passalgo=sha512

# SELinux enabled
selinux --permissive

# Disable anything graphical
skipx
text
eula --agreed

# Setup the disk
zerombr
clearpart --all
part /boot --fstype=ext3 --size=256 --asprimary
part / --fstype=xfs --grow --size=1024 --asprimary
bootloader --timeout=5 --location=mbr

# Shutdown when the kickstart is done
halt

# Minimal package set
%packages --excludedocs
@base
@network-file-system-client
deltarpm
yum-plugin-fastestmirror
dracut-config-generic
-dracut-config-rescue
-plymouth
-fprintd-pam
-wireless-tools
-NetworkManager
-NetworkManager-tui
%end

%post --log=/root/ks-post.log

echo -n "/etc/fstab fixes"
# update fstab for the root partition
perl -pi -e 's/(defaults)/$1,noatime,nodiratime/' /etc/fstab
echo .

echo -n "Network fixes"
# initscripts don't like this file to be missing.
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF
echo -n "."

# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules
echo -n "."

# simple eth0 config, again not hard-coded to the build hardware
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
PERSISTENT_DHCLIENT="yes"
EOF
echo -n "."

# generic localhost names
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

EOF
echo -n "."

# since NetworkManager is disabled, need to enable normal networking
chkconfig network on
echo .

# utility script
echo -n "Utility scripts"
echo "== Utility scripts ==" >> /root/ks-post.debug.log
wget -O /opt/domu-hostname.sh https://github.com/frederickding/xenserver-kickstart/raw/develop/opt/domu-hostname.sh 2>> /root/ks-post.debug.log
chmod +x /opt/domu-hostname.sh
echo .

# generalization
echo -n "Generalizing"
rm -f /etc/ssh/ssh_host_*
echo .
%end
