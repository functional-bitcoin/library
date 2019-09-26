--[[
Calculates Fibonacci numbers using tail-optimised recursion.

Takes a variable length number of integers and maps them into an array of
Fibonacci numbers.

## Examples

    OP_RETURN
      $REF
        "10"
        "55"
    # [55, 139583862445]

@version 0.0.1
@author Libs
]]--
return function(ctx, ...)
  ctx = ctx or {}
  assert(
    type(ctx) == 'table',
    'Invalid context. Must receive a table.')

  -- Local function to derive the nth Fib number using tail-optimised recusion.
  local function trfib(n, u, s)
    if n < 2 then
      return u + s
    else
      return trfib(n-1, u+s, u)
    end
  end

  local function fib(n)
    return trfib(n-1, 1, 0)
  end

  -- Iterrate over each vararg number and insert Fib number into context.
  for i, n in ipairs({...}) do
    local n = tonumber(n)
    if n ~= nil then table.insert(ctx, fib(n)) end
  end
 
  return ctx
end