{
  description = "A GitHub action that lints your Lua code using sumneko lua-language-server. Static type checking with EmmyLua!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
    ];
    perSystem = nixpkgs.lib.genAttrs supportedSystems;
    pkgsFor = system: import nixpkgs {inherit system;};

    lua-typecheck-action-for = system: let
      pkgs = pkgsFor system;
      lua-typecheck-action-wrapped = pkgs.lua51Packages.buildLuaApplication {
        pname = "lua-typecheck-action";
        version = "scm-1";

        src = self;
      };
    in
      pkgs.writeShellApplication {
        name = "lua-typecheck-action";
        runtimeInputs = with pkgs; [
          sumneko-lua-language-server
          lua-typecheck-action-wrapped
        ];

        text = ''
          lua-typecheck-action.lua "$@"
        '';
      };
  in {
    packages = perSystem (system: let
      lua-typecheck-action = lua-typecheck-action-for system;
    in {
      default = lua-typecheck-action;
      inherit lua-typecheck-action;
    });
  };
}
