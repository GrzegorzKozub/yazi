local M = {}

local get_paths = ya.sync(function()
  local paths, selected = {}, true
  for _, value in pairs(cx.active.selected) do
    paths[#paths + 1] = tostring(value)
  end
  if #paths == 0 then
    paths[1] = tostring(cx.active.current.cwd)
    selected = false
  end
  return paths, selected
end)

local fetch_size = function(paths)
  local output, err = Command('du'):arg('-scb'):args(paths):output()
  if not output then
    return nil, tostring(err)
  end
  return output.stdout, nil
end

local get_total_size = function(sizes)
  for size, name in sizes:gmatch '(%d+)%s+([^\n]+)' do
    if name == 'total' then
      return size
    end
  end
end

local function format_size(size)
  local units = { 'B', 'KB', 'MB', 'GB', 'TB' }
  local unit_index = 1
  while size > 1024 and unit_index < #units do
    size = size / 1024
    unit_index = unit_index + 1
  end
  return string.format('%.2f %s', size, units[unit_index])
end

M.entry = function()
  local items, selected = get_paths()
  local output, err = fetch_size(items)
  if err then
    ya.notify { level = 'error', title = 'size', content = err, timeout = 10 }
    return
  end
  local total_size = get_total_size(output)
  local formatted_size = format_size(tonumber(total_size))
  local notification_content = 'Total size: ' .. formatted_size
  ya.notify {
    title = 'Size',
    content = notification_content,
    timeout = 10,
  }
end

return M
