---@class LeanCLIArgList
local ArgList = {}

---@generic T : any[]
---@param items T
---@return T
local function array_reverse(items)
  local result = {}
  local length = #items
  for i, item in ipairs(items) do
    result[length - i + 1] = item
  end
  return result
end

-- local function array_slice(items, start_index, end_index)
--   local result = {}
--   for i = start_index, end_index do
--     result[i - start_index + 1] = items[i]
--   end
--   return result
-- end

local function array_push(items, item)
  items[#items + 1] = item
end

local function array_pop(items)
  local item = items[#items]
  items[#items] = nil
  return item
end

---@param args string[]
---@return LeanCLIArgList
function ArgList:new(args)
  ---@type LeanCLIArgList
  local arg_list = { _items = array_reverse(args) }

  setmetatable(arg_list, { __index = self })

  return arg_list
end

---@param arg string
function ArgList:add(arg)
  array_push(self._items, arg)
end

function ArgList:consume()
  if not self:peek() then
    error("arglist empty")
  end

  local arg = array_pop(self._items)

  return arg
end

function ArgList:drain()
  local args = array_reverse(self._items)
  self._items = {}
  return args
end

function ArgList:peek()
  return self._items[#self._items]
end

return ArgList
