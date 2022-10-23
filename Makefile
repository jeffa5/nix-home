.PHONY: dconf
dconf:
	dconf dump / > dconf.settings
	dconf2nix -i dconf.settings -o home/dconf.nix
	rm dconf.settings

.PHONY: diff.txt
diff.txt:
	nix profile diff-closures --profile /nix/var/nix/profiles/system > diff.txt
