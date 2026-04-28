#!/bin/sh
echo "Validating module-02: Push and Generate Keys" >> /tmp/progress.log

# Check that the cosign private key was generated
if [ ! -f /home/rhel/cosign.key ]; then
    echo "FAIL: cosign.key not found"
    echo "HINT: Run 'cosign generate-key-pair' to generate the key pair"
    exit 1
fi

# Check that the cosign public key was generated
if [ ! -f /home/rhel/cosign.pub ]; then
    echo "FAIL: cosign.pub not found"
    echo "HINT: Run 'cosign generate-key-pair' to generate the key pair"
    exit 1
fi

# Check that IMAGE_DIGEST is set in bashrc
if ! grep -q 'IMAGE_DIGEST' /home/rhel/.bashrc; then
    echo "FAIL: IMAGE_DIGEST not written to ~/.bashrc"
    echo "HINT: Capture the digest with podman inspect and write it to ~/.bashrc"
    exit 1
fi

echo "PASS: cosign key pair and IMAGE_DIGEST are in place"
exit 0
