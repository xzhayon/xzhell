#!/bin/sh

SELF=$0
PATH=$PATH:${SELF%/*}
source ${SELF%/*}/../lib/xzh.sh

_error() {
	_x_yell $*
	status=1
}

_realpath() {
	local path=${1%/}
	local dir=$(dirname "$path")
	local target=$(readlink "$path" || echo "$path")

	_x_is_abs "$target" ||
	target=$(cd "$dir" && pwd)/${path##*/}

	test -f "$target" &&
	( cd $(dirname "$target")
	  echo $(pwd -P)/${target##*/} ) ||
	( cd $target
	  pwd -P )
}

_cmd() {
	_x_min_args 1 $#

	status=0
	for file in "$@"; do
		test ! -e "$file" &&
		_error $file: no such file or directory && continue

		_realpath "$file" | sed 's,//,/,'
	done

	_x_die $status
}

_usage() {
	echo usage: $(_x_self) FILE...
}

_x_run "$@"
