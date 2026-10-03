fish_add_path $HOME/.local/bin
if status is-interactive
    fastfetch
end
thefuck --alias | source
starship init fish | source
