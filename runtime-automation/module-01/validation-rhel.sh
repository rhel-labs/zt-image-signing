#!/bin/sh
echo "Validating module-01" >> /tmp/progress.log

if [ ! -f /home/rhel/hi-openjdk.sig ]; then
    echo "FAIL: hi-openjdk.sig not found" >> /tmp/progress.log
    echo "HINT: Verify the openjdk:21-runtime signature with cosign using the Red Hat public key URL" >> /tmp/progress.log
    exit 1
fi

if [ ! -f /home/rhel/ubi-latest.sig ]; then
    echo "FAIL: ubi-latest.sig not found" >> /tmp/progress.log
    echo "HINT: Verify the ubi9/ubi:latest signature with cosign using the local RHEL signing key" >> /tmp/progress.log
    exit 1
fi

echo "PASS: Both signature output files exist" >> /tmp/progress.log
exit 0
