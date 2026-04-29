#!/bin/sh
echo "Solving module-01: Verify Published Signatures" >> /tmp/progress.log

# Verify Red Hat openjdk:21-runtime signature using the published public key URL
/usr/local/bin/cosign verify --insecure-ignore-tlog \
  --output-file /home/rhel/hi-openjdk.sig \
  --key https://security.access.redhat.com/data/63405576.txt \
  registry.access.redhat.com/hi/openjdk:21-runtime

# Verify UBI image signature using the local signing key shipped with RHEL
/usr/local/bin/cosign verify --insecure-ignore-tlog \
  --output-file /home/rhel/ubi-latest.sig \
  --key /etc/pki/sigstore/SIGSTORE-redhat-release3 \
  registry.access.redhat.com/ubi9/ubi:latest

cat /home/rhel/hi-openjdk.sig | jq '.[0].optional'

echo "module-01 solve complete" >> /tmp/progress.log
