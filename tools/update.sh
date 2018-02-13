#!/bin/sh

: ${SCRIPT:=https://raw.githubusercontent.com/xzhavilla/xzhell/master/tools/install.sh}

sh -c "$(curl -fsSL $SCRIPT)"
