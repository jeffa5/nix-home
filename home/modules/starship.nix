{...}: {
  programs.starship = {
    enable = true;

    settings = {
      kubernetes.disabled = false;
    };
  };
}
