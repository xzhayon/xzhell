#!/bin/sh

: ${REMOTE:=https://github.com/xzhavilla/xzhell.git}
: ${LOCAL:=$HOME/.xzhell}

( if test -d $LOCAL; then
	cd $LOCAL &&
	git checkout . &&
	env git pull --rebase --stat origin master
  else
	env git clone --depth=1 $REMOTE $LOCAL
  fi ) &&
sed -i.orig 's,^SELF=\$0,SELF='$LOCAL/bin/realpath',' $LOCAL/bin/realpath &&
rm -f $LOCAL/bin/realpath.orig &&
mkdir -p $HOME/bin && {
	for file in $LOCAL/bin/*; do
		ln -s $LOCAL/bin/${file##*/} bin/ 2>/dev/null || true
	done
}
