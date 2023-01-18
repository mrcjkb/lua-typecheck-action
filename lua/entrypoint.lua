#!/usr/bin/env lua

---@class Args
---@field checklevel string The diagnostics level to fail at
---@field directories string[] The directories to lint
---@field configpath string? Path to the luarc.json

---@type string[]
local arg_list = { ... }

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

local directory_list = parse_list_args(arg_list[2])

---@type Args
local args = {
  checklevel = arg_list[1],
  directories = #directory_list > 0 and directory_list or { '' },
  configpath = (arg_list[3] ~= '' and '"' .. workdir .. '/' .. arg_list[3] .. '"' or nil),
}

---@param filename string
---@param foo bar
---@return string? content
local function read_file(filename)
  local content
  local f = io.open(filename, 'r')
  if f then
    content = f:read('*a')
    f:close()
  end
  return content
end

---@class LintResult
---@field success boolean
---@field directory string
---@field diagnostics string?

---@param directory string
---@return LintResult
local function lint(directory)
  local result = {
    directory = directory,
  }
  local stdout_file = 'stdout.txt'
  local stderr_file = 'stderr.txt'
  local logpath = '.'
  local cmd = 'lua-language-server --check '
    .. directory
    .. (args.configpath and ' --configpath=' .. args.configpath or '')
    .. ' --logpath='
    .. logpath
    .. ' --checklevel='
    .. args.checklevel
  local redirect = ' >' .. stdout_file .. ' 2>' .. stderr_file
  print(cmd)
  local exit_code = os.execute(cmd .. redirect)
  local stdout = read_file(stderr_file) or ''
  print(stdout)
  if exit_code ~= 0 then
    local stderr = read_file(stderr_file) or ''
    print(stderr)
    error('Failed to call lua-language-server. Exit code: ' .. exit_code)
  end
  local logfile = logpath .. '/check.json'
  local diagnostics = read_file(logfile)
  if diagnostics and diagnostics ~= '' then
    result.success = false
    result.diagnostics = diagnostics
    return result
  end
  result.success = true
  return result
end

local success = true
for _, directory in ipairs(args.directories) do
  local result = lint('"' .. workdir .. '/' .. directory .. '"')
  if not result.success then
    print('Diagnostics for directory ' .. result.directory .. ':')
    print(result.diagnostics)
    success = false
  end
end
if not success then
  error('LINT FAILED!')
end
