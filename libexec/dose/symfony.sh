#!/bin/sh

_x_namespace symfony

: ${SYMFONY_GUESTDIR:=.}

SYMFONY_HINT=composer.json
SYMFONY_COMPOSER=composer
SYMFONY_CONSOLE=bin/console

_symfony_container() {
	test -n "$DRYRUN" &&
	echo '$container' &&
	return

	printf "Searching for Symfony container... " >&2

	for service in $(_od_services); do
		_od_compose exec $service test -e $SYMFONY_GUESTDIR/$SYMFONY_HINT 2>/dev/null &&
		printf "\b\b\b\b: %s\n" "$service" >&2 &&
		echo $service &&
		return
	done

	echo >&2
	_x_yell container not found
	return 1
}

_symfony_exec() {
	_x_min_args 1 $#

	: ${symfony_exec_CONTAINER:=${SYMFONY_CONTAINER:-$(_symfony_container)}}
	test -z $symfony_exec_CONTAINER && exit 1

	_od_exec $symfony_exec_CONTAINER "$@"
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

	test -n "$DRYRUN" ||
	_symfony_console 2>/dev/null | grep doctrine:cache >/dev/null ||
	return $status

	_symfony_doctrine cache:clear-metadata
	_symfony_doctrine cache:clear-query
	_symfony_doctrine cache:clear-result
}

_symfony_doctrine() {
	_x_min_args 1 $#

	_symfony_console "doctrine:$@"
}

symfony_opts=$(_opts)
_opts() {
	echo S:$symfony_opts
}

_opt_S() {
	SYMFONY_CONTAINER=$1
}

_cmd_symfony_shell() {
	local container=$1

	: ${container:=${SYMFONY_CONTAINER:-$(_symfony_container)}}
	test -z $container && exit 1

	_od_shell $container
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

_cmd_symfony_exec() {
	_symfony_exec "$@"
}

_alias_symfony_x() {
	echo symfony_exec
}

_opts_symfony_exec() {
	echo "c:du:"
}

_opt_symfony_exec_c() {
	symfony_exec_CONTAINER="$@"
}

_opt_symfony_exec_d() {
	_opt_exec_d "$@"
}

_opt_symfony_exec_u() {
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

_cmd_symfony_doctrine() {
	_symfony_doctrine "$@"
}

_x_add_opt "-S CONTAINER" \
	"Docker container running Symfony [${SYMFONY_CONTAINER:-auto}]"

_x_add_cmd "${_x_ns}shell|${_x_ns}sh [-u USER] [CONTAINER]" \
	"Log into a container [${SYMFONY_CONTAINER:-"Symfony's"}];;\
-u Username or UID"
_x_add_cmd "${_x_ns}exec|${_x_ns}x [-d] [-c CONTAINER] [-u USER] COMMAND [ARGS]" \
	"Execute a command inside a container [${SYMFONY_CONTAINER:-"Symfony's"}];;\
-c Choose a different container;;\
-d Run command in the background;;\
-u Username or UID"
_x_add_cmd "${_x_ns}composer [COMMAND [ARGS]]" \
	"Run Composer into Symfony container"
_x_add_cmd "${_x_ns}symfony|${_x_ns}sf [COMMAND [ARGS]]" \
	"Execute Symfony command"
_x_add_cmd "${_x_ns}cache" \
	"Clear Symfony cache"
_x_add_cmd "${_x_ns}doctrine COMMAND [ARGS]" \
	"Execute Doctrine command"
