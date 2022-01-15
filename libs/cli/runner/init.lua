local parse = require("cli.parser")

local runner = {}

-- local function get_root_dir()
--   local level, caller = 3, nil
--   repeat
--     caller = debug.getinfo(level, "S").source
--     level = level + 1
--   until caller ~= "=[C]"
--
--   if string.sub(caller, 1, 1) == "@" then
--     return lpath:new(string.sub(caller, 2), "../lua"):absolute()
--   end
--
--   if string.sub(caller, 1, 7) == "bundle:" then
--     return lpath:new(string.sub(caller, 8), "../lua"):absolute()
--   end
--
--   return lpath:new("./lua"):absolute()
-- end

function runner.run(args, config)
  ---@diagnostic disable-next-line: undefined-field
  args = args or _G.args
  config = config or {}

  local root = config.root_path or "lua.init"

  ---@type LeanCLICommand
  local cmd = require(root)

  local result = parse(args, cmd)

  if result.subcommand then
    return runner.run(result.unparsed_args, {
      root_path = "lua.commands." .. result.subcommand,
      parent_result = result,
    })
  end

  return cmd.run(result)
end

return runner
