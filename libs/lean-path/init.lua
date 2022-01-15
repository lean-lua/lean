local lstring = require("lean-string")
local uv = require("uv")

---@class LeanPath
local Path = {
  root = "/",
  sep = "/",
}

Path.__meta__ = {
  __index = Path,
  __tostring = function(path)
    return path._value
  end,
}

---@param path string
---@return string[]
local function split_path(path)
  local parts = {}
  for part in string.gmatch(path, string.format("([^%s]+)", Path.sep)) do
    table.insert(parts, part)
  end
  return parts
end

---@return string
local function cwd()
  return uv.cwd()
end

---@param path string
---@return boolean
local function is_absolute(path)
  return lstring.starts_with(path, Path.sep)
end

---@param path string
---@return boolean
local function is_normalized(path)
  return not string.find(path, Path.sep .. ".", 1, true)
    and not string.find(path, "." .. Path.sep, 1, true)
    and not string.find(path, Path.sep .. Path.sep, 1, true)
end

---@param path string
---@return string
local function normalize(path)
  if is_normalized(path) then
    return path
  end

  local normalized_path = ""
  local parts = split_path(path)

  local i, pop = #parts, 0

  repeat
    if parts[i] == ".." then
      pop = pop + 1
    elseif #parts[i] > 0 and parts[i] ~= "." then
      if pop == 0 then
        normalized_path = parts[i] .. Path.sep .. normalized_path
      else
        pop = pop - 1
      end
    end

    i = i - 1
  until i <= 0

  normalized_path = string.gsub(normalized_path, "/$", "", 1)

  local prefix = ""
  if is_absolute(path) then
    prefix = Path.root
  end

  return prefix .. normalized_path
end

---@param ... string
function Path:new(...)
  ---@type LeanPath
  local path = {}

  path._value = table.concat({ ... }, Path.sep)
  if #path._value == 0 then
    path._value = "."
  end

  setmetatable(path, self.__meta__)
  return path
end

---@return boolean
function Path:is_absolute()
  return is_absolute(self._value)
end

---@return string
function Path:absolute()
  if is_absolute(self._value) then
    return normalize(self._value)
  end

  return normalize(cwd() .. Path.sep .. self._value)
end

---@param ... string
---@return LeanPath
function Path:join(...)
  local value = self._value .. Path.sep .. table.concat({ ... }, Path.sep)
  return Path:new(value)
end

function Path:__stat()
  if not self._stat then
    local stat = uv.fs_stat(self:absolute())
    self._stat = stat or {}
  end
  return self._stat
end

---@return boolean
function Path:is_dir()
  return self:__stat().type == "directory"
end

---@return boolean
function Path:is_file()
  return self:__stat().type == "file"
end

return Path
