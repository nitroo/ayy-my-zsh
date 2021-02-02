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
}

initialize_history() {
    function _history_wrapper {
        local clear list
        zparseopts -E c=clear l=list

        if [[ -n "$clear" ]]; then
            # if -c provided, clobber the history file
            echo -n >| "$HISTFILE"
            fc -p "$HISTFILE"
            echo >&2 History file deleted.
        elif [[ -n "$list" ]]; then
            # if -l provided, run as if calling `fc' directly
            builtin fc "$@"
        else
            # unless a number is provided, show all history events (starting from 1)
            [[ ${@[-1]-} = *[0-9]* ]] && builtin fc -l "$@" || builtin fc -l "$@" 1
        fi
    }

    # Timestamp format
    case ${HIST_STAMPS-} in
        "mm/dd/yyyy") alias history='_history_wrapper -f' ;;
        "dd.mm.yyyy") alias history='_history_wrapper -E' ;;
        "yyyy-mm-dd") alias history='_history_wrapper -i' ;;
        "") alias history='_history_wrapper' ;;
        *) alias history="_history_wrapper -t '$HIST_STAMPS'" ;;
    esac

    [ -z "$HISTFILE" ] && HISTFILE="$ZDOTDIR/.zsh_history"
    [ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
    [ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

    ## History command configuration
    setopt extended_history       # record timestamp of command in HISTFILE
    setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
    setopt hist_ignore_dups       # ignore duplicated commands history list
    setopt hist_ignore_space      # ignore commands that start with space
    setopt hist_verify            # show command with history expansion to user before running it
    setopt share_history          # share command history data
}

initialize_directories() {
    # Set colors for ls
    alias ls="ls --color=tty"
    alias lsa='ls -lah'
    alias l='ls -lah'
    alias ll='ls -lh'
    alias la='ls -lAh'
}

initialize_plugins() {
    source $AMZ/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    source $AMZ/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
}

[[ -z $ZDOTDIR ]] && ZDOTDIR=$HOME
[[ -z $AMZ ]] && AMZ=${0%/*}

# Set editing mode to emacs
bindkey -e

initialize_prompt
initialize_history
initialize_directories
initialize_plugins
