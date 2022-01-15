local ltable = {}

function ltable.includes(tbl, searchItem)
  for _, item in ipairs(tbl) do
    if item == searchItem then
      return true
    end
  end
  return false
end

function ltable.reverse(tbl)
  local len = #tbl
  local items = {}
  for i, item in ipairs(tbl) do
    items[len - i + 1] = item
  end
  return items
end

return ltable
