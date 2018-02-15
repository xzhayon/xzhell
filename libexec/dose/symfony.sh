#!/bin/sh

_x_namespace symfony

: ${SYMFONY_GUESTDIR:=.}

SYMFONY_HINT=composer.json
SYMFONY_COMPOSER=composer
SYMFONY_CONSOLE=bin/console

_symfony_container() {
	echo Searching for Symfony container... >&2

	for service in $(_od_services); do
		_od_exec $service test -e $SYMFONY_GUESTDIR/$SYMFONY_HINT 2>/dev/null &&
		echo $service &&
		break
	done
}

_symfony_exec() {
	_od_exec ${SYMFONY_CONTAINER:-$(_symfony_container)} "$@"
}

_symfony_composer() {
	_symfony_exec $SYMFONY_COMPOSER "$@"
}

_symfony_console() {
	_symfony_exec $SYMFONY_GUESTDIR/$SYMFONY_CONSOLE "$@"
}

_symfony_cache() {
	_symfony_console cache:clear
	status=$?

	_symfony_console | grep -q doctrine:cache ||
	return $status

	_symfony_console doctrine:cache:clear-metadata
	_symfony_console doctrine:cache:clear-query
	_symfony_console doctrine:cache:clear-result
}

symfony_opts=$(_opts)
_opts() {
	echo C:S:$symfony_opts
}

_opt_C() {
	SYMFONY_CONTAINER=$1
}

_opt_S() {
	SYMFONY_GUESTDIR=$1
}

_cmd_symfony_shell() {
	_od_shell ${1:-${SYMFONY_CONTAINER:-$(_symfony_container)}}
}

_alias_symfony_sh() {
	echo symfony_shell
}

_opts_symfony_shell() {
	echo "u:"
}

_opt_symfony_shell_u() {
	_opt_exec_u "$@"
}

_cmd_symfony_composer() {
	_symfony_composer "$@"
}

_cmd_symfony_symfony() {
	_symfony_console "$@"
}

_alias_symfony_sf() {
	echo symfony_symfony
}

_cmd_symfony_cache() {
	_symfony_cache
}

_x_add_opt "-C CONTAINER" \
	"Docker container running Symfony [${SYMFONY_CONTAINER:-auto}]"
_x_add_opt "-S SYMFONYDIR" \
	"Symfony directory in Docker container [$SYMFONY_GUESTDIR]"

_x_add_cmd "${_x_ns}shell|${_x_ns}sh [-u USER] [CONTAINER]" \
	"Log into a container [${SYMFONY_CONTAINER:-"Symfony's"}];;\
-u Username or UID"
_x_add_cmd "${_x_ns}composer [COMMAND [ARGS]]" \
	"Run Composer into Symfony container"
_x_add_cmd "${_x_ns}symfony|${_x_ns}sf [COMMAND [ARGS]]" \
	"Execute Symfony command"
_x_add_cmd "${_x_ns}cache" \
	"Clear Symfony cache"
