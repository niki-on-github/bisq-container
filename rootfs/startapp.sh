#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export HOME=/data
export userhome="$HOME"
export JAVA_TOOL_OPTIONS="-Duser.home=/data"

id -a
mkdir -p /data/.local/share

exec /opt/bisq/bin/Bisq
