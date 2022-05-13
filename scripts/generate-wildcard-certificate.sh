#!/usr/bin/env bash

# See https://gist.github.com/dmadisetti/16006751fd6e1526fa9c2f2e1660e8e3
# Modified to provide a SAN and make this usable for SSL.

DOMAIN=${1:-`hostname`}
echo "USAGE: $0 tld

This will generate a non-secure self-signed wildcard certificate for \
a given development tld."

read -p "Add wildcard *.$DOMAIN?
> " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

# Add wildcard
WILDCARD="*.$DOMAIN"

# Set our variables
cat <<EOF > req.cnf
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = US
ST = MD
O = home
localityName = home
commonName = $WILDCARD
organizationalUnitName = home
emailAddress = $(git config user.email)
[v3_req]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1   = *.https.$DOMAIN
IP   = 10.0.0.1
EOF

# DNS.1   = https.$DOMAIN

# Generate our Private Key, and Certificate directly
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout "$DOMAIN.key" -config req.cnf \
  -out "$DOMAIN.crt" -sha256
rm req.cnf

echo ""
echo "Next manual steps:"
echo "- Use $DOMAIN.crt and $DOMAIN.key to configure Apache/nginx"
echo "- Import $DOMAIN.crt into Chrome settings: chrome://settings/certificates > tab 'Authorities'"
