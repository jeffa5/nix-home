export PATH="$coreutils/bin:$gzip/bin"
mkdir -p $out/share/keymaps/i386/colemak
gzip --stdout $src/iso-uk-colemak-dh.map > $out/share/keymaps/i386/colemak/iso-uk-colemak-dh.map.gz
