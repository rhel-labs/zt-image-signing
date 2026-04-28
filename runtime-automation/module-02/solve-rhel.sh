#!/bin/sh
echo "Solving module-02: Push and Generate Keys" >> /tmp/progress.log

# Load REGISTRY from bashrc if not already set
if [ -z "$REGISTRY" ]; then
    . /home/rhel/.bashrc 2>/dev/null || true
fi

# Tag the pre-built image for the local registry
podman tag rhhi-demo:v1 ${REGISTRY}/rhhi-demo:v1

# Push to the local registry
podman push ${REGISTRY}/rhhi-demo:v1

# Capture the image digest
IMAGE_DIGEST=$(podman inspect --format='{{.Digest}}' ${REGISTRY}/rhhi-demo:v1)

# Persist to bashrc for subsequent terminal sessions
grep -v 'IMAGE_DIGEST' /home/rhel/.bashrc > /tmp/bashrc.tmp && mv /tmp/bashrc.tmp /home/rhel/.bashrc
echo "export IMAGE_DIGEST=${IMAGE_DIGEST}" >> /home/rhel/.bashrc

echo "Image digest: ${IMAGE_DIGEST}" >> /tmp/progress.log

# Generate cosign key pair with empty password
export COSIGN_PASSWORD=""
cd /home/rhel && cosign generate-key-pair

echo "module-02 solve complete" >> /tmp/progress.log
