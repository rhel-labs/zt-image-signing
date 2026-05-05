#!/bin/bash
USER=rhel

echo "Starting setup for zt-image-signing" > /tmp/progress.log
echo "Adding wheel" > /root/post-run.log
usermod -aG wheel rhel

chmod 666 /tmp/progress.log

# Fetch setup files from the lab git repo
TMPDIR=/tmp/lab-setup-$$
git clone --single-branch --branch ${GIT_BRANCH:-main} --no-checkout \
  --depth=1 --filter=tree:0 ${GIT_REPO} $TMPDIR
git -C $TMPDIR sparse-checkout set --no-cone /setup-files
git -C $TMPDIR checkout
SETUP_FILES=$TMPDIR/setup-files

# Install cosign
COSIGN_VERSION=v2.6.3
curl -LO https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-amd64
install -m 755 cosign-linux-amd64 /usr/local/bin/cosign
rm cosign-linux-amd64
echo "Cosign installed" >> /tmp/progress.log

# Install syft (needed to pre-generate SBOM)
SYFT_VERSION=v1.42.4
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | \
  sh -s -- -b /usr/local/bin ${SYFT_VERSION}
echo "Syft installed" >> /tmp/progress.log

# Install Java and certbot
dnf install -y java-21-openjdk-devel certbot
echo "Dependencies installed" >> /tmp/progress.log

# Get ZeroSSL certificate for the registry hostname
# Credentials are not traced to avoid leaking to logs
set +x
certbot certonly \
  --eab-kid "${ZEROSSL_EAB_KEY_ID}" \
  --eab-hmac-key "${ZEROSSL_HMAC_KEY}" \
  --server "https://acme.zerossl.com/v2/DV90" \
  --standalone --preferred-challenges http \
  -d registry-"${GUID}"."${DOMAIN}" \
  --non-interactive --agree-tos -m trackbot@instruqt.com -v
rm -f /var/log/letsencrypt/letsencrypt.log
set -x
echo "SSL cert obtained" >> /tmp/progress.log

# Start unauthenticated SSL registry (no htpasswd - open access for lab)
REGISTRY_HOST="registry-${GUID}.${DOMAIN}"
podman run -d \
  --name registry \
  -p 443:5000 \
  -v /etc/letsencrypt/live/${REGISTRY_HOST}/fullchain.pem:/certs/fullchain.pem:ro \
  -v /etc/letsencrypt/live/${REGISTRY_HOST}/privkey.pem:/certs/privkey.pem:ro \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/fullchain.pem \
  -e REGISTRY_HTTP_TLS_KEY=/certs/privkey.pem \
  quay.io/mmicene/registry:2
echo "Registry started at ${REGISTRY_HOST}" >> /tmp/progress.log

# Write REGISTRY to rhel user's bashrc for persistence across terminal sessions
# Ensure the file is rhel-owned before writing so subsequent su -l rhel appends work
touch /home/rhel/.bashrc
chown rhel:rhel /home/rhel/.bashrc
echo "export REGISTRY=${REGISTRY_HOST}" >> /home/rhel/.bashrc

# Install Quarkus CLI via jbang for the rhel user
cat > /tmp/quarkus-install.sh <<'QEOF'
curl -Ls https://sh.jbang.dev | bash -s - trust add https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/
curl -Ls https://sh.jbang.dev | bash -s - app install --fresh --force quarkus@quarkusio
if ! grep -q '.jbang/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.jbang/bin:$PATH"' >> ~/.bashrc
fi
QEOF
chmod +x /tmp/quarkus-install.sh
su -l rhel -c /tmp/quarkus-install.sh

# Scaffold Quarkus project
su -l rhel -c "~/.jbang/bin/quarkus create app com.example:sample-app \
  --extension='rest,rest-jackson' --no-code"

# Copy application source files from the lab repo
mkdir -p /home/rhel/sample-app/src/main/java/com/example
cp $SETUP_FILES/quarkus/GreetingResource.java \
  /home/rhel/sample-app/src/main/java/com/example/
cp $SETUP_FILES/quarkus/application.properties \
  /home/rhel/sample-app/src/main/resources/
cp $SETUP_FILES/quarkus/Containerfile /home/rhel/sample-app/
cp $SETUP_FILES/quarkus/.dockerignore /home/rhel/sample-app/
chmod a+x /home/rhel/sample-app/mvnw
chmod -R a+rX /home/rhel/sample-app/.mvn/ /home/rhel/sample-app/src/
chmod a+r /home/rhel/sample-app/pom.xml
chown -R rhel:rhel /home/rhel

# Pull base images into rhel's rootless store
su -l rhel -c "podman pull registry.access.redhat.com/hi/openjdk:21-builder"
su -l rhel -c "podman pull registry.access.redhat.com/hi/openjdk:21-runtime"

# Pre-warm Maven dependency cache
su -l rhel -c "podman run --rm --net=host \
  -v /home/rhel/sample-app:/build:Z -w /build \
  registry.access.redhat.com/hi/openjdk:21-builder \
  ./mvnw dependency:resolve -q"

# Build rhhi-demo:v1 image
su -l rhel -c "podman build -t rhhi-demo:v1 \
  -f /home/rhel/sample-app/Containerfile /home/rhel/sample-app"
echo "rhhi-demo:v1 built" >> /tmp/progress.log

# Pre-generate SBOM via OCI archive export (no podman socket required)
su -l rhel -c "mkdir -p ~/scanning && podman save rhhi-demo:v1 --format oci-archive -o /tmp/rhhi-demo-oci.tar && syft oci-archive:/tmp/rhhi-demo-oci.tar -o spdx-json=~/scanning/rhhi-demo.spdx && rm /tmp/rhhi-demo-oci.tar"
echo "SBOM generated at ~/scanning/rhhi-demo.spdx" >> /tmp/progress.log

# Clean up temp files
rm -rf $TMPDIR /tmp/quarkus-install.sh

echo "Setup complete" >> /tmp/progress.log
