#!/bin/bash
set -e

export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

mkdir -p assets/config
sops decrypt secrets.sops.yaml > assets/config/secrets.yaml

echo "Decrypted to assets/config/secrets.yaml"
