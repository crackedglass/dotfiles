{
  description = "crackedglass's dotfiles";

  outputs = { self, ... }: {
    # Directories meant to live under ~/.config, ready to be copied verbatim by
    # home-manager. install.sh (the standalone symlink installer) and the flake
    # metadata are excluded.
    configDir = builtins.path {
      path = ./.;
      name = "dotfiles-config";
      filter = path: type:
        !builtins.elem (baseNameOf path) [
          "install.sh"
          "flake.nix"
          "flake.lock"
          ".git"
        ];
    };
  };
}
