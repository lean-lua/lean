local Result = require("cli.parser.result")
local ArgList = require("cli.parser.arg_list")
local lstring = require("lean-string")
local ltable = require("lean-table")

local function is_defined(value)
  return value ~= nil
end

---@param map table<string, any>
---@param key string
---@return boolean
local function table_has(map, key)
  return is_defined(map[key])
end

---@generic V
---@param map table<string, V>
---@param key string
---@return V
local function table_get(map, key)
  return map[key]
end

---@generic V
---@param map table<string, V>
---@param key string
---@param value V
local function table_set(map, key, value)
  map[key] = value
end

local function object_clone(object)
  local result = {}
  for key, value in pairs(object) do
    result[key] = value
  end
  return result
end

local function object_assign(target, source)
  for key, value in pairs(source) do
    target[key] = value
  end
  return target
end

---@param parameter LeanCLIParameter
---@return LeanCLIParameter|{ id: string }
local function get_parameter_with_id(parameter, id)
  return object_assign(object_clone(parameter), { id = id })
end

---@param args string[]
---@param command LeanCLICommand
---@return LeanCLIResult
local function parse(args, command)
  ---@alias ParameterWithId LeanCLIParameter|{ id: string }

  local parameters, subcommands = command.parameters, command.subcommands

  local position_set = {}

  ---@type table<string, ParameterWithId>
  local long_params = {}
  ---@type table<string, ParameterWithId>
  local short_params = {}
  ---@type ParameterWithId[]
  local positional_parameters = {}

  local result = Result:new()

  for id, parameter in pairs(parameters) do
    if is_defined(parameter.long) then
      if table_has(long_params, parameter.long) then
        error(string.format("duplicate long parameter name: --%s", parameter.long))
      end

      table_set(long_params, parameter.long, get_parameter_with_id(parameter, id))

      if is_defined(parameter.long_aliases) then
        for _, long_alias in ipairs(parameter.long_aliases) do
          if table_has(long_params, long_alias) then
            error(string.format("duplicate long parameter alias: --%s", long_alias))
          end

          table_set(long_params, long_alias, get_parameter_with_id(parameter, id))
        end
      end
    end

    if is_defined(parameter.short) then
      if table_has(short_params, parameter.short) then
        error(string.format("duplicate short parameter name: -%s", parameter.short))
      end

      table_set(short_params, parameter.short, get_parameter_with_id(parameter, id))

      if is_defined(parameter.short_aliases) then
        for _, short_alias in ipairs(parameter.short_aliases) do
          if table_has(short_params, short_alias) then
            error(string.format("duplicate short parameter alias: -%s", short_alias))
          end

          table_set(short_params, short_alias, get_parameter_with_id(parameter, id))
        end
      end
    end

    if not is_defined(parameter.long) and not is_defined(parameter.short) then
      if is_defined(parameter.position) then
        if table_get(position_set, parameter.position) then
          error(string.format("duplicate parameter position: %d", parameter.position))
        end

        table_set(position_set, parameter.position, true)

        positional_parameters[parameter.position] = get_parameter_with_id(parameter, id)
      else
        positional_parameters[#positional_parameters + 1] = get_parameter_with_id(parameter, id)
      end
    end

    if is_defined(parameter.default_value) then
      result:set_value(id, parameter.default_value)
    end
  end

  local arg_list = ArgList:new(args)

  local arg = arg_list:peek()

  while arg do
    arg_list:consume()

    if lstring.starts_with(arg, "--", true) then
      -- long parameter

      local name, value = table.unpack(lstring.split_n(string.sub(arg, 3), "=", 2))

      local parameter = table_get(long_params, name)

      if parameter then
        local id = parameter.id

        local count = result:get_count(id)

        if not parameter.multiple and count > 0 then
          error(string.format("multiple value passed to parameter: %s", id))
        end

        result:increment_count(id)

        if parameter.takes_value then
          -- parameter:option

          if not value then
            local next_arg = arg_list:peek()

            if next_arg and not lstring.starts_with(next_arg, "-", true) then
              arg_list:consume()
              value = next_arg
            end

            if value then
              if parameter.valid then
                if not parameter.valid(value) then
                  error(string.format("invalid value (%s) for parameter: %s", value, id))
                end
              end

              if parameter.parse then
                result:set_value(id, parameter.parse(value))
              else
                result:set_value(id, value)
              end
            elseif is_defined(parameter.default_value) then
              result:set_value(id, parameter.default_value)
            else
              error(string.format("missing value for parameter: %s", id))
            end
          end
        else
          -- parameter:flag

          result:set_value(id, true)
        end
      end
    elseif lstring.starts_with(arg, "-", true) and #arg > 1 then
      -- short parameter

      local name, rest = table.unpack(lstring.split_n(string.sub(arg, 2), "", 2))

      local parameter = table_get(short_params, name)

      if parameter then
        local id = parameter.id

        local count = result:get_count(id)

        if not parameter.multiple and count > 0 then
          error(string.format("multiple value passed to parameter: %s", id))
        end

        result:increment_count(id)

        if parameter.takes_value then
          -- parameter:option

          local value

          if #rest > 0 then
            value = string.gsub(rest, "^=", "")
          else
            local next_arg = arg_list:peek()

            if next_arg and not lstring.starts_with(next_arg, "-", true) then
              arg_list:consume()

              value = next_arg
            end
          end

          if value then
            if parameter.valid then
              if not parameter.valid(value) then
                error(string.format("invalid value (%s) for parameter: %s", value, id))
              end

              if parameter.parse then
                result:set_value(id, parameter.parse(value))
              else
                result:set_value(id, value)
              end
            end
          elseif is_defined(parameter.default_value) then
            result:set_value(id, parameter.default_value)
          else
            error(string.format("missing value for parameter: %s", id))
          end
        else
          -- parameter:flag

          result:set_value(id, true)

          if #rest then
            -- stacked short parameter

            arg_list:add("-" .. rest)
          end
        end
      end
    else
      -- positional parameter

      if ltable.includes(subcommands, arg) then
        result:set_subcommand(arg)
        result:set_unparsed_args(arg_list:drain())
        break
      end

      if #positional_parameters > 0 then
        local parameter = positional_parameters[1]

        if parameter then
          local id = parameter.id

          result:increment_count(id)

          if not parameter.multiple_value then
            table.remove(positional_parameters, 1)
          end

          local value = arg

          if parameter.valid then
            if not parameter.valid(value) then
              error(string.format("invalid value (%s) for parameter: %s", value, id))
            end
          end

          if parameter.parse then
            result:set_value(id, parameter.parse(value))
          else
            result:set_value(id, value)
          end
        end
      end
    end

    arg = arg_list:peek()
  end

  for id, parameter in pairs(parameters) do
    if parameter.required then
      if result:get_count(id) < 1 then
        error(string.format("missing required parameter: %s", id))
      end
    end
  end

  return result:create()
end

return parse
