#!/bin/sh

: ${REMOTE:=git@github.com:xzhavilla/xzhell.git}
: ${LOCAL:=$HOME/.xzhell}

hash git >/dev/null 2>&1 ||
{ echo xzh: git: command not found 2>/dev/null
  exit 127 }

env git clone --depth=1 $REMOTE $LOCAL &&
mkdir -p $HOME/bin &&
{ for file in $LOCAL/bin; do
	ln -s $LOCAL/bin/$file bin/$file 2>/dev/null || true
  done }
