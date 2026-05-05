#!/bin/sh
echo "Solving module-04: SBOM Attestation" >> /tmp/progress.log

# Load REGISTRY from bashrc
. /home/rhel/.bashrc 2>/dev/null || true

# Look up the image digest from local podman storage
IMAGE_DIGEST=$(runuser -l rhel -c "podman inspect --format='{{.Digest}}' ${REGISTRY}/rhhi-demo:v1" 2>/dev/null)

# Attach the pre-generated SBOM as a signed attestation (run as rhel for registry auth context)
runuser -l rhel -c "COSIGN_PASSWORD='' /usr/local/bin/cosign attest --tlog-upload=false --yes --key /home/rhel/cosign.key --predicate /home/rhel/scanning/rhhi-demo.spdx --type spdxjson ${REGISTRY}/rhhi-demo@${IMAGE_DIGEST}" >> /tmp/progress.log 2>&1

echo "module-04 solve complete" >> /tmp/progress.log
