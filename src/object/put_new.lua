--[[
Extends the context table by placing the given values at the given keys
unless the key already exists.

Takes a variable length number of arguments and maps them into key value pairs.
Where a key is a path seperated by `.`, the table is traversed creating a nested
table until the value is set on the tip.

## Examples

    OP_RETURN
      $REF
        "user.profile"
        "name"
        "Joe Bloggs"
        |
      $REF
        "account"
        "name"
        "Acme Corp"
    # {
    #   account: {
    #     name: "Acme Corp"
    #   },
    #   user: {
    #     profile: {  
    #       name: "Joe Bloggs,
    #     }
    #   }
    # }

@version 0.0.2
@author Libs
]]--
return function(ctx, path, ...)
  ctx = ctx or {}
  local obj = {}
  assert(
    type(ctx) == 'table',
    'Invalid context. Must receive a table.')
  assert(
    type(path) == 'string' and string.len(path) > 0,
    'Invalid path. Must receive a string.')

  -- Helper function to extend the given object with the path and value.
  -- Splits the path into an array of keys and iterrates over each, either
  -- extending the context object or setting the value on the tip, without
  -- overwriting any existing value.
  local function extend_new(ctx, path, value)
    local keys = {}
    string.gsub(path, '[^%.]+', function(k) table.insert(keys, k) end)
    for i, k in ipairs(keys) do
      if type(ctx) ~= 'table' then
        break
      elseif ctx[k] == nil then
        if i == #keys then ctx[k] = value else ctx[k] = {} end
      end
      ctx = ctx[k]
    end
  end

  -- Iterrate over each vararg pair to get the path and value
  -- Unless path is blank, the PUT object is extended
  for n = 1, select('#', ...) do
    if math.fmod(n, 2) > 0 then
      local path = select(n, ...)
      local value = select(n+1, ...)
      if path ~= nil and string.len(path) > 0 then
        extend_new(obj, path, value)
      end
    end
  end

  -- Extend the context
  extend_new(ctx, path, obj)
  return ctx
end