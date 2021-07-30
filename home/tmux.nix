{
  enable = true;
  baseIndex = 1;
  clock24 = true;
  escapeTime = 0;
  keyMode = "vi";
  prefix = "M-m";
  terminal = "tmux-256color";
  secureSocket = false;
  extraConfig = ''
    bind r source-file ~/.tmux.conf \; display-message "Config reloaded..."

    # start new panes in current directory
    bind % split-window -h -c "#{pane_current_path}"
    bind '"' split-window -v -c "#{pane_current_path}"
    bind C new-window -c "#{pane_current_path}"

    # switch panes without prefix
    bind -n M-h select-pane -L
    bind -n M-l select-pane -R
    bind -n M-j select-pane -D
    bind -n M-k select-pane -U

    # create a new session
    unbind-key 'n'
    bind-key 'n' new-session

    # sync panes
    unbind-key 'p'
    bind-key 'p' setw synchronize-panes

    # VI mode
    bind-key -T copy-mode-vi 'v' send -X begin-selection
    bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel

    set-option -sa terminal-overrides ',alacritty:RGB'

    # enable mouse control
    set -g mouse on

    # start windows and panes at 1
    setw -g pane-base-index 1

    set -g visual-activity off
    set -g visual-bell off
    set -g visual-silence off
    setw -g monitor-activity off
    set -g bell-action none

    #  modes
    setw -g clock-mode-colour blue
    setw -g mode-style 'fg=colour1 bg=colour12 bold'

    # panes
    set -g pane-border-style 'bg=colour0 fg=colour2'
    set -g pane-active-border-style 'bg=colour0 fg=colour12'

    # statusbar
    set -g status-position bottom
    set -g status-justify left
    set -g status-style 'bg=#3a3a3a fg=colour15'
    set -g status-left '#[bold][#S] '
    set -g status-right ' #{?pane_synchronized,#[bg=blue]#[bold] Sync #[default],#[bg=#4e4e4e] Sync #[default]} #{?client_prefix,#[bg=blue]#[bold] Prefix #[default],#[bg=#4e4e4e] Prefix #[default]} #[bg=#4e4e4e,fg=colour15] %H:%M:%S %d/%m '
    set -g status-right-length 50
    set -g status-left-length 20
    set -g status-interval 1

    setw -g window-status-current-style 'fg=colour2 bg=#4e4e4e bold'
    setw -g window-status-current-format ' #I#[fg=colour15]:#[fg=colour15]#W#[fg=colour2]#F '

    setw -g window-status-last-style 'fg=colour4 bg=#4e4e4e bold'

    setw -g window-status-style 'fg=colour15 bg=#4e4e4e dim'
    setw -g window-status-format ' #I#[fg=colour15]:#[fg=colour15]#W#[fg=colour4]#F '

    setw -g window-status-bell-style 'fg=colour15 bg=colour1 bold'

    # messages
    set -g message-style 'fg=colour15 bg=colour4 bold'
  '';
}
