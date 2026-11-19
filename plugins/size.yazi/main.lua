local M = {}

local get_paths = ya.sync(function()
  local paths = {}
  local selected
  for _, value in pairs(cx.active.selected) do
    paths[#paths + 1] = tostring(value.url)
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

local get_total = function(paths)
  local total = 0
  for _, value in ipairs(paths) do
    local it, err = fs.calc_size(Url(value))
    if not it then
      return nil, tostring(err)
    end
    for size, e in it do
      if not size then
        return nil, tostring(e)
      end
      total = total + size
    end
  end
  return format(total), nil
end

M.entry = function()
  ya.emit('escape', { visual = true })
  local paths, selected = get_paths()
  local total, err = get_total(paths)
  if err then
    ya.notify { content = err, level = 'error', timeout = 3, title = 'Size' }
    return
  end
  ya.notify {
    content = selected .. (type(selected) == 'number' and ' selected' or '') .. ': ' .. total,
    level = 'info',
    timeout = 3,
    title = 'Size',
  }
end

return M
