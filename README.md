# lua-language-server type check action

A GitHub action that lets you leverage [`lua-language-server`](https://github.com/LuaLS/lua-language-server)
and [luaCATS](https://luals.github.io/wiki/annotations/) to statically type check and lint lua code.

## Introduction

What I found the most frustrating about developing Neovim plugins in Lua is the lack
of type safety.

When I [added](https://github.com/mrcjkb/haskell-tools.nvim/pull/103/files) some LuaCATS
annotations to one of my plugins (to generate Vimdoc using [`lemmy-help`](https://github.com/numToStr/lemmy-help)),
I noticed `lua-language-server` was giving me diagnostics based on my documentation.
This was something I was not getting from linters like `luacheck`.
So I asked myself, "Can I leverage `lua-language-server` and EmmyLua to statically type check my Lua code?"

The result is this GitHub action, which type checks itself: 

[![Type Check Code Base](https://github.com/mrcjkb/lua-typecheck-action/actions/workflows/typecheck.yml/badge.svg)](https://github.com/mrcjkb/lua-typecheck-action/actions/workflows/typecheck.yml)

## Usage

Create `.github/workflows/typecheck.yml` in your repository with the following contents:

```yaml
---
name: Type Check Code Base
on:
  pull_request: ~
  push:
    branches:
      - master

jobs:
  build:
    name: Type Check Code Base
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Type Check Code Base
        uses: mrcjkb/lua-typecheck-action@v1
```

## Inputs

The following optional inputs can be specified using `with:`

### `checklevel`

The diagnostics severity level to fail on. One of:

* `Error`
* `Warning` (default)
* `Information`
* `Hint`

Example:

```yaml
- name: Type Check Code Base
  uses: mrcjkb/lua-typecheck-action@v1
  with:
    checklevel: Error
```

### `directories`

Directories to lint (relative to the repostitory root).
Defaults to the repository root if none are specified.

Example:

```yaml
- name: Type Check Code Base
  uses: mrcjkb/lua-typecheck-action@v1
  with:
    directories: |
     lua
     tests
```

### `configpath`

Path to a [`.luarc.json`](https://github.com/LuaLS/lua-language-server/wiki/Configuration-File#luarcjson) (relative to the repository root).

Example:

```yaml
- name: Type Check Code Base
  uses: mrcjkb/lua-typecheck-action@v1
  with:
    configpath: ".luarc.json"
```

## Wiki

See [the wiki](https://github.com/mrcjkb/lua-typecheck-action/wiki) for usage examples.

## Can I use this with a non-GPLv2 licensed project?

Yes.
Because it is not distributed with any binaries, you can use it in any project.
