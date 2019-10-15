--[[
Implements the Magic Attribute Protocol. Depending on the given mode, the
state is either extended with the given values at the given keys (overriding
values where keys already exist), or the given keys are deleted from the state.

In addition a `_MAP` attribute is attached to the state listing the mapping
changes.

## Examples

    OP_FALSE OP_RETURN
      $REF
        "SET"
        "user.name"
        "Joe Bloggs"
        "user.age"
        20
    # {
    #   user: {
    #     age: 20,
    #     name: "Joe Bloggs"
    #   },
    #   _MAP: {
    #     PUT: {
    #       "user.age": 20,
    #       "user.name": "Joe Bloggs"
    #     }
    #   }
    # }

@version 0.1.0
@author Libs
]]--
return function(state, mode, ...)
  state = state or {}
  local obj = {}
  local mode = string.upper(mode or '')
  assert(
    type(state) == 'table',
    'Invalid state type.')
  assert(
    mode == 'SET' or mode == 'DELETE',
    'Invalid MAP mode. Must be SET or DELETE.')

  -- Helper function to extend the given object with the path and value.
  -- Splits the path into an array of keys and iterrates over each, either
  -- extending the state object or setting the value on the tip.
  local function extend(state, path, value)
    local keys = {}
    string.gsub(path, '[^%.]+', function(k) table.insert(keys, k) end)
    for i, k in ipairs(keys) do
      if i == #keys then
        state[k] = value
      elseif type(state[k]) ~= 'table' then
        state[k] = {}
      end
      state = state[k]
    end
  end

  -- Helper function to drop the path from the given object.
  -- Splits the path into an array of keys and traverses the state object
  -- until it nullifies the tip.
  local function drop(state, path)
    local keys = {}
    string.gsub(path, '[^%.]+', function(k) table.insert(keys, k) end)
    for i, k in ipairs(keys) do
      if type(state) ~= 'table' then
        break
      elseif state[k] ~= nil then
        if i == #keys then state[k] = nil end
      end
      state = state[k]
    end
  end

  if mode == 'SET' then
    -- Iterrate over each vararg pair to get the path and value
    -- Unless path is blank, the state is extended
    for n = 1, select('#', ...) do
      if math.fmod(n, 2) > 0 then
        local path = select(n, ...)
        local value = select(n+1, ...)
        
        if path ~= nil and string.len(path) > 0 then
          obj[path] = value
          extend(state, path, value)
        end
      end
    end
  elseif mode == 'DELETE' then
    -- Iterrate over each vararg and drop from the state
    for i, path in ipairs({...}) do
      table.insert(obj, path)
      drop(state, path)
    end
  end
  
  -- Attach mapping to state
  state['_MAP'] = {}
  state['_MAP'][mode] = obj

  return state
end