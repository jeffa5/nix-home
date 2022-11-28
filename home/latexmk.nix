pkgs: {
  xdg.configFile."latexmk/latexmkrc".text = ''
    $pdf_previewer = '${pkgs.evince}/bin/evince';
    $pdf_mode = 1;
  '';
}
