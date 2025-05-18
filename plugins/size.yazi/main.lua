local M = {}

local get_paths = ya.sync(function()
  local paths, selected = {}, nil
  for _, value in pairs(cx.active.selected) do
    paths[#paths + 1] = tostring(value)
  end
  if #paths == 0 then
    local h = cx.active.current.hovered.url
    paths[1] = tostring(h)
    selected = h.name
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

-- local get_total = function(paths)
--   local output, err = Command('du'):arg('-bcs'):arg(paths):output()
--   if not output then
--     return nil, tostring(err)
--   end
--   for size, name in output.stdout:gmatch '(%d+)%s+([^\n]+)' do
--     if name == 'total' then
--       return format(tonumber(size)), nil
--     end
--   end
-- end

local get_total = function(paths)
  local total = 0
  for _, value in ipairs(paths) do
    local it = fs.calc_size(Url(value))
    while true do
      local found = it:recv()
      if found then
        total = total + found
      else
        break
      end
    end
  end
  return format(total)
end

M.entry = function()
  ya.manager_emit('escape', { visual = true })
  local paths, selected = get_paths()
  -- local total, err = get_total(paths)
  -- if err then
  --   ya.notify { content = err, level = 'error', timeout = 3, title = 'Size' }
  --   return
  -- end
  local total = get_total(paths)
  ya.notify {
    content = selected .. (type(selected) == 'number' and ' selected' or '') .. ': ' .. total,
    level = 'info',
    timeout = 3,
    title = 'Size',
  }
end

return M
