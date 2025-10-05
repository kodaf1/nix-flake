{
  description = "Kodaf MacOS Nix Flakes Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
  }: let
    configuration = {pkgs, ...}: {
      homebrew = {
        enable = true;
        user = "kodaf";
        brews = [
          "mas"
        ];
        casks = [
          "hiddenbar"
          "keka"
          "vlc"
        ];
        taps = [
        ];
        masApps = {
        };
      };

      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        neofetch
        wget
        curl
        ffmpeg
        findutils
        zsh-syntax-highlighting
        ngrok
        go
        htop
        nodejs
        tmux
      ];
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macos" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
      ];
    };
  };
}
