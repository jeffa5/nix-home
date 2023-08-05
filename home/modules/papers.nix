{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.papers];

  home.file = {
    ".config/papers/config.yaml".text = ''
      default_repo: ${config.home.homeDirectory}/Cloud/papers
      paper_defaults:
        tags:
          - '#new'
      notes_template:
        content: |
          ## One sentence summary

          ## Paper summary

          ## Strengths

          ## Weaknesses

          ## Comments
    '';
  };
}
