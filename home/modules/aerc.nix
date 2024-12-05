{
  pkgs,
  lib,
  ...
}: let
  aerc-filters = "${pkgs.aerc}/libexec/aerc/filters";
  sd = lib.getExe pkgs.sd;
  aerc-opener-html = pkgs.writeShellScriptBin "aerc-opener-html" ''
    ${sd} -f i ' src' ' _src' "$1"
    ${sd} -f i '<script(.|\n)*?\/script>' ''' "$1"
    xdg-open "$1"
  '';
in {
  programs.aerc.enable = true;
  programs.aerc.stylesets = {
    home = let
      gray = 8;
    in {
      "*.selected.bg" = gray;
      "statusline_*.dim" = false;
      "msglist_read.selected.bold" = false;
      "border.fg" = gray;
      "title.bg" = gray;
      "msglist_pill.bg" = gray;
      "part_mimetype.default" = true;
      "part_mimetype.bold" = true;
      "selector_focused.fg" = gray;
      "header.default" = true;
    };
  };
  programs.aerc.templates = {
    my_quoted_reply = ''
      X-Mailer: aerc {{version}}

      On {{dateFormat (.OriginalDate | toLocal) "Mon Jan 2, 2006 at 3:04 PM MST"}}, {{.OriginalFrom | names | join ", "}} wrote:
      {{if eq .OriginalMIMEType "text/html"}}
      {{exec `${pkgs.aerc}/libexec/aerc/filters/html` .OriginalText | wrap 72 | quote}}
      {{else}}
      {{trimSignature .OriginalText | wrap 72 | quote}}
      {{end}}
      {{- with .Signature }}

      {{.}}
      {{- end }}
    '';
    my_forward_as_body = ''
      X-Mailer: aerc {{version}}

      Forwarded message from {{.OriginalFrom | names | join ", "}}  on {{dateFormat .OriginalDate "Mon Jan 2, 2006 at 3:04 PM"}}:
      {{if eq .OriginalMIMEType "text/html"}}
      {{exec `${pkgs.aerc}/libexec/aerc/filters/html` .OriginalText}}
      {{else}}
      {{trimSignature .OriginalText}}
      {{end}}
      {{- with .Signature }}

      {{.}}
      {{- end }}
    '';
  };
  programs.aerc.extraConfig = {
    general.unsafe-accounts-conf = true;
    ui = {
      timestamp-format = "02 Jan 2006";
      this-day-time-format = "15:04";
      this-week-time-format = "02 Jan";
      this-year-time-format = "02 Jan";
      sidebar-width = 30;
      sort = "-r date";
      styleset-name = "home";

      threading-enabled = true;
      mouse-enabled = true;
      tab-title-account = "{{.Account}} {{if .Unread}}({{.Unread}}){{end}}";
      dirlist-tree = true;
      auto-mark-read = false;
      fuzzy-complete = true;
    };
    compose = {
      address-book-cmd = "khard email --remove-first-line --parsable '%s'";
      edit-headers = true;
      empty-subject-warning = true;
      no-attachment-warning = "^[^>]*attach(ed|ment)";
    };
    filters = {
      "subject,~^\\[PATCH" = "${aerc-filters}/hldiff";
      "text/html" = "${aerc-filters}/html";
      "text/plain" = "${aerc-filters}/wrap | ${aerc-filters}/plaintext";
      "text/calendar" = "${aerc-filters}/calendar";
    };
    templates = {
      quoted-reply = "my_quoted_reply";
      forwards = "my_forward_as_body";
    };
    openers = {
      "text/html" = lib.getExe aerc-opener-html;
    };
  };

  xdg.configFile."aerc/binds.conf".text = ''
    <C-h> = :prev-tab<Enter>
    <C-n> = :next-tab<Enter>
    <C-l> = :change-tab -<Enter>
    <C-t> = :term<Enter>

    [messages]
    q = :quit<Enter>

    j = :next<Enter>
    <Down> = :next<Enter>
    <C-d> = :next 50%<Enter>
    <C-f> = :next 100%<Enter>
    <PgDn> = :next -s 100%<Enter>

    k = :prev<Enter>
    <Up> = :prev<Enter>
    <C-u> = :prev 50%<Enter>
    <C-b> = :prev 100%<Enter>
    <PgUp> = :prev -s 100%<Enter>
    g = :select 0<Enter>
    G = :select -1<Enter>

    J = :next-folder<Enter>
    K = :prev-folder<Enter>

    <Enter> = :view<Enter>
    l = :view<Enter>
    d = :read<Enter>:move Deleted<Enter>

    C = :compose<Enter>

    rr = :reply -a<Enter>
    rq = :reply -aq<Enter>
    Rr = :reply<Enter>
    Rq = :reply -q<Enter>

    c = :cf<space>
    $ = :term<space>
    ! = :term<space>
    | = :pipe<space>

    a = :read<Enter>:archive flat<Enter>
    / = :search<space>
    \ = :filter<space>
    n = :next-result<Enter>
    N = :prev-result<Enter>

    t = :read -t<Enter>
    f = :fold -t<Enter>

    <space> = :mark -t<Enter>:next<Enter>
    ma = :mark -at<Enter>

    A = :pipe khard add-email -H all<Enter>

    s = :exec mu find --clearlinks --format=links --linksdir=~/mail/search/results<space>

    [view]
    q = :close<Enter>
    | = :pipe<space>
    f = :forward<Enter>
    D = :delete<Enter>
    rr = :reply -a<Enter>
    rq = :reply -aq<Enter>
    Rr = :reply<Enter>
    Rq = :reply -q<Enter>
    <C-k> = :prev-part<Enter>
    <C-j> = :next-part<Enter>
    S = :save<space>

    h = :close<Enter>
    o = :open<Enter>
    a = :read<Enter>:archive flat<Enter>:close<Enter>
    d = :read<Enter>:move Deleted<Enter>
    u = :pipe -p ${pkgs.urlscan}/bin/urlscan<Enter>
    c = :pipe -p ${lib.getExe pkgs.khal} import --batch<Enter>
    J = :next-message<Enter>
    K = :prev-message<Enter>

    [compose]
    <C-k> = :prev-field<Enter>
    <C-j> = :next-field<Enter>
    <C-q> = :abort<Enter>

    [compose::editor]
    $noinherit = true
    $ex = <C-x>
    <C-k> = :prev-field<Enter>
    <C-j> = :next-field<Enter>
    <C-p> = :prev-tab<Enter>
    <C-n> = :next-tab<Enter>
    <C-q> = :abort<Enter>

    [compose::review]
    y = :send<Enter>
    n = :abort<Enter>
    q = :abort<Enter>
    p = :postpone<Enter>
    e = :edit<Enter>
    a = :attach<space>
    <C-q> = :abort<Enter>

    [terminal]
    $noinherit = true
    $ex = <semicolon>

    <C-p> = :prev-tab<Enter>
    <C-n> = :next-tab<Enter>

    <C-q> = :close<Enter>
  '';
}
