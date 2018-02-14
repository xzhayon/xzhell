#!/bin/sh

: ${REMOTE:=https://github.com/xzhavilla/xzhell.git}
: ${LOCAL:=$HOME/.xzhell}
: ${TARGET:=$HOME/bin}

BINDIR=$LOCAL/bin
REALPATH=$BINDIR/realpath.sh

__pull_repository() {
	cd $LOCAL &&
	env git checkout . &&
	env git pull --rebase --stat origin master
}

__clone_repository() {
	env git clone --depth=1 $REMOTE $LOCAL
}

_fetch_repository() {
	if test -d $LOCAL; then
		__pull_repository
	else
		__clone_repository
	fi
}

_hardcode_path() {
	sed -i.orig 's,^SELF=\$0,SELF='$REALPATH',' $REALPATH
}

_link_binaries() {
	mkdir -p $TARGET &&
	for file in $BINDIR/*.sh; do
		local cmd=${file##*/}
		cmd=${cmd%.sh}
		ln -s $file $TARGET/$cmd 2>/dev/null || true
	done
}

_fetch_repository &&
_hardcode_path &&
_link_binaries
