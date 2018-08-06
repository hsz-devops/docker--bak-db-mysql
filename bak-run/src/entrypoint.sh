#!/usr/bin/env bash
set -eu
set -x

# Blocking all other entrypoint from base images, since the only reason
# we are using base MySQL Server image is to have correct mysqldump binaries

exec "$@"
