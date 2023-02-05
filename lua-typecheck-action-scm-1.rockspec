local _MODREV, _SPECREV = 'scm', '-1'
rockspec_format = "3.0"
package = 'lua-typecheck-action'
version = _MODREV .. _SPECREV

description = {
   summary = 'A GitHub action that lints your Lua code using sumneko lua-language-server. Static type checking with EmmyLua!',
   homepage = 'http://github.com/mrcjkb/lua-typecheck-action',
   license = 'GPLv2',
}

dependencies = {
   'lua >= 5.1',
}

source = {
  url = 'git://github.com/mrcjkb/lua-typecheck-action',
}

build = {
   type = 'builtin',
}

