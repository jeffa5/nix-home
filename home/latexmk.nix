pkgs: {
  xdg.configFile."latexmk/latexmkrc".text = ''
    $pdf_previewer = '${pkgs.zathura}/bin/zathura';
    $pdf_mode = 1;
  '';
}
