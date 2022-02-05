---@class LeanCLIResult
---@field count fun(id: string): number
---@field get fun(id: string): { count: number, value?: any }
---@field value fun(id: string): any
---@field subcommand? string
---@field unparsed_args string[]
---@field dump fun(): any[]

---@class LeanCLIResultFactory
local Result = {}

function Result:new()
  ---@type LeanCLIResultFactory
  local result = {
    _ = {
      subcommand = nil,
      unparsed_args = {},
      count_map = {},
      value_map = {},
    },
  }

  setmetatable(result, { __index = self })

  return result
end

function Result:get_count(id)
  return self._.count_map[id] or 0
end

function Result:increment_count(id)
  local count = self:get_count(id)
  self._.count_map[id] = count + 1
end

function Result:get_value(id)
  return self._.value_map[id]
end

function Result:set_value(id, value)
  self._.value_map[id] = value
end

function Result:set_subcommand(id)
  self._.subcommand = id
end

function Result:set_unparsed_args(args)
  local current_length = #self._.unparsed_args
  for i, arg in ipairs(args) do
    self._.unparsed_args[current_length + i] = arg
  end
end

---@return LeanCLIResult
function Result:create()
  return {
    count = function(id)
      return self:get_count(id)
    end,
    get = function(id)
      return {
        count = self:get_count(id),
        value = self:get_value(id),
      }
    end,
    value = function(id)
      return self:get_value(id)
    end,
    subcommand = self._.subcommand,
    unparsed_args = self._.unparsed_args,
    dump = function()
      local value_entries = {}
      for id, value in pairs(self._.value_map) do
        table.insert(value_entries, { id, value })
      end
      return value_entries
    end,
  }
end

return Result
