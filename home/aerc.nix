pkgs: {
  xdg.configFile."aerc/aerc.conf".text = ''
    [ui]
    index-format=%Z %D %-30.30n %s
    timestamp-format=15:04 Mon 02/01/2006
    sidebar-width=30
    sort=-r date
    stylesets-dirs=~/.config/aerc/stylesets

    [compose]
    address-book-cmd=khard email --remove-first-line --parsable '%s'

    [filters]
    subject,~^\[PATCH=awk -f ${pkgs.aerc}/share/aerc/filters/hldiff
    text/html=${pkgs.aerc}/share/aerc/filters/html
    text/*=awk -f ${pkgs.aerc}/share/aerc/filters/plaintext

    [triggers]
    new-email=exec ${pkgs.libnotify}/bin/notify-send "New email from %n" "%s"
  '';

  xdg.configFile."aerc/binds.conf".text = ''
    <C-p> = :prev-tab<Enter>
    <C-n> = :next-tab<Enter>
    <C-l> = :change-tab -<Enter>
    <C-t> = :term<Enter>
    <C-r> = :term mailsync<Enter>

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

    <space> = :mark -t<Enter>
    ma = :mark -at<Enter>

    A = :pipe khard add-email -H all<Enter>

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
    u = :pipe -p urlscan<Enter>
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
