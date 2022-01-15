local lpath = require("lean-path")

---@class LeanPackageMetadata
---@field private boolean
---@field name string
---@field version string
---@field license string
---@field homepage string
---@field description string
---@field author { name: string, email?: string, url?: string }
---@field dependencies table
---@field scripts table<string, string>

---@param filepath string
---@return string
local function read_file(filepath)
  local file, err = io.open(filepath, "r")
  if not file then
    error(err)
  end
  local content = file:read("*a")
  io.close(file)
  return content
end

---@param content string
---@param chunkname string
---@return LeanPackageMetadata
local function load_data(content, chunkname)
  local load = loadstring(content, chunkname)

  local env = {}
  setfenv(load, env)

  local data = load()
  if type(data) == "nil" then
    data = env
  end

  return data
end

---@param metadata LeanPackageMetadata
---@return LeanPackageMetadata
local function normalize_pkg_metadata(metadata)
  if type(metadata.author) == "string" then
    metadata.author = {
      name = metadata.author,
    }
  end

  if not metadata.scripts then
    metadata.scripts = {}
  end

  if not metadata.dependencies then
    metadata.dependencies = {}
  end

  return metadata
end

---@param content string
---@param tag string
---@return string
local function extract_tagged_comment_content(content, tag)
  local start_s, start_e, level = string.find(content, "%-%-%[(=*)%[" .. tag)
  if not start_s then
    error(string.format("failed to extract tagged comment: %s"), tag)
  end

  local end_s, end_e = string.find(content, "]" .. level .. "]", start_e + 1, true)
  if not end_s then
    error(string.format("failed to extract tagged comment: %s"), tag)
  end

  local extracted_content = string.sub(content, start_e + 1, end_s - 1)

  return extracted_content
end

---@param pkg_root LeanPath
---@param metadata_filename string
---@param metadata_comment_tag string
---@return { path: string, content: string }
local function get_pkg_file(pkg_root, metadata_filename, metadata_comment_tag)
  local should_scan_comment = false

  ---@type LeanPath
  local filepath

  if pkg_root:is_file() then
    filepath = pkg_root
  elseif pkg_root:is_dir() then
    filepath = pkg_root:join(metadata_filename)

    if not filepath:is_file() then
      filepath = pkg_root:join("init.lua")
      should_scan_comment = true
    end

    if not filepath:is_file() then
      filepath = nil
    end
  end

  if not filepath then
    error("failed to find package metadata file")
  end

  local path = filepath:absolute()
  local content = read_file(path)

  if should_scan_comment then
    content = extract_tagged_comment_content(content, metadata_comment_tag)
  end

  return {
    path = path,
    content = content,
  }
end

---@param path? string
---@return LeanPackageMetadata
local function get_pkg_metadata(path)
  local pkg_path = lpath:new(path or ".")
  local should_scan_comment = false

  local file = get_pkg_file(pkg_path, "lean.pkg.lua", "@lean.pkg")

  local metadata = normalize_pkg_metadata(load_data(file.content, file.path))

  return metadata
end

return {
  get_pkg_metadata = get_pkg_metadata,
}
