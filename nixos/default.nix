{ colemakdh }:
{ config, pkgs, ... }:

{
  time.timeZone = "Europe/London";

  networking.networkmanager.enable = true;
  networking.useDHCP = false;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.andrew = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    zsh
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  console.packages = [ colemakdh ];
  console.keyMap = "iso-uk-colemak-dh";

  services.fstrim.enable = true;

  programs.sway.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
