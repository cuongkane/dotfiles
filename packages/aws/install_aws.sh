#!/bin/bash

# Check if AWS CLI is already installed
if command -v aws &> /dev/null; then
    echo "AWS CLI is already installed. Skipping installation."
else
    echo "Installing AWS CLI..."
    if curl -sf "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg" && \
       sudo installer -pkg AWSCLIV2.pkg -target /; then
        echo "AWS CLI installation complete."
    else
        echo "⚠ AWS CLI installation failed. Continuing with remaining packages."
    fi
    rm -f AWSCLIV2.pkg
fi
