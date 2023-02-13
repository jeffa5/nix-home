.PHONY: dconf
dconf:
	dconf dump / > dconf.settings
	dconf2nix -i dconf.settings -o home/dconf.nix
	rm dconf.settings

.PHONY: diff-all
diff-all:
	nix profile diff-closures --profile /nix/var/nix/profiles/system

.PHONY: diff
diff:
	nixos-rebuild build --flake . # get the to-be-installed closure
	nix store diff-closures /run/current-system ./result

.PHONY: nvd
nvd:
	nixos-rebuild build --flake . # get the to-be-installed closure
	nix run nixpkgs#nvd -- diff /run/current-system ./result # diff that with the current system

.PHONY: tree
tree:
	nix-store -q --tree /nix/var/nix/profiles/system > tree.txt
