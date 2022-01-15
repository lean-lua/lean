local Command = require("cli.command")
local Parameter = require("cli.parameter")
local get_pkg_metadata = require("lua.metadata").get_pkg_metadata

local Run = Command:new("run")

Run:parameter(
  "script",
  Parameter
    :new({
      position = 1,
      required = true,
    })
    :create()
)

Run:run(function(result)
  local metadata = get_pkg_metadata()
  local script_name = result.value("script")

  print(string.format("script(%s): %s", script_name, metadata.scripts[script_name] or "nil"))
end)

local cmd = Run:create()

return cmd
