_TAB_SIZE=8
_USAGE_PAD=2
_USAGE_MIN_LENGTH=20

_OPTS_PARSED=0

trap _x_die 2

_x_is_abs() {
	case $1 in
	/*) return 0 ;;
	*) return 1 ;;
	esac
}

_x_is_cmd() {
	declare -f -F $1 >/dev/null
}

_x_width() {
	echo ${COLUMNS-$(tput cols)}
}

_x_self() {
	echo ${0##*/}
}

_x_is_piped_in() {
	test ! -t 0
}

_x_is_piped_out() {
	test ! -t 1
}

_x_die() {
	exit ${1:-1}
}

_x_yell() {
	echo $(_x_self): $* >&2
}

__undef() {
	_x_yell $1: command not found
	_x_die 127
}

_x_min_args() {
	test $2 -ge $1 || __usage
}

_x_namespace() {
    _x_no_execute && return
    _NS=$1
}

_x_require() {
    local _x_ns=_
    __import "$1"
    _x_ns=
}

_x_no_execute() {
    test "$_x_ns" = "_"
}

_x_extend() {
    _x_no_execute && return
	_CMD_EXTENDED="$@"
}

_x_use() {
    _x_no_execute && return

    local file="${1##*:}"
    local ns=${1%%:*}
    test "$ns" = "$file" && ns=

    local _x_ns
    test -n "$ns" && _x_ns="$ns:" || _x_ns=
    __import "$file"
    _x_ns=

    test -n "$_NS" &&
    eval "_NS_$ns=${_NS}_"
    _NS=
}

__import() {
    local filename="${1##*/}"

    case "$_FILES_IMPORTED" in
    *" $filename "*) return ;;
    esac

    _FILES_IMPORTED="$_FILES_IMPORTED  $filename  "
    source "$1"
}

__usage() {
	local opts cmd args

	test -n "$_OPTS" && opts=" [OPTIONS]"
	test -n "$_CMDS" && cmd=" COMMAND"
	args=" [ARGS]"

	( ( _x_is_cmd _usage &&
	    _usage ||
	    echo usage: $(_x_self)$opts$cmd$args ) | fmt -nw $(_x_width)

	  __usage_opts
	  __usage_cmds ) >&2

	_x_die 2
}

__usage_cols() {
	local max_length=$(echo "$@" | while read line; do
		test -n "$line" || continue
		printf "%s" "${line%%$'\t'*}" | wc -c
	done | sort -nr | head -1)

	local col1_size=$(($_TAB_SIZE * ((($max_length + 1) / $_TAB_SIZE) + 1)))
	local col2_size=$(($(_x_width) - $col1_size - $_USAGE_PAD))

	test $col2_size -lt $_USAGE_MIN_LENGTH &&
	col2_size=$(($(_x_width) - $_USAGE_PAD * 2)) &&
	local is_small=1

	echo "$@" | while read line; do
		test -n "$line" || continue

		term=${line%%$'\t'*}
		desc=${line#*$'\t'}
		test "$desc" = "$term" && desc=""

		test -n "$is_small" &&
		test -n "$desc" &&
		desc="\n$desc\n\n."

		echo "$desc" |
		sed 's,;;,\
\
,g' |
		fmt -nw $col2_size |
		while read desc_line; do
			test -n "$term" ||
			test -n "$desc_line" ||
			continue

			test "$desc_line" = "." &&
			desc_line=""

			test -n "$is_small" &&
			test ! -n "$term" &&
			col1_current_size=$(($(_x_width) - $col2_size - $_USAGE_PAD)) ||
			col1_current_size=$col1_size

			test $col1_current_size -lt 0 &&
			col1_current_size=0

			printf "%${_USAGE_PAD}s%-${col1_current_size}s%s\n" " " "$term" "$desc_line" |
			fmt -nw $(_x_width)

			term=""
		done
	done
}

__usage_opts() {
	test -n "$_OPTS" || return

	echo "\noptions:"
	__usage_cols "$_OPTS"
}

__usage_cmds() {
	test -n "$_CMDS" || return

	echo "\ncommands:"
	__usage_cols "$_CMDS"
}

_x_add_opt() {
    _x_no_execute && return
	_OPTS="$_OPTS$1\t$2\n"
}

_x_add_cmd() {
    _x_no_execute && return
	_CMDS="$_CMDS$1\t$2\n"
}

__parse_opts() {
	local cmd=$1
	shift

	test -n "$cmd" && cmd=_$cmd
	_x_is_cmd _opts$cmd || return 0

	OPTIND=1
	while getopts "$(_opts$cmd)" opt; do
		test $opt != ? || __usage
		_x_is_cmd _opt${cmd}_$opt || __undef _opt${cmd}_$opt
		_opt${cmd}_$opt "$OPTARG"
	done

	return $(($OPTIND - 1))
}

_x_parse_opts() {
    _x_no_execute && return

	__parse_opts "" "$@"
	_OPTS_PARSED=$?
}

_x_run() {
    _x_no_execute && return

	shift $_OPTS_PARSED
	__parse_opts "" "$@"
	shift $?

	_x_is_cmd _cmd || __undef _cmd
	_cmd "$@"
}

_x_run_cmd() {
    _x_no_execute && return

    shift $_OPTS_PARSED
	__parse_opts "" "$@"
	shift $?

	_x_min_args 1 $#

	local cmd=${1##*:}
	local ns=${1%%:*}
	shift

	test "$ns" = "$cmd" && ns=
	eval "local tmpcmd=\${_NS_$ns}$cmd"

	test -n "$ns" ||
	( _x_is_cmd _cmd_$tmpcmd ||
	  _x_is_cmd _alias_$tmpcmd ) &&
	cmd=$tmpcmd

	_x_is_cmd _alias_$cmd &&
	cmd=$(_alias_$cmd)

	__parse_opts $cmd "$@"
	shift $?

	if ! _x_is_cmd _cmd_$cmd; then
		test ! -n "$_CMD_EXTENDED" &&
		__undef _cmd_$cmd

		$_CMD_EXTENDED $cmd "$@"
	else
		_cmd_$cmd "$@"
	fi
}
