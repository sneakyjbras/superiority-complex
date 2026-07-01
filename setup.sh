#!/usr/bin/env bash
# Back-compat shim: the entry point is now install.sh. Forwards all arguments.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install.sh" "$@"
