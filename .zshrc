
initialize_prompt() {
    # Collapse working directory parents into single letter segments.
    # (e.g.) turns abc/def/ghi/jkl into a/d/g/jkl
    _collapsed_working_dir() {
        local i pwd

        # replace $HOME with ~, split working dir into array of dir segments.
        pwd=("${(s:/:)PWD/#$HOME/~}")
        for i in {1..$(($#pwd-1))}; do
            # use the first letter from all directories besides current.
            if [[ "$pwd[$i]" = .* ]]; then
                pwd[$i]="${${pwd[$i]}[1,2]}"
            else
                pwd[$i]="${${pwd[$i]}[1]}"
            fi
        done

        # join dir segments with a /
        echo "${(j:/:)pwd}"
    }

    _CLR_RESET=white

    setopt prompt_subst
    PROMPT='%n@%M %F{green}$(_collapsed_working_dir)%F{$_CLR_RESET}> '

    # Set colors for ls
    alias ls="ls --color=tty"
}

initialize_prompt