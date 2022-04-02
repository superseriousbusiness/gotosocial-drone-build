#!/bin/sh

set -eu

# clone the repo
git clone --mirror ${ORIGIN_REPO} .

# configure git credentials
git config --global user.email "${CODEBERG_EMAIL}"
git config credential.helper store
printf "https://${CODEBERG_USER}:${CODEBERG_TOKEN}@codeberg.org\n" >> ~/.git-credentials

# push mirror
git push --mirror ${TARGET_REPO}

# clean up
rm ~/.git-credentials
