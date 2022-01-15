local Future = {}

function Future.from_callback(func)
  return function(...)
    local co = coroutine.running()
    func(..., function(...)
      local ok, err = coroutine.resume(co, ...)
      if not ok then
        error(err, 2)
      end
    end)
    return coroutine.yield()
  end
end

return Future
