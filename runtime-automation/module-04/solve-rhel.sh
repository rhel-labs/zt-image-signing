#!/bin/sh
echo "Solving module-04: SBOM Attestation" >> /tmp/progress.log

# Load environment variables from bashrc
. /home/rhel/.bashrc 2>/dev/null || true

export COSIGN_PASSWORD=""

# Attach the pre-generated SBOM as a signed attestation
cosign attest --tlog-upload=false \
  --yes --key /home/rhel/cosign.key \
  --predicate /home/rhel/scanning/rhhi-demo.spdx --type spdxjson \
  ${REGISTRY}/rhhi-demo@${IMAGE_DIGEST}

# Verify the attestation and check package count
cosign verify-attestation --insecure-ignore-tlog=true \
  --key /home/rhel/cosign.pub \
  --type spdxjson \
  ${REGISTRY}/rhhi-demo@${IMAGE_DIGEST} \
  | jq -r '.payload' | base64 -d | jq '.predicate.packages | length'

# Download the attestation for local inspection
cosign download attestation --output-file /home/rhel/cosign.sbom \
  ${REGISTRY}/rhhi-demo@${IMAGE_DIGEST}

# Verify the downloaded attestation matches
jq -r '.payload' /home/rhel/cosign.sbom | base64 -d | jq '.predicate.packages | length'

echo "module-04 solve complete" >> /tmp/progress.log
