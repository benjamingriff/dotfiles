
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/benjamingriffiths/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/benjamingriffiths/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/benjamingriffiths/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/benjamingriffiths/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="/opt/homebrew/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(starship init zsh)"

alias dotfiles="nvim ~/repos/dotfiles/"
alias wd="cd ~/pep-repos"
alias pd="cd ~/repos"
alias lg="lazygit"
alias dn="cd ~/Downloads"
alias pep="cd '$HOME/OneDrive - PEP Health'"
alias doc="cd ~/Documents" 
alias tech="cd '$HOME/Library/CloudStorage/OneDrive-SharedLibraries-PEPHealth/Tech - Tech'"
alias oc="opencode"

export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
export GOPATH=$HOME/go

# bun completions
[ -s "/Users/benjamingriffiths/.bun/_bun" ] && source "/Users/benjamingriffiths/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
export TMPDIR="$HOME/.cache/tmp"
