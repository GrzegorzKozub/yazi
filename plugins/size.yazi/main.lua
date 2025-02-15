local M = {}

local get_paths = ya.sync(function()
  local paths, selected = {}, 0
  for _, value in pairs(cx.active.selected) do
    paths[#paths + 1] = tostring(value)
  end
  if #paths == 0 then
    paths[1] = tostring(cx.active.current.cwd)
  else
    selected = #paths
  end
  return paths, selected
end)

local function format(bytes)
  local size, units, index = bytes, { 'B', 'K', 'M', 'G', 'T' }, 1
  while size > 1024 and index < #units do
    size = size / 1024
    index = index + 1
  end
  return string.format('%.1f%s', size, units[index])
end

local get_total = function(paths)
  local output, err = Command('du'):arg('-bcs'):args(paths):output()
  if not output then
    return nil, tostring(err)
  end
  for size, name in output.stdout:gmatch '(%d+)%s+([^\n]+)' do
    if name == 'total' then
      return format(tonumber(size)), nil
    end
  end
end

M.entry = function()
  local paths, selected = get_paths()
  local total, err = get_total(paths)
  if err then
    ya.notify { content = err, level = 'error', timeout = 5, title = 'Size' }
    return
  end
  ya.notify {
    content = (selected > 0 and 'Selected ' .. selected .. ' items: ' or 'Current dir: ')
      .. total,
    -- level = 'info',
    timeout = 5,
    title = 'Size',
  }
end

return M
