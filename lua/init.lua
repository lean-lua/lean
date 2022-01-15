local Command = require("cli.command")
local Parameter = require("cli.parameter")

local Lean = Command:new("lean")

Lean:subcommands({
  "install",
  "run",
  "help",
})

Lean:parameter(
  "alpha",
  Parameter
    :new({
      long = "alpha",
      short = "a",
    })
    :parse(function(v)
      return tonumber(v)
    end)
    :takes_value()
    :create()
)

Lean:run(function(result)
  for _, iv in ipairs(result.dump()) do
    print(iv[1], iv[2], type(iv[2]))
  end
end)

local cmd = Lean:create()

return cmd
