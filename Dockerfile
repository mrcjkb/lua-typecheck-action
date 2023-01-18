# TODO: Use official alpine image with pinned package versions when lua-language-server is available
FROM nixos/nix:2.13.1 AS sumneko-lint

RUN nix-env -iA nixpkgs.lua5_1 nixpkgs.sumneko-lua-language-server

COPY lua/entrypoint.lua /entrypoint.lua

ENTRYPOINT ["/entrypoint.lua"]
