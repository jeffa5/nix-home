{...}: {
  programs.newsboat = {
    enable = true;
    urls = [
      {
        title = "Inside Rust Blog";
        url = "https://blog.rust-lang.org/inside-rust/feed.xml";
      }
      {
        title = "Rust Blog";
        url = "https://blog.rust-lang.org/feed.xml";
      }
      {
        title = "Rust OSDev";
        url = "https://rust-osdev.com/rss.xml";
      }
      {
        title = "Rust and WebAssembly";
        url = "https://rustwasm.github.io/feed.xml";
      }
      {
        title = "This Week in Rust";
        url = "https://this-week-in-rust.org/rss.xml";
      }
      {
        title = "Writing an OS in Rust";
        url = "https://os.phil-opp.com/rss.xml";
      }
      {
        title = "rust-analyzer";
        url = "https://rust-analyzer.github.io/feed.xml";
      }
      {
        title = "The Cloudflare Blog";
        url = "https://blog.cloudflare.com/rss/";
      }
      {
        title = "Adventures in Linux and KDE";
        url = "https://pointieststick.com/feed/";
      }
      {
        title = "Alchemists: News";
        url = "https://www.alchemists.io/feeds/news.xml";
      }
      {
        title = "Automerge-RS on Automerge-RS Development";
        url = "https://inkandswitch.github.io/automerge-rs/index.xml";
      }
      {
        title = "Bartosz Ciechanowski";
        url = "https://ciechanow.ski/atom.xml";
      }
      {
        title = "Bartosz Sypytkowski";
        url = "https://bartoszsypytkowski.com/rss/";
      }
      {
        title = "Blog Posts - Effective Altruism UK";
        url = "http://feeds.feedburner.com/BlogPosts-EffectiveAltruismLondon";
      }
      {
        title = "Blogs on Sourcehut";
        url = "https://sourcehut.org/blog/index.xml";
      }
      {
        title = "Bounded Regret";
        url = "https://bounded-regret.ghost.io/rss/";
      }
      {
        title = "Brendan Gregg's Blog";
        url = "https://www.brendangregg.com/blog/rss.xml";
      }
      {
        title = "Christine Dodrill's Blog";
        url = "https://christine.website/blog.rss";
      }
      {
        title = "DYNOMIGHT";
        url = "https://dynomight.net/feed.xml";
      }
      {
        title = "DaedTech";
        url = "http://feeds.feedblitz.com/daedtech/www";
      }
      {
        title = "Dave Allie's Blog";
        url = "https://blog.daveallie.com/rss.xml";
      }
      {
        title = "Derek Sivers blog";
        url = "https://sive.rs/en.atom";
      }
      {
        title = "Determinate Systems";
        url = "https://determinate.systems/rss.xml";
      }
      {
        title = "Drew DeVault's blog";
        url = "https://drewdevault.com/blog/index.xml";
      }
      {
        title = "DropBox Tech";
        url = "https://dropbox.tech/feed";
      }
      {
        title = "Element Blog";
        url = "https://element.io/blog/rss/";
      }
      {
        title = "Eli Bendersky's website";
        url = "https://eli.thegreenplace.net/feeds/all.atom.xml";
      }
      {
        title = "Factorio Blog";
        url = "https://factorio.com/blog/rss";
      }
      {
        title = "GNOME Shell &amp; Mutter";
        url = "https://blogs.gnome.org/shell-dev/feed/";
      }
      {
        title = "Garage";
        url = "https://garagehq.deuxfleurs.fr/rss.xml";
      }
      {
        title = "Garnix Blog";
        url = "https://garnix.io/feed.xml";
      }
      {
        title = "Geoffrey Litt";
        url = "https://www.geoffreylitt.com/feed.xml";
      }
      {
        title = "Ham Vocke";
        url = "https://www.hamvocke.com/feed.xml";
      }
      {
        title = "Happenings in GNOME";
        url = "https://blogs.gnome.org/chergert/feed/";
      }
      {
        title = "Home Assistant";
        url = "https://www.home-assistant.io/atom.xml";
      }
      {
        title = "Home Assistant Alerts";
        url = "https://alerts.home-assistant.io/feed.xml";
      }
      {
        title = "Immich Blog";
        url = "https://immich.app/blog/feed.xml";
      }
      {
        title = "Jane Street Tech Blog";
        url = "https://blog.janestreet.com/feed.xml";
      }
      {
        title = "Jim Nielsen’s Blog";
        url = "https://blog.jim-nielsen.com/feed.xml";
      }
      {
        title = "Joel on Software";
        url = "https://www.joelonsoftware.com/feed/";
      }
      {
        title = "Julia Evans";
        url = "https://jvns.ca/atom.xml";
      }
      {
        title = "Ladybird Newsletter";
        url = "https://buttondown.com/ladybird/rss";
      }
      {
        title = "Martin Kleppmann's blog";
        url = "https://feeds.feedburner.com/martinkl";
      }
      {
        title = "Mobile NixOS news";
        url = "https://mobile.nixos.org/index.xml";
      }
      {
        title = "NLnet news";
        url = "https://nlnet.nl/feed.atom";
      }
      {
        title = "Nicholas Nethercote";
        url = "https://nnethercote.github.io/feed.xml";
      }
      {
        title = "Organic Maps";
        url = "https://organicmaps.app/rss.xml";
      }
      {
        title = "Our World in Data";
        url = "https://ourworldindata.org/atom.xml";
      }
      {
        title = "Paul Graham: Essays";
        url = "http://www.aaronsw.com/2002/feeds/pgessays.rss";
      }
      {
        title = "Pedestrian Observations";
        url = "https://pedestrianobservations.com/feed/";
      }
      {
        title = "Pijul - A Distributed Version Control System";
        url = "http://pijul.org/index.xml";
      }
      {
        title = "Polars DataFrame blog";
        url = "https://pola.rs/rss.xml";
      }
      {
        title = "Predrag Gruevski's blog and personal site.";
        url = "https://predr.ag/atom.xml";
      }
      {
        title = "Seph";
        url = "https://josephg.com/blog/rss/";
      }
      {
        title = "The Thunderbird Blog";
        url = "https://blog.thunderbird.net/feed/";
      }
      {
        title = "This Week in GNOME";
        url = "https://thisweek.gnome.org/index.xml";
      }
      {
        title = "This Week in KDE Apps on KDE Blogs";
        url = "https://blogs.kde.org/categories/this-week-in-kde-apps/index.xml";
      }
      {
        title = "This Week in Plasma on KDE Blogs";
        url = "https://blogs.kde.org/categories/this-week-in-plasma/index.xml";
      }
      {
        title = "Too late now - Blog";
        url = "https://www.jeffas.net/blog/atom.xml";
      }
      {
        title = "Tristan Hume";
        url = "https://thume.ca/atom.xml";
      }
      {
        title = "Writing - rachelbythebay";
        url = "http://rachelbythebay.com/w/atom.xml";
      }
      {
        title = "arduin.io";
        url = "https://arduin.io/index.xml";
      }
      {
        title = "baby steps";
        url = "https://smallcultfollowing.com/babysteps/atom.xml";
      }
      {
        title = "bors-ng";
        url = "https://bors.tech/feed.xml";
      }
      {
        title = "env.fail";
        url = "https://env.fail/blog.rss";
      }
      {
        title = "etcd – Blog";
        url = "https://etcd.io/blog/index.xml";
      }
      {
        title = "fasterthanli.me";
        url = "https://fasterthanli.me/index.xml";
      }
      {
        title = "kflansburg.com";
        url = "https://kflansburg.com/index.xml";
      }
      {
        title = "matklad";
        url = "https://matklad.github.io/feed.xml";
      }
      {
        title = "matrix.org";
        url = "https://matrix.org/blog/feed";
      }
      {
        title = "mort’s mythopœia";
        url = "https://mort.io/atom.xml";
      }
      {
        title = "ntietz.com blog";
        url = "https://ntietz.com/atom.xml";
      }
      {
        title = "seanmonstar";
        url = "https://seanmonstar.com/rss";
      }
    ];
    extraConfig = ''
      unbind-key j
      unbind-key k
      unbind-key J
      unbind-key K
      unbind-key p
      unbind-key ENTER
      unbind-key g
      unbind-key G
      unbind-key t
      unbind-key A
      unbind-key q
      unbind-key Q
      unbind-key HOME
      unbind-key END

      bind-key j down
      bind-key k up
      bind-key h quit
      bind-key q hard-quit
      bind-key l open
      bind-key N prev-unread
      bind-key t mark-feed-read
      bind-key g home
      bind-key G end

      color listfocus default default reverse
      color listfocus_unread default default bold reverse
      color title default default reverse
      color info default default reverse

      feed-sort-order latestunread
    '';
  };
}
