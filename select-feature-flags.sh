#!/usr/bin/env bash
# Copies the feature flags of one environment to where a build expects them, after checking that
# every environment file lists the same flags (so a new flag can't be forgotten in one environment).
#
# Usage: select-feature-flags.sh <development|preproduction|production> <destination file>
set -euo pipefail

ENVIRONMENTS=(development preproduction production)
FLAGS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/feature-flags"

environment="${1:-}"
destination="${2:-}"

if [[ -z "$environment" || -z "$destination" ]]; then
    echo "Usage: $0 <${ENVIRONMENTS[*]// /|}> <destination file>" >&2
    exit 1
fi

if [[ " ${ENVIRONMENTS[*]} " != *" $environment "* ]]; then
    echo "Unknown environment '$environment'. Expected one of: ${ENVIRONMENTS[*]}" >&2
    exit 1
fi

# Flag names are the indented keys under "features:", comments ignored.
flag_names() {
    grep -E '^[[:space:]]+[^#[:space:]][^:]*:' "$1" | sed -E 's/^[[:space:]]+([^:]+):.*/\1/' | sort
}

reference="${ENVIRONMENTS[0]}"
for env in "${ENVIRONMENTS[@]}"; do
    if [[ ! -f "$FLAGS_DIR/$env.yaml" ]]; then
        echo "Missing feature flag file: feature-flags/$env.yaml" >&2
        exit 1
    fi
    if [[ "$(flag_names "$FLAGS_DIR/$env.yaml")" != "$(flag_names "$FLAGS_DIR/$reference.yaml")" ]]; then
        echo "feature-flags/$reference.yaml and feature-flags/$env.yaml don't list the same flags:" >&2
        diff <(flag_names "$FLAGS_DIR/$reference.yaml") <(flag_names "$FLAGS_DIR/$env.yaml") >&2 || true
        exit 1
    fi
done

mkdir -p "$(dirname "$destination")"
cp "$FLAGS_DIR/$environment.yaml" "$destination"
echo "Using $environment feature flags ($destination):"
grep -E '^[[:space:]]+[^#[:space:]]' "$destination"
