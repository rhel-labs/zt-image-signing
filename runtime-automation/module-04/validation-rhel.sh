#!/bin/sh
echo "Validating module-04: SBOM Attestation" >> /tmp/progress.log

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

export COSIGN_PASSWORD=""

# Verify the SBOM attestation exists and is valid
ATTEST_OUTPUT=$(cosign verify-attestation --insecure-ignore-tlog=true \
  --key /home/rhel/cosign.pub \
  --type spdxjson \
  ${REGISTRY}/rhhi-demo@${IMAGE_DIGEST} 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "FAIL: SBOM attestation verification failed"
    echo "HINT: Make sure you ran 'cosign attest' with the spdxjson predicate"
    exit 1
fi

# Check that the package count is greater than 100 (sanity check for real SBOM)
PKG_COUNT=$(echo "$ATTEST_OUTPUT" | jq -r '.payload' | base64 -d | jq '.predicate.packages | length')
if [ -z "$PKG_COUNT" ] || [ "$PKG_COUNT" -lt 100 ]; then
    echo "FAIL: SBOM package count ($PKG_COUNT) is less than expected"
    echo "HINT: Verify the SBOM at ~/scanning/rhhi-demo.spdx is valid and was generated from rhhi-demo:v1"
    exit 1
fi

echo "PASS: SBOM attestation verified with ${PKG_COUNT} packages"
exit 0
