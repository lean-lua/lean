local uv = require("uv")
local Future = require("lean-future")
local Queue = require("lean-queue")

---@class LeanNetTcp
local TCP = {}

function TCP:new()
  ---@type LeanNetTcp
  local tcp = {
    _ = uv.new_tcp(),
    queue = Queue:new(),
  }

  setmetatable(tcp, {
    __index = self,
  })

  return tcp
end

function TCP:bind(addr, port, flags)
  local ok = self._:bind(addr, port, flags) == 0
  if not ok then
    error()
  end
end

---@param backlog? number
function TCP:listen(handler, backlog)
  backlog = backlog or 128

  self._:listen(backlog, function(err)
    if err then
      handler(err)
      return
    end

    local client = uv.new_tcp()
    self._:accept(client)
    handler(nil, client)
  end)
end

return {
  TCP = TCP,
}
