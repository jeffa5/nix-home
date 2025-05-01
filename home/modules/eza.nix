{...}: {
  programs.eza = {
    enable = true;
    # doesn't work well with nushell as it doesn't output a table
    enableNushellIntegration = false;
  };
}
