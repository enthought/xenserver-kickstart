# CentOS 6.5 kickstart for XenServer
# branch: develop
##########################################

# Install, not upgrade
install

# Install from a friendly mirror and add updates
url --url http://dfw.mirror.rackspace.com/centos/6/os/x86_64/
repo --name=centos-updates --baseurl=http://dfw.mirror.rackspace.com/centos/6/os/x86_64
repo --name=epel --baseurl=http://dfw.mirror.rackspace.com/epel/6/x86_64
repo --name=epel-testing --baseurl=http://dfw.mirror.rackspace.com/epel/testing/6/x86_64

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

# Setup the disk
zerombr
clearpart --all --drives=xvda
part / --fstype=xfs --grow --size=1024 --asprimary
bootloader --location=partition --timeout=5 --driveorder=xvda --append="console=hvc0"

# Shutdown when the kickstart is done
halt

# Minimal package set
%packages --excludedocs
@server-platform
@network-file-system-client
man
vim
deltarpm
yum-plugin-fastestmirror
net-tools
-dracut-config-rescue
-fprintd-pam
-wireless-tools
%end
