#!/bin/sh
echo "Solving module-03: Sign and Verify" >> /tmp/progress.log

# Load environment variables from bashrc
. /home/rhel/.bashrc 2>/dev/null || true

# Sign the image using the digest and local key
export COSIGN_PASSWORD=""
cosign sign --tlog-upload=false \
  --yes --key /home/rhel/cosign.key \
  ${REGISTRY}/rhhi-demo@${IMAGE_DIGEST}

# Verify the signature with the public key
cosign verify --insecure-ignore-tlog=true \
  --key /home/rhel/cosign.pub \
  ${REGISTRY}/rhhi-demo@${IMAGE_DIGEST}

echo "module-03 solve complete" >> /tmp/progress.log
