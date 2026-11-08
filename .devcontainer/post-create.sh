#!/bin/bash
set -euo pipefail

if [ -n "${SDKMAN_DIR:-}" ] && [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
  :
elif [ -s "/usr/local/sdkman/bin/sdkman-init.sh" ]; then
  export SDKMAN_DIR="/usr/local/sdkman"
elif [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  export SDKMAN_DIR="$HOME/.sdkman"
else
  export SDKMAN_DIR="$HOME/.sdkman"
  curl -sSf "https://get.sdkman.io" | bash
fi

set +u
source "$SDKMAN_DIR/bin/sdkman-init.sh"
set -u

run_sdkman() {
  set +u
  sdk "$@"
  set -u
}

if [ ! -e "$SDKMAN_DIR/candidates/kotlin/current" ]; then
  run_sdkman install kotlin
fi

if [ ! -e "$SDKMAN_DIR/candidates/kotlin/current" ]; then
  kotlin_version=$(
    find "$SDKMAN_DIR/candidates/kotlin" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' |
      sort -V |
      tail -n 1
  )

  if [ -z "$kotlin_version" ]; then
    echo "Kotlin installation did not produce an installed candidate." >&2
    exit 1
  fi

  run_sdkman default kotlin "$kotlin_version"
fi
