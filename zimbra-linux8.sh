#!/bin/bash
clear

echo -e "##########################################################################"
echo -e "#      Avci Internet ve Bilisim Hizmetleri - http://www.avciweb.com      #"
echo -e "#                  Zimbra Oracle and Centos 8 install                    #"
echo -e "#                    Contact at info@avciweb.com.tr                      #"
echo -e "#                               www.avciweb.com                          #"
echo -e "##########################################################################"

echo ""
echo -e "Make sure you have internet connection to install packages..."
echo ""
echo -e "Press key enter"
read presskey

# Disable Selinux & Firewall

echo -e "[INFO] : Configuring Firewall & Selinux"
sleep 2
sed -i s/'SELINUX='/'#SELINUX='/g /etc/selinux/config
echo 'SELINUX=disabled' >> /etc/selinux/config
setenforce 0
service firewalld stop
service iptables stop
service ip6tables stop
systemctl disable firewalld
systemctl disable iptables
systemctl disable ip6tables

# Configuring network, /etc/hosts and resolv.conf

echo ""
echo -e "[INFO] : Configuring /etc/hosts"
echo ""
echo -n "Hostname. Example mail : "
read HOSTNAME
echo -n "Domain name. Example avciweb.com : "
read DOMAIN
echo -n "IP Address : "
read IPADDRESS
echo ""

# /etc/hosts

cp /etc/hosts /etc/hosts.backup

#echo "127.0.0.1       localhost" > /etc/hosts
echo "$IPADDRESS   $HOSTNAME.$DOMAIN       $HOSTNAME" >> /etc/hosts

# Change Hostname
hostnamectl set-hostname $HOSTNAME.$DOMAIN

# Disable service sendmail or postfix

service sendmail stop
service postfix stop
systemctl disable sendmail
systemctl disable postfix

# Update repo and install package

yum clean all
yum -y install epel-release
yum update -y
yum -y install perl
yum -y install perl-core
yum -y install libstdc++.so.6
yum -y install wget
yum -y install screen
yum -y install openssh-clients
yum -y install openssh-server
yum -y install bind
yum -y install bind-utils
yum -y install unzip
yum -y install nmap
yum -y install nmap-ncat
yum -y install sed
yum -y install nc
yum -y install sysstat
yum -y install libaio
yum -y install rsync
yum -y install telnet
yum -y install aspell
yum -y install net-tools
yum -y install certbot

# Restart Network
service network restart

# Configuring DNS Server

echo ""
echo -e "[INFO] : Configuring DNS Server"
echo ""

NAMED=`ls /etc/ | grep named.conf.back`;

        if [ "$NAMED" == "named.conf.back" ]; then
	cp /etc/named.conf.back /etc/named.conf        
        else
	cp /etc/named.conf /etc/named.conf.back        
        fi

sed -i s/"listen-on port 53 { 127.0.0.1; };"/"listen-on port 53 { 127.0.0.1; $IPADDRESS ; };"/g /etc/named.conf
sed -i s/"allow-query     { localhost; };"/"allow-query     { localhost; $IPADDRESS ; };"/g /etc/named.conf

echo 'zone "'$DOMAIN'" IN {' >> /etc/named.conf
echo "        type master;" >> /etc/named.conf
echo '        file "'db.$DOMAIN'";' >> /etc/named.conf
echo "        allow-update { none; };" >> /etc/named.conf
echo "};" >> /etc/named.conf

touch /var/named/db.$DOMAIN
chgrp named /var/named/db.$DOMAIN

echo '$TTL 14400' > /var/named/db.$DOMAIN
echo "@       IN SOA  ns1.$DOMAIN. root.$DOMAIN. (" >> /var/named/db.$DOMAIN
echo '                                        0       ; serial' >> /var/named/db.$DOMAIN
echo '                                        3600      ; refresh' >> /var/named/db.$DOMAIN
echo '                                        1800      ; retry' >> /var/named/db.$DOMAIN
echo '                                        604800      ; expire' >> /var/named/db.$DOMAIN
echo '                                        86400 )    ; minimum' >> /var/named/db.$DOMAIN
echo "@		IN	NS	ns1.$DOMAIN." >> /var/named/db.$DOMAIN
echo "@		IN	MX	0 $HOSTNAME.$DOMAIN." >> /var/named/db.$DOMAIN
echo "ns1	IN	A	$IPADDRESS" >> /var/named/db.$DOMAIN
echo "$HOSTNAME	IN	A	$IPADDRESS" >> /var/named/db.$DOMAIN

# Insert localhost as the first Nameserver
mv /etc/resolv.conf /etc/resolv.confbak
touch /etc/resolv.conf
#sed -i '1 s/^/nameserver 127.0.0.1\n/' /etc/resolv.conf
#sed -i s/"nameserver "/"nameserver 8.8.8.8"/g /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
# Restart Service & Check results configuring DNS Server

service named restart
systemctl enable named
nslookup $HOSTNAME.$DOMAIN
dig $DOMAIN mx

echo ""
echo "Configuring Firewall, network, /etc/hosts and DNS server has been finished. please install Zimbra now"