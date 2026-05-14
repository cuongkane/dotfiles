#!/usr/bin/env bash
set -e

if command -v rtk &>/dev/null; then
  rtk init -g
fi
