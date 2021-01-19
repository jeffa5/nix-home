{
  enable = true;
  autoReload = true;
  urls = [
    { url = "https://www.hamvocke.com/feed.xml"; title = "Ham Vocke"; }
    { url = "https://blog.acolyer.org/feed/"; title = "The morning paper"; }
    { url = "https://www.joelonsoftware.com/feed/"; title = "Joel on Software"; }
    { url = "https://www.atlassian.com/blog/feed/all-teams"; title = "Atlassian Blog"; }
    { url = "http://feeds.feedburner.com/scalable-startups"; }
    { url = "https://sourcehut.org/blog/index.xml"; }
    { url = "https://thume.ca/atom.xml"; }
    { url = "https://drewdevault.com/feed.xml"; }
    { url = "http://feeds.feedblitz.com/daedtech/www"; }
    { url = "https://ocaml.org/feed.xml"; }
    { url = "https://www.phoronix.com/rss.php"; }
    { url = "https://dropbox.tech/feed"; }
    { url = "https://blog.janestreet.com/feed.xml"; }
    { url = "https://monzo.com/blog/technology"; }
    { url = "https://blog.rust-lang.org/feed.xml"; }
    { url = "https://blog.rust-lang.org/inside-rust/feed.xml"; }
    { url = "https://rust-analyzer.github.io/feed.xml"; }
    { url = "http://rachelbythebay.com/w/atom.xml"; }
    { url = "https://fasterthanli.me/index.xml"; }
    { url = "https://os.phil-opp.com/rss.xml"; }
    { url = "https://eli.thegreenplace.net/feeds/all.atom.xml"; }
    { url = "https://unixism.net/feed/"; }
    { url = "https://feeds.feedburner.com/martinkl"; }
    { url = "https://christine.website/blog.rss"; }
    { url = "https://stackoverflow.blog/feed/"; }
    { url = "https://pijul.org/posts/index.xml"; }
  ];
  extraConfig = ''
    confirm-exit yes

    datetime-format "%d %b %Y"

    feedlist-title-format "%N - Feeds (%u unread, %t total)%?T? - tag `%T'&?"
    articlelist-title-format "%N - Articles in '%T' (%u unread, %t total) - %U"
    articlelist-format "%4i %f %D  %?T?|%-17T|  ?%t (%L)"
    searchresult-title-format "%N - Search result (%u unread, %t total)"
    filebrowser-title-format "%N - %?O?Open File&Save File? - %f"
    help-title-format "%N - Help"
    selecttag-title-format "%N - Select tag"
    selectfilter-title-format "%N - Select filter"
    itemview-title-format "%N - %F - %T (%u unread, %t total)"
    urlview-title-format "%N - URLs"
    dialogs-title-format "%N - Dialogs"

    # set vim movement bindings
    unbind-key h
    unbind-key j
    unbind-key k
    unbind-key l
    unbind-key ENTER

    bind-key h quit
    bind-key j down
    bind-key k up
    bind-key l open

    unbind-key J
    unbind-key K
    unbind-key PAGEUP
    unbind-key PAGEDOWN

    bind-key J pagedown
    bind-key K pageup

    # mark read
    unbind-key a
    unbind-key A
    unbind-key C

    bind-key a mark-feed-read
    bind-key A mark-all-feeds-read

    # next/prev article
    unbind-key n
    unbind-key N

    bind-key n next
    bind-key N prev

    # next/prev unread article
    unbind-key m
    unbind-key M
    unbind-key p

    bind-key m next-unread
    bind-key M prev-unread

    # change home and end keys
    unbind-key HOME
    unbind-key END
    unbind-key g
    unbind-key G

    bind-key g home
    bind-key G end

    # bind v to toggle show read feeds (verbosity)
    unbind-key v

    bind-key v toggle-show-read-feeds

    # sort articles
    unbind-key d
    unbind-key D

    bind-key d sort
    bind-key D rev-sort

    # change hard quit to q
    unbind-key Q
    unbind-key q

    bind-key q hard-quit
  '';
}
