#!/bin/bash

set -euo pipefail

# ignore the global and user git configuration settings for these tests
GIT=HOME=/dev/null GIT_CONFIG_NOSYSTEM=1 git"

$GIT show
