local bundle = require("luvi").bundle
loadstring(bundle.readfile("loader.lua"), "bundle:loader.lua")()

local uv = require("uv")

require("cli.runner").run(args)

uv.run()
