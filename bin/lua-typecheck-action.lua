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

local function getenv_or_err(env_var)
  return assert(os.getenv(env_var), env_var .. ' not set.')
end

local workdir = os.getenv('GITHUB_WORKSPACE') or '.'

local directory_args = getenv_or_err('INPUT_DIRECTORIES')
local config_path_input = getenv_or_err('INPUT_CONFIGPATH')
local directory_list = parse_list_args(directory_args)

---@type Arg
local args = {
  checklevel = getenv_or_err('INPUT_CHECKLEVEL'),
  directories = #directory_list > 0 and directory_list or { '' },
  configpath = (config_path_input ~= '' and '"' .. workdir .. '/' .. config_path_input .. '"' or nil),
}

---@param filename string
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
  local cmd = 'lua-language-server --check_format=pretty --check '
    .. directory
    .. (args.configpath and ' --configpath=' .. args.configpath or '')
    .. ' --checklevel='
    .. args.checklevel
  local redirect = ' >' .. stdout_file .. ' 2>' .. stderr_file
  print(cmd)
  local exit_code = os.execute(cmd .. redirect)
  local stdout = read_file(stdout_file) or ''
  if exit_code ~= 0 then
    local stderr = read_file(stderr_file) or ''
    result.success = false;
    result.diagnostics = stdout .. '\n\n' .. stderr
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
