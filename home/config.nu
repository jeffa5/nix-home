alias cat = bat
alias g = git
alias ga = git add
alias gc = git commit -v
alias gd = git diff
alias gdm = git diff main
alias gst = git status
alias gl = git pull
alias glum = git pull upstream main
alias gp = git push
alias gpu = git push --set-upstream origin HEAD
alias gpf = git push --force-with-lease
alias gcm = git checkout main
alias grb = git rebase
alias grbm = git rebase main
alias grbc = git rebase --continue
alias grba = git rebase --abort
alias gsh = git show
alias glog = git log --oneline --graph
alias gco = git checkout
alias gcb = git checkout -b
alias gstp = git stash pop

$env.config = {
  edit_mode: vi
  cursor_shape: {
    vi_insert: line
    vi_normal: block
  }
}
