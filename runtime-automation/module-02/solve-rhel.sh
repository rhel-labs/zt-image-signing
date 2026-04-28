#!/bin/sh
echo "Solving module-02: Push and Generate Keys" >> /tmp/progress.log

runuser -l rhel << 'RHEL_EOF'
. ~/.bashrc
podman tag rhhi-demo:v1 ${REGISTRY}/rhhi-demo:v1
podman push ${REGISTRY}/rhhi-demo:v1
IMAGE_DIGEST=$(podman inspect --format='{{.Digest}}' ${REGISTRY}/rhhi-demo:v1)
echo "${IMAGE_DIGEST}" > /tmp/image_digest.txt
export COSIGN_PASSWORD=""
cd ~
cosign generate-key-pair
RHEL_EOF

IMAGE_DIGEST=$(cat /tmp/image_digest.txt 2>/dev/null)
rm -f /tmp/image_digest.txt
grep -v 'IMAGE_DIGEST' /home/rhel/.bashrc > /tmp/bashrc.tmp && mv /tmp/bashrc.tmp /home/rhel/.bashrc
echo "export IMAGE_DIGEST=${IMAGE_DIGEST}" >> /home/rhel/.bashrc
chown rhel:rhel /home/rhel/.bashrc

echo "Image digest: ${IMAGE_DIGEST}" >> /tmp/progress.log
echo "module-02 solve complete" >> /tmp/progress.log
