local bundle = require("luvi").bundle
loadstring(bundle.readfile("loader.lua"), "bundle:loader.lua")()

local pp = require("pp").prettyPrint
local uv = require("uv")

-- require("cli.runner").run(args)

local TCP = require("lean-net").TCP

local server = TCP:new()
server:bind("127.0.0.1", 1337)
server:listen(function(err, client)
  if err then
    print("err", err)
    return
  end

  client:read_start(function(err, chunk)
    assert(not err, err)
    if chunk then
      client:write(chunk)
    else
      client:shutdown()
      client:close()
    end
  end)
end)

-- server:listen(128, function (err)
--   assert(not err, err)
--   local client = uv.new_tcp()
--   server:accept(client)
--   client:read_start(function (err, chunk)
--     assert(not err, err)
--     if chunk then
--       client:write(chunk)
--     else
--       client:shutdown()
--       client:close()
--     end
--   end)
-- end)

uv.run()
