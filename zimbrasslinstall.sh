#!/bin/bash
#
echo -n "Domain name. Example mail.avciweb.com : "
read SSLDOMAIN
echo ""

echo -n "E-mail name. Example info@avciweb.com : "
read SSLMAIL
echo ""

MAIL="$SSLMAIL"
DOMAIN="$SSLDOMAIN"

# renew ssl 
wget -4 -O /usr/sbin/zimbrasslrenew.sh https://raw.githubusercontent.com/warning31/zimbra-linux8/main/zimbrasslrenew.sh

# renew cron
crontab <<EOF
0 0 * * *  root    /usr/sbin/zimbrasslrenew.sh
EOF

certbot certonly --standalone -d $DOMAIN -m $MAIL
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