#!/usr/bin/env bash

nix build "/pkg#lua-typecheck-action"

./result/bin/lua-typecheck-action "$@"
