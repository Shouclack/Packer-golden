#version=RHEL7
# System authorization information

install
text
cdrom
network --onboot yes --bootproto=dhcp --device=eth0 --activate --noipv6
lang en_US
keyboard us
timezone America/New_York

zerombr
clearpart --all --initlabel
autopart
bootloader --location=mbr --append="ipv6.disable=1 net.ifnames=0 biosdevname=0"

auth --enablesssd --enablesssdauth --enablemkhomedir --updateall
rootpw --iscrypted $6$5Wold.MPqUueyB1I$lBh4ZKUMXvXHAiH/TSWnCZBzSi.mxaK6efjA/vZi7W5ugaj.zHgHgJi5pIXlB7vgO.t8PCNfIY7o.R7xCz1PF0
user --name=vagrant --groups=vagrant --password=vagrant

selinux --permissive
firewall --disabled
firstboot --disabled

reboot

#repo --name=KVM --baseurl=ftp://192.168.1.24/CentOS-7-x86_64-Minimal-1810

#---------------MORE KICKSTART STUFF-----------------

%pre
%end

#Package selection for smallest footprint
%packages --nobase
@core --nodefaults
-aic94xx-firmware*
-alsa-*
-biosdevname
-btrfs-progs*
-dhclient
-dhcp*
-dracut-network
-iprutils
-ivtv*
-iwl*firmware
-libertas*
-kexec-tools
-plymouth*
-postfix
openssh-clients
openssh-server
%end

%post --log=/root/ks-post.log
# Add vagrant to sudoers
cat > /etc/sudoers.d/vagrant << EOF_sudoers_vagrant
vagrant        ALL=(ALL)       NOPASSWD: ALL
EOF_sudoers_vagrant

/bin/chmod 0440 /etc/sudoers.d/vagrant
/bin/sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Fix sshd config for CentOS 7 1611 (reboot issue)
cat << EOF_sshd_config >> /etc/ssh/sshd_config

TCPKeepAlive yes
ClientAliveInterval 0
ClientAliveCountMax 3

UseDNS no
UsePAM no
GSSAPIAuthentication no
ChallengeResponseAuthentication no

EOF_sshd_config

#yum -y update
%end
