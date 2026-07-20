#!/bin/bash

# Check if gcloud CLI is already installed
if command -v gcloud &> /dev/null; then
    echo "Google Cloud CLI is already installed. Skipping installation."
else
    echo "Installing Google Cloud CLI..."

    # Pick the download for this machine's architecture
    case "$(uname -m)" in
        arm64) GCLOUD_ARCH="arm" ;;
        *)     GCLOUD_ARCH="x86_64" ;;
    esac
    GCLOUD_TARBALL="google-cloud-cli-darwin-${GCLOUD_ARCH}.tar.gz"
    GCLOUD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${GCLOUD_TARBALL}"

    if curl -sf "$GCLOUD_URL" -o "$GCLOUD_TARBALL" && \
       tar -xzf "$GCLOUD_TARBALL" -C "$HOME" && \
       "$HOME/google-cloud-sdk/install.sh" --quiet \
           --usage-reporting=false \
           --command-completion=true \
           --path-update=true \
           --rc-path="$HOME/.zshrc"; then
        echo "Google Cloud CLI installation complete."
    else
        echo "⚠ Google Cloud CLI installation failed. Continuing with remaining packages."
    fi
    rm -f "$GCLOUD_TARBALL"
fi
