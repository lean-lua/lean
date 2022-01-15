if not table.unpack then
  table.unpack = unpack
end

local function patch_package_path()
  package.path = package.path .. ";lua/?.lua;lua/?/init.lua"
  package.path = package.path .. ";libs/?.lua;libs/?/init.lua"
  package.path = package.path .. ";deps/?.lua;deps/?/init.lua"
end

patch_package_path()
