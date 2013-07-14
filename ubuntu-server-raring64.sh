#!/bin/sh

# Ubuntu Server 13.04
# ===================

# Download
# --------

# The result of this box is [publicly available][1] so you can add it to your
# vagrant configuration like so:
# [1]: https://copy.com/ihzTonCKxAiH "Ubuntu Server 13.04 “Raring Ringtail”"

# ```
# config.vm.box = "ubuntu-server-raring64"
# config.vm.box_url = "https://copy.com/ihzTonCKxAiH/ubuntu-server-raring64.box"
# ```

# Prerequisites
# -------------

# These steps assume that you've gone through the process of setting up your
# virtual machine and are logged into that machine as root. **Important** you
# need to have the guest additions disk mounted.

# Step 1: Basic packages
# ----------------------

# ### Install chef

# Chef should be installed as per the [opscode installation instructions][1]
# which utilizes a web installer.
# [1]: http://www.opscode.com/chef/install/
curl -L https://www.opscode.com/chef/install.sh | bash

# ### Install puppet

# Puppet is installed from the default apt repositories provided in Ubuntu. I'm
# not currently using puppet, so if there's a better method please send a pull
# request.
apt-get install -y puppet puppetmaster

# Step 2: VirtualBox Additions
# ----------------------------

# ### Install build dependencies

# Build dependencies are installed so that virtualbox and generate the
# neccisasary kernel modules.
apt-get install linux-headers-$(uname -r) build-essential -y

# ### Mount the guest additions CDROM

# Note that you must have 'inserted' the guest additions ISO using the "Install
# Guest Additions ..." menu button before this step.
mount /dev/cdrom /media/cdrom

# ### Run the guest additions installer

# VirtualBox provides an installation script which will build the kernel module
# that it requires and install other services required for management of the VM
# by the host. *Note that 'Installing the Window System drivers' will fail, this
# is expected as servers don't have a window system.*
sh /media/cdrom/VBoxLinuxAdditions.run

# ### Remove the build dependencies

# Once we've installed the VirtualBox additions we don't need the build
# dependencies any more. They should be removed to reduce the size of the
# virtual machine.
apt-get remove linux-headers-$(uname -r) build-essential -y

# Step 3: Users, Groups and Sudo
# ------------------------------

# ### Create the `admin` group

# The admin group is used to provide passwordless sudo to vagrant.
groupadd admin

# ### Add `vagrant` to the `admin` group

# It is important that the `admin` group is the only group which `vagrant` is a
# member of. This is to prevent the `sudo` group from overwriting the
# passwordless sudo setup of the `admin` group. The sudoers file keeps the
# settings from the *last* matching group (sudo) which overwrites the settings
# of the admin group.
usermod -G admin vagrant

# ### Configure sudoers file

# The `admin` group needs to be granted access to execute all commands with no
# password. Additionally agent forwarding should be kept when vagrant executes
# sudo.
echo '
Defaults env_keep="SSH_AUTH_SOCK"
%admin ALL=NOPASSWD: ALL
' >> /etc/sudoers

# Step 4: SSH Keys
# ----------------

# Vagrant uses an 'insecure' public/private key pair to facilitate conntections
# to the VM. This key pair needs to be stored and authorized for connections.

# ### Create SSH config directory

# Create the `/home/vagrant/.ssh` directory
mkdir /home/vagrant/.ssh

# Change to that directory
cd /home/vagrant/.ssh

# ### Download SSH Keys

# Download the [`vagrant`][2] and [`vagrant.pub`][2] keys from github into the
# `.ssh` directory.
#  [1]: https://github.com/mitchellh/vagrant/blob/master/keys/vagrant
#  [2]: https://github.com/mitchellh/vagrant/blob/master/keys/vagrant.pub
wget https://raw.github.com/mitchellh/vagrant/master/keys/vagrant
wget https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub

# Append the contents of `vagrant.pub` to the `authorized_keys` to authorize
# vagrant to login via ssh.
cat vagrant.pub >> authorized_keys

# Ensure that the correct permissions are applied to the `authorized_keys`,
# `vagrant` and `vagrant.pub` folders
chmod 0700 .
chown vagrant:vagrant authorized_keys vagrant vagrant.pub
chmod 0600 authorized_keys vagrant vagrant.pub

# Step 5: Cleanup
# ---------------

# This step is sourced from the [`purge.sh` gist][2] by [Adrien Brault][1] and
# will minimize the size of the created box file.
#  [1]: https://gist.github.com/adrienbrault
#  [2]: https://gist.github.com/adrienbrault/3775253

# ### Remove unused packages
apt-get purge -y ri
apt-get purge -y installation-report landscape-common wireless-tools wpasupplicant ubuntu-serverguide
apt-get purge -y python-dbus libnl1 python-smartpm python-twisted-core libiw30
apt-get purge -y python-twisted-bin libdbus-glib-1-2 python-pexpect python-pycurl python-serial python-gobject python-pam python-openssl

# ### Remove APT cache
apt-get clean -y
apt-get autoclean -y

# ### Zero free space to aid VM compression
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# ### Remove bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# ### Cleanup log files
find /var/log -type f | while read f; do echo -ne '' > $f; done

# ### Whiteout root
count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`
let count--
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count
rm /tmp/whitespace
 
# ### Whiteout /boot
count=`df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}'`
let count--
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count
rm /boot/whitespace
 
# ### Whiteout swap
swappart=`cat /proc/swaps | tail -n1 | awk -F ' ' '{print $1}'`
swapoff $swappart
dd if=/dev/zero of=$swappart
mkswap $swappart
swapon $swappart

# Step 6: Reboot
# --------------

# System is should rebooted to give it a final flush out and to restore things
# like the history file.
reboot

# Thanks to
# ---------

# The contents of this script has been compiled from a bunch of different
# resources I found around the web. I just wanted to say a big thanks to those
# who shared their experiences and knowledge and encourage you to have a look at
# their aritcles yourself.

# **[Felipe Espinoza](https://github.com/fespinoza)**
# > [Creating a vagrant base box for ubuntu 12.04 32bit server][1]
# [1]: https://github.com/fespinoza/checklist_and_guides/wiki/Creating-a-vagrant-base-box-for-ubuntu-12.04-32bit-server

# **[Basilio Briceño](http://briceno.mx)**
# > [Easy and simple guide to create your own Vagrant box (Ubuntu-12.02-64
#   server bridged) from VirtualBox][1]
# [1]: http://briceno.mx/2012/10/easy-guide-to-create-a-vagrant-box-from-virtualbox/

# **[Adrien Brault](https://gist.github.com/adrienbrault)**
# > [`purge.sh`](https://gist.github.com/adrienbrault/3775253) - a gist with
# > commands to reduce the size of a vagrant box
