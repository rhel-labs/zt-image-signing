#!/bin/sh
echo "Validating module-03: Sign and Verify" >> /tmp/progress.log

# Load environment variables from bashrc
. /home/rhel/.bashrc 2>/dev/null || true

if [ -z "$REGISTRY" ]; then
    echo "FAIL: REGISTRY environment variable not set"
    echo "HINT: Run 'source ~/.bashrc' to load the REGISTRY variable"
    exit 1
fi

if [ -z "$IMAGE_DIGEST" ]; then
    echo "FAIL: IMAGE_DIGEST environment variable not set"
    echo "HINT: Run 'source ~/.bashrc' to load the IMAGE_DIGEST variable"
    exit 1
fi

# Verify the signature exists and is valid
export COSIGN_PASSWORD=""
if cosign verify --insecure-ignore-tlog=true \
  --key /home/rhel/cosign.pub \
  ${REGISTRY}/rhhi-demo@${IMAGE_DIGEST} > /dev/null 2>&1; then
    echo "PASS: Image signature verification succeeded"
    exit 0
else
    echo "FAIL: Image signature verification failed"
    echo "HINT: Make sure you ran 'cosign sign' with your cosign.key for the correct image digest"
    exit 1
fi
