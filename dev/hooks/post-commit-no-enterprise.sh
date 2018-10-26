#!/bin/bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

remote_url=TODO local_sha="$(git rev-parse HEAD) ./dev/hooks/check-no-enterprise.sh
