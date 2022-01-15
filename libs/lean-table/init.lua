local ltable = {}

function ltable.includes(tbl, searchItem)
  for _, item in ipairs(tbl) do
    if item == searchItem then
      return true
    end
  end
  return false
end

return ltable
