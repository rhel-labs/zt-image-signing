#!/bin/sh
echo "Validating module-02" >> /tmp/progress.log

if [ ! -f /home/rhel/cosign.key ] || [ ! -f /home/rhel/cosign.pub ]; then
    echo "FAIL: cosign key pair not found" >> /tmp/progress.log
    echo "HINT: Did you run cosign generate-key-pair to create your signing keys?" >> /tmp/progress.log
    exit 1
fi

. /home/rhel/.bashrc 2>/dev/null || true

if ! runuser -u rhel -- podman image exists ${REGISTRY}/rhhi-demo:v1 2>/dev/null; then
    echo "FAIL: rhhi-demo:v1 not found in local registry storage" >> /tmp/progress.log
    echo "HINT: Did you tag and push the image to ${REGISTRY} as shown in the module?" >> /tmp/progress.log
    exit 1
fi

echo "PASS: cosign key pair exists and image pushed to registry" >> /tmp/progress.log
exit 0
