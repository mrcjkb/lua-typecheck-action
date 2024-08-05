#!/usr/bin/env lua

---@class Args
---@field checklevel string The diagnostics level to fail at
---@field directories string[] The directories to lint
---@field configpath string? Path to the luarc.json

---@param str string
---@return string[] list_arg
local function parse_list_args(str)
  local tbl = {}
  for arg in str:gmatch('[^\r\n]+') do
    table.insert(tbl, arg)
  end
  return tbl
end

local workdir = os.getenv('GITHUB_WORKSPACE') or '.'

local directory_args = os.getenv('INPUT_DIRECTORIES')
local config_path_input = os.getenv('INPUT_CONFIGPATH') or '.luarc.json'

local fh = io.open(config_path_input, 'r')
if not fh then
  error(config_path_input .. ' not found.')
end
fh:close()

local directory_list = directory_args and parse_list_args(directory_args) or { '' }

---@type Args
local args = {
  checklevel = os.getenv('INPUT_CHECKLEVEL') or '"Warning"',
  workdir = workdir,
  directories = directory_list,
  configpath = (config_path_input ~= '' and '"' .. workdir .. '/' .. config_path_input .. '"' or nil),
}

require('lua-typecheck-action').run(args)
