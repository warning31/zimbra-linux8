#!/bin/bash
#
#
#

echo -n "Domain name. Example avciweb.com : "
read SSLDOMAIN
echo ""

DOMAIN="$SSLDOMAIN"
#
yum install epel-release -y
yum install certbot -y
#
iptables -A INPUT -p tcp -m multiport --dport 80,443 -j ACCEPT
#
certbot certonly --standalone -d $DOMAIN
#
iptables -D INPUT -p tcp -m multiport --dport 80,443 -j ACCEPT
#
cd /etc/letsencrypt/live/$DOMAIN/ || exit
#wget -4 -O /etc/letsencrypt/live/$DOMAIN/zimbra_chain.pem https://letsencrypt.org/certs/trustid-x3-root.pem.txt
wget -4 -O /etc/letsencrypt/live/$DOMAIN/zimbra_chain.pem https://letsencrypt.org/certs/isrgrootx1.pem.txt
#
cat /etc/letsencrypt/live/$DOMAIN/chain.pem >> /etc/letsencrypt/live/$DOMAIN/zimbra_chain.pem
#
tar -czf /opt/zimbra/ssl/zimbra-$(date +"%d.%m.%y_%H.%M").tar.gz /opt/zimbra/ssl/zimbra
#
mkdir /opt/zimbra/ssl/letsencrypt
cp /etc/letsencrypt/live/$DOMAIN/* /opt/zimbra/ssl/letsencrypt/
#
chown -Rfv zimbra:zimbra /opt/zimbra/ssl/letsencrypt/
#
sudo su - zimbra -c "zmcertmgr verifycrt comm /opt/zimbra/ssl/letsencrypt/privkey.pem /opt/zimbra/ssl/letsencrypt/cert.pem /opt/zimbra/ssl/letsencrypt/zimbra_chain.pem"
#
cp /opt/zimbra/ssl/letsencrypt/privkey.pem /opt/zimbra/ssl/zimbra/commercial/commercial.key
chown zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/commercial.key
#
sudo su - zimbra -c "zmproxyctl stop"
sudo su - zimbra -c "zmmailboxdctl stop"
sudo su - zimbra -c "zmcertmgr deploycrt comm /opt/zimbra/ssl/letsencrypt/cert.pem /opt/zimbra/ssl/letsencrypt/zimbra_chain.pem"
sudo su - zimbra -c "zmcontrol restart"