local M = {}

---@class Args
---@field workdir string The working directory
---@field checklevel? string The diagnostics level to fail at
---@field directories? string[] The subdirectories to lint (relative to the working directory)
---@field configpath? string Path to the luarc.json

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

---@param args Args
function M.run(args)
  ---@param directory string
  ---@return LintResult
  local function lint(directory)
    ---@type LintResult
    ---@diagnostic disable-next-line: missing-fields
    local result = {
      directory = directory,
    }
    local stdout_file = 'stdout.txt'
    local stderr_file = 'stderr.txt'
    local cmd = 'llscheck'
      .. (args.configpath and ' --configpath ' .. args.configpath or '')
      .. ' --checklevel '
      .. (args.checklevel or '"Warning"')
      .. ' '
      .. directory
    local redirect = ' >' .. stdout_file .. ' 2>' .. stderr_file
    print(cmd)
    local exit_code = os.execute(cmd .. redirect)
    local stdout = read_file(stderr_file) or ''
    print(stdout)
    if exit_code ~= 0 then
      local stderr = read_file(stderr_file) or ''
      result.success = false
      result.diagnostics = stderr
      return result
    end
    result.success = true
    result.diagnostics = stdout
    return result
  end

  local success = true
  for _, directory in ipairs(args.directories or { '' }) do
    local result = lint('"' .. args.workdir .. '/' .. directory .. '"')
    if not result.success then
      print('Diagnostics for directory ' .. result.directory .. ':')
      print(result.diagnostics)
      success = false
    end
  end
  if not success then
    error('LINT FAILED!')
  end
end

return M
