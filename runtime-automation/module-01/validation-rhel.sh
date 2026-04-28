#!/bin/sh
echo "Validating module-01: Verify Published Signatures" >> /tmp/progress.log

# Check that the openjdk signature output file was created
if [ ! -f /home/rhel/hi-openjdk.sig ]; then
    echo "FAIL: hi-openjdk.sig not found"
    echo "HINT: Run the cosign verify command for openjdk:21-runtime with --output-file hi-openjdk.sig"
    exit 1
fi

# Check that the UBI signature output file was created
if [ ! -f /home/rhel/ubi-latest.sig ]; then
    echo "FAIL: ubi-latest.sig not found"
    echo "HINT: Run the cosign verify command for ubi9/ubi:latest with --output-file ubi-latest.sig"
    exit 1
fi

echo "PASS: Both signature output files exist"
exit 0
