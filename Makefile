.PHONY: dconf
dconf:
	dconf dump / > dconf.settings
	dconf2nix -i dconf.settings -o home/dconf.nix
	rm dconf.settings
