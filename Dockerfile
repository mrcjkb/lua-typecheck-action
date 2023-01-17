FROM lspcontainers/lua-language-server:2.4.2 AS sumneko-lint

COPY entrypoint.lua /entrypoint.lua

ENTRYPOINT ["/entrypoint.lua"]
