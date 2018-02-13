fmt() {
	which fmt >/dev/null 2>&1 && {
		command fmt "$@"
		exit
	}

	echo "$@"
}

tput() {
	which tput >/dev/null 2>&1 && {
		command tput "$@"
		exit
	}

	test "$1" != "cols" && exit 1

	echo 80
}
