local lstring = {}

local function split_chars(str, n)
  local str_len = #str
  n = n or str_len

  local parts = {}

  local i = 1
  while i <= str_len do
    parts[i] = string.sub(str, i, i)

    i = i + 1
    if i == n then
      break
    end
  end

  table.insert(parts, string.sub(str, i))

  return parts
end

local function split(str, sep, n)
  if sep == "" then
    return split_chars(str, n)
  end

  local str_len = #str
  n = n or str_len

  local parts = {}

  local i, pos = 1, 1
  local sep_start, sep_end = string.find(str, sep, pos)

  if not sep_start or sep_end < sep_start then
    return { str }
  end

  while pos <= str_len and sep_start do
    parts[i] = string.sub(str, pos, sep_start - 1)
    pos = sep_end + 1

    i = i + 1
    if i == n then
      break
    end

    sep_start, sep_end = string.find(str, sep, pos)
  end

  table.insert(parts, string.sub(str, pos))

  return parts
end

---@param str string
---@param sep string
---@return string[]
function lstring.split(str, sep)
  return split(str, sep)
end

---@param str string
---@param sep string
---@param n number
---@return string[]
function lstring.split_n(str, sep, n)
  if n == 1 then
    return { str }
  end

  return split(str, sep, n)
end

---@param str string
---@param pattern string
---@param plain? boolean
---@return boolean
function lstring.starts_with(str, pattern, plain)
  if plain then
    return string.sub(str, 1, #pattern) == pattern
  end
  return string.find(str, "^" .. pattern) ~= nil
end

---@param str string
---@param pattern string
---@param plain? boolean
---@return boolean
function lstring.ends_with(str, pattern, plain)
  if plain then
    return string.sub(str, -#pattern, -1) == pattern
  end
  return string.find(str, pattern .. "$") ~= nil
end

return lstring
