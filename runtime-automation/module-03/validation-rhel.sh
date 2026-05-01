#!/bin/sh
echo "Validating module-03" >> /tmp/progress.log

. /home/rhel/.bashrc 2>/dev/null || true

IMAGE_DIGEST=$(runuser -l rhel -c "podman inspect --format='{{.Digest}}' ${REGISTRY}/rhhi-demo:v1" 2>/dev/null)
if [ -z "$IMAGE_DIGEST" ]; then
    echo "FAIL: Could not find rhhi-demo:v1 in registry storage" >> /tmp/progress.log
    echo "HINT: Did you complete module 2 to push the image to the registry?" >> /tmp/progress.log
    exit 1
fi

export COSIGN_PASSWORD=""
if /usr/local/bin/cosign verify --insecure-ignore-tlog=true \
  --key /home/rhel/cosign.pub \
  ${REGISTRY}/rhhi-demo@${IMAGE_DIGEST} > /dev/null 2>&1; then
    echo "PASS: Image signature verified" >> /tmp/progress.log
    exit 0
else
    echo "FAIL: Image signature verification failed" >> /tmp/progress.log
    echo "HINT: Did you complete the cosign sign step? Verify your key and image digest are correct" >> /tmp/progress.log
    exit 1
fi
