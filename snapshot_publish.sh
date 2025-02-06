#!/bin/sh

set -eu

# Set up minio CLI using provided credentials.
S3_ACCESS_KEY_ID="${S3_ACCESS_KEY_ID:-$(cat s3accesskeyid)}"
S3_SECRET_ACCESS_KEY="${S3_SECRET_ACCESS_KEY:-$(cat s3secretaccesskey)}"
S3_HOSTNAME="${S3_HOSTNAME:-}"
S3_BUCKET_NAME="${S3_BUCKET_NAME:-}"

# Alias s3 to the destination host.
mc alias set s3 "${S3_HOSTNAME}" "${S3_ACCESS_KEY_ID}" "${S3_SECRET_ACCESS_KEY}"

# Copy dist folder (from goreleaser)
# to a temporary folder for editing.
cp -r "./dist" "./dist-s3"

# Parse current build version number.
BUILD_VERSION="$(cat ./dist-s3/metadata.json | jq -r .version)"

# Use build version number to strip version
# metadata out of the build .tar.gz files.
# It's unnecessary since we'll be storing
# files in s3 keyed by the commit hash.
#
# Example:
#   gotosocial_0.11.0-SNAPSHOT_linux_armv6.tar.gz
# becomes:
#   gotosocial_linux_armv6.tar.gz
for f in ./dist-s3/gotosocial_*.tar.gz
    do mv "${f}" "$(echo ${f} | sed "s/_${BUILD_VERSION}//")"
done

# Modify checksums to use the new filenames.
sed -i "s/_${BUILD_VERSION}//" "./dist-s3/checksums.txt"

# Modify checksums to remove source code tar.gz.
sed -i "/gotosocial-${BUILD_VERSION}-source-code.tar.gz/d" "./dist-s3/checksums.txt"

# Mirror dist folder, but only tar.gz and
# checksum files, ignore everything else.
mc mirror \
    --overwrite \
    --remove \
    --exclude "config.yaml" \
    --exclude "artifacts.json" \
    --exclude "metadata.json" \
    --exclude "*source-code.tar.gz" \
    --exclude "gotosocial_freebsd_amd64_v1/gotosocial" \
    --exclude "gotosocial_freebsd_arm64/gotosocial" \
    --exclude "gotosocial_linux_amd64_v1/gotosocial" \
    --exclude "gotosocial_linux_arm64/gotosocial" \
    --exclude "gotosocial_netbsd_amd64_v1/gotosocial" \
    --exclude "gotosocial_netbsd_arm64/gotosocial" \
    --exclude "gotosocial_nowasm_freebsd_amd64_v1/gotosocial" \
    --exclude "gotosocial_nowasm_linux_386/gotosocial" \
    --exclude "gotosocial_nowasm_linux_amd64_v1/gotosocial" \
    --exclude "gotosocial_nowasm_linux_arm_6/gotosocial" \
    --exclude "gotosocial_nowasm_linux_arm64/gotosocial" \
    --exclude "gotosocial_nowasm_linux_arm_7/gotosocial" \
    "./dist-s3" "s3/${S3_BUCKET_NAME}/$(git rev-parse HEAD)"

# Clean up.
mc alias rm s3
rm -r "./dist-s3"
