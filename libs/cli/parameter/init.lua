---@class LeanCLIParameter
---@field default_value? any
---@field long? string
---@field long_aliases? string[]
---@field short? string
---@field short_aliases? string[]
---@field position? number
---@field info? string
---@field usage? string[]
---@field global? boolean
---@field multiple? boolean
---@field multiple_value? boolean
---@field takes_value? boolean
---@field required? boolean
---@field parse? fun(value: string): any
---@field valid? fun(value: string): boolean
---@field conflicts? string|string[]
---@field requires? string|string[]

---@class LeanCLIParameterFactory
local Parameter = {}

local function is_defined(value)
  return value ~= nil
end

---@param definition LeanCLIParameter
---@return LeanCLIParameterFactory
function Parameter:new(definition)
  ---@type LeanCLIParameterFactory
  local parameter = {
    _def = definition or {},
  }

  setmetatable(parameter, { __index = self })

  return parameter
end

function Parameter:default_value(default_value)
  self._def.takes_value = true
  self._def.default_value = default_value
  return self
end

function Parameter:long(long)
  if is_defined(self._def.long) then
    error()
  end

  self._def.long = long
  return self
end

function Parameter:long_aliases(long_aliases)
  if is_defined(self._def.position) then
    error()
  end

  self._def.long_aliases = long_aliases
  return self
end

function Parameter:short(short)
  if is_defined(self._def.short) then
    error()
  end

  self._def.short = short
  return self
end

function Parameter:short_aliases(short_aliases)
  if is_defined(self._def.position) then
    error()
  end

  self._def.short_aliases = short_aliases
  return self
end

function Parameter:position(position)
  if is_defined(self._def.long) or is_defined(self._def.short) then
    error()
  end

  if is_defined(self._def.multiple) then
    error()
  end

  if position < 1 then
    error()
  end

  self._def.position = position
  return self
end

function Parameter:info(info)
  self._def.info = info
  return self
end

function Parameter:usage(usage)
  self._def.usage = usage
  return self
end

function Parameter:global()
  if is_defined(self._def.position) then
    error()
  end

  self._def.global = true
  return self
end

function Parameter:multiple()
  if is_defined(self._def.position) then
    error()
  end

  self._def.multiple = true
  return self
end

function Parameter:multiple_value()
  self._def.takes_value = true
  self._def.multiple_value = true
  return self
end

function Parameter:takes_value()
  self._def.takes_value = true
  return self
end

function Parameter:required()
  self._def.required = true
  return self
end

function Parameter:parse(parse)
  self._def.parse = parse
  return self
end

function Parameter:valid(valid)
  self._def.valid = valid
  return self
end

function Parameter:conflicts(conflicts)
  self._def.conflicts = conflicts
  return self
end

function Parameter:requires(requires)
  self._def.requires = requires
  return self
end

---@param definition LeanCLIParameter
---@return LeanCLIParameter
function Parameter:create(definition)
  for key, value in pairs(definition or {}) do
    self._def[key] = value
  end

  return self._def
end

return Parameter
