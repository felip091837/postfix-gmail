#!/bin/bash

# issue 'SASL failed'
# https://accounts.google.com/b/0/DisplayUnlockCaptcha

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

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
[smtp.gmail.com]:587 youremail@gmail.com:PASSWORD
EOT

chmod 400 /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd

cat /etc/ssl/certs/thawte_Primary_Root_CA.pem | sudo tee -a /etc/postfix/cacert.pem

systemctl restart postfix.service

# test
# mail -s 'TESTE' youremail@mail.com <<< $(date '+%H:%M:%S - %d/%m/%Y')
