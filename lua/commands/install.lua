local lstring = require("lean-string")
local Command = require("cli.command")
local get_pkg_metadata = require("lua.metadata").get_pkg_metadata

local Cmd = Command:new("install")

local source_name_by_prefix = {
  ["luarocks"] = "luarocks",
  ["lit"] = "lit",
}

---@param pkg_name string
---@return { source: string }
local function parse_package_name(pkg_name)
  print(pkg_name)

  local prefix = lstring.split_n(pkg_name, ":", 2)[1]
  local source = source_name_by_prefix[prefix] or "git"

  print(source)

  local uri

  if string.match(pkg_name, "^https?://") then
    uri = pkg_name

    if not lstring.ends_with(uri, ".git", true) then
      uri = uri .. ".git"
    end

    print(uri)
  end

  return {
    source = source,
  }
end

Cmd:run(function(result)
  local pkg = get_pkg_metadata()

  local dependencies = pkg.dependencies

  print("--")
  for pkg_name, info in pairs(dependencies) do
    local package = parse_package_name(pkg_name)
    print("--")
  end
end)

local cmd = Cmd:create()

return cmd
