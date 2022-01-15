local Queue = {}

function Queue:new()
  return setmetatable({ first = 0, last = -1 }, { __index = self })
end

function Queue:is_empty()
  return self.first > self.last
end

function Queue:push_left(value)
  local first = self.first - 1
  self.first = first
  self[first] = value
end

function Queue:push_right(value)
  local last = self.last + 1
  self.last = last
  self[last] = value
end

function Queue:pop_left()
  local first = self.first
  if first > self.last then
    error("queue is empty")
  end
  local value = self[first]
  self[first] = nil
  self.first = first + 1
  return value
end

function Queue:pop_right()
  local last = self.last
  if self.first > last then
    error("queue is empty")
  end
  local value = self[last]
  self[last] = nil
  self.last = last - 1
  return value
end

return Queue
