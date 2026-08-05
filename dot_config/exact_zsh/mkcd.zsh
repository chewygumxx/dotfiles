mkcd () {
	\builtin command mkdir -p "$1"
	\builtin cd "$1"
}
    
mkdirt () {
	while (( $# ))
	do
		\builtin command mkdir -p "$1"
		\builtin command touch "$1/.keep"
		shift
	done
}
