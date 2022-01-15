---@class LeanCLICommand
---@field id string
---@field info string
---@field usage string[]
---@field parameters table<string, LeanCLIParameter>
---@field subcommands string[]
---@field run fun(result: LeanCLIResult): nil

---@class LeanCLICommandFactory
local Command = {}

---@param id string
function Command:new(id)
  ---@type LeanCLICommandFactory
  local command = {
    _def = {
      id = id,
      parameters = {},
      subcommands = {},
      run = function() end,
    },
  }

  setmetatable(command, { __index = self })

  return command
end

function Command:info(info)
  self._def.info = info
  return self
end

function Command:usage(usage)
  self._def.usage = usage
  return self
end

---@param id string
---@param parameter LeanCLIParameter
function Command:parameter(id, parameter)
  if self._def.parameters[id] then
    error()
  end

  self._def.parameters[id] = parameter
  return self
end

---@param names string[]|fun(): string[]
function Command:subcommands(names)
  self._def.subcommands = type(names) == "function" and names() or names
  return self
end

---@param run fun(result: LeanCLIResult): nil
function Command:run(run)
  self._def.run = run
  return self
end

function Command:create()
  return self._def
end

return Command
