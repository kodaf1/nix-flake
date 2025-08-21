{
  description = "Kodaf MacOS Nix Flakes Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    nvf,
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
        php
        tmux
      ];
      programs.nvf = {
        enable = true;

        settings.vim = {
          viAlias = true;
          vimAlias = true;

          options = {
            shiftwidth = 4;
            tabstop = 4;
          };

          lsp = {
            enable = true;
            formatOnSave = true;
            inlayHints.enable = true;
            lightbulb.enable = true;
            lightbulb.autocmd.enable = true;
          };

          languages = {
            enableFormat = true;
            enableTreesitter = true;

            nix.enable = true;
            markdown.enable = true;
            bash.enable = true;
            css.enable = true;
            html.enable = true;
            sql.enable = true;
            ts.enable = true;
            go.enable = true;
            lua.enable = true;
            python.enable = true;
            php = {
              enable = true;
              lsp = {
                enable = true;
                server = "intelephense";
              };
            };
            tailwind.enable = true;
          };

          treesitter = {
            indent.enable = false;
          };

          filetree = {
            neo-tree = {
              enable = true;
            };
          };

          binds = {
            cheatsheet.enable = true;
            whichKey.enable = true;
          };

          visuals = {
            nvim-scrollbar.enable = true;
            nvim-web-devicons.enable = true;
            nvim-cursorline.enable = true;
            cinnamon-nvim.enable = true;
            fidget-nvim.enable = true;

            highlight-undo.enable = true;
            indent-blankline.enable = true;

            # Fun
            cellular-automaton.enable = false;
          };

          statusline = {
            lualine = {
              enable = true;
              theme = "catppuccin";
            };
          };

          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
            transparent = false;
          };

          autocomplete = {
            nvim-cmp.enable = true;
          };

          telescope.enable = true;

          git = {
            enable = true;
            gitsigns.enable = true;
            gitsigns.codeActions.enable = false; # throws an annoying debug message
          };

          ui = {
            borders.enable = true;
            noice.enable = true;
            colorizer.enable = true;
            modes-nvim.enable = false; # the theme looks terrible with catppuccin
            illuminate.enable = true;
            breadcrumbs = {
              enable = true;
              navbuddy.enable = true;
            };
            smartcolumn = {
              enable = true;
              setupOpts.custom_colorcolumn = {
                # this is a freeform module, it's `buftype = int;` for configuring column position
                nix = "110";
                ruby = "120";
                java = "130";
                go = ["90" "130"];
              };
            };
            fastaction.enable = true;
          };
        };
      };
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macos" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nvf.nixosModules.default
      ];
    };
  };
}
