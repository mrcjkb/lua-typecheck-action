{
  description = "A GitHub action that lints your Lua code using lua-language-server. Static type checking with EmmyLua!";

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
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
    ];
    perSystem = nixpkgs.lib.genAttrs supportedSystems;
    pkgsFor = system: import nixpkgs {inherit system;};

    lua-typecheck-action-for = system: let
      pkgs = pkgsFor system;
    in
      pkgs.luajit.pkgs.callPackage ({
        buildLuaApplication,
        llscheck,
        busted,
      }:
        buildLuaApplication {
          pname = "lua-typecheck-action";
          version = "scm-1";

          src = self;

          nativeBuildInputs = [pkgs.makeWrapper];

          # XXX: Somehow nativeCheckInputs doesn't work
          propagatedBuildInputs = [llscheck busted];

          postInstall = ''
              makeWrapper $out/bin/lua-typecheck-action.lua $out/bin/lua-typecheck-action
          '';

          doCheck = true;
        }) {};
  in {
    packages = perSystem (system: let
      lua-typecheck-action = lua-typecheck-action-for system;
    in {
      default = lua-typecheck-action;
      inherit lua-typecheck-action;
    });
    shells = perSystem (system: {
      default = let
        pkgs = pkgsFor system;
        lua-typecheck-action = lua-typecheck-action-for system;
      in
        lua-typecheck-action.overrideAttrs (oa: {
          doCheck = false;
          buildInputs = with pkgs; [
            alejandra
            stylua
            luacheck
          ];
        });
    });
  };
}
