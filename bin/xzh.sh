#!/bin/sh

SELF=$(realpath $0)
PATH=$PATH:${SELF%/*}
. ${SELF%/*}/../lib/xzh.sh

_cmd_update() {
	${SELF%/*}/../tools/update.sh
}

_alias_up() {
	echo update
}

_x_add_cmd "update|up" \
	"Update xzhell"

_x_run_cmd "$@"
