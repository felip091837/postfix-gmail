#!/bin/bash

# felipesi - 2020

# need allow 
# https://myaccount.google.com/lesssecureapps?gar=1

# issue 'SASL failed'
# https://accounts.google.com/b/0/DisplayUnlockCaptcha

# tested on 'Ubuntu Server 20.04' aws

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

account='youremail@gmail.com'
password='PASSWORD'

apt update -y
apt install postfix mailutils libsasl2-2 ca-certificates libsasl2-modules -y

cat <<EOT > /etc/postfix/main.cf
relayhost = [smtp.gmail.com]:587
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_CAfile = /etc/postfix/cacert.pem
smtp_use_tls = yes
EOT

cat <<EOT > /etc/postfix/sasl_passwd
[smtp.gmail.com]:587 $account:$password
EOT

chmod 400 /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd

cat /etc/ssl/certs/thawte_Primary_Root_CA.pem | sudo tee -a /etc/postfix/cacert.pem

systemctl restart postfix.service

# send test
# mail -s 'TESTE' youremail@mail.com <<< $(date '+%H:%M:%S - %d/%m/%Y')
