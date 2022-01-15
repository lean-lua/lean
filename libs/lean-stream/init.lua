local uv = require("uv")

local UVStream = {}

function UVStream:new(stream)
  assert(
    stream
      and stream.write
      and stream.shutdown
      and stream.read_start
      and stream.read_stop
      and stream.is_closing
      and stream.close,
    "stream does not appear to be a uv_stream_t"
  )

  local state = {
    stream = stream,
    read = false,
    written = false,
    errored = false,
  }

  return setmetatable({
    _ = state,
  }, {
    __index = self,
  })
end

function UVStream:close()
  local state = self._

  if state.closed then
    return
  end

  state.closed = true

  if not state.readClosed then
    state.readClosed = true

    if state.onClose then
      state.onClose()
    end
  end

  if not state.stream:is_closing() then
    state.stream:close()
  end
end

function UVStream:read() end

return {
  UVStream = UVStream,
}
