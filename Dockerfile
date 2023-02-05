# TODO: Use official alpine image with pinned package versions when lua-language-server is available
FROM nixpkgs/nix-flakes:nixos-22.11 AS lua-typecheck-action-drv

COPY bin /pkg/bin
COPY lua-typecheck-action-scm-1.rockspec /pkg/
COPY flake.nix /pkg/flake.nix
COPY flake.lock /pkg/flake.lock
COPY entrypoint.sh /entrypoint.sh

FROM lua-typecheck-action-drv AS lua-typecheck-action

ENTRYPOINT ["/entrypoint.sh"]
