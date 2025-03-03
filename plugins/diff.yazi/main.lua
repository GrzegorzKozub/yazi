local M = {}

local get_paths = ya.sync(function()
  local paths = {}
  for _, value in pairs(cx.active.selected) do
    paths[#paths + 1] = value
  end
  local h = cx.active.current.hovered.url
  if paths[#paths] ~= h then
    paths[#paths + 1] = h
  end
  return paths
end)

local filter_files = function(paths)
  local files = {}
  for _, value in ipairs(paths) do
    if not fs.cha(value).is_dir then
      files[#files + 1] = tostring(value)
    end
  end
  if #files < 2 then
    return {}, 'Not enough files selected'
  end
  return { files[#files - 1], files[#files] }, nil
end

M.entry = function()
  local files, err = filter_files(get_paths())
  if err then
    ya.notify { content = err, level = 'error', timeout = 3, title = 'Diff' }
    return
  end
  ya.mgr_emit('shell', {
    'nvim -d ' .. files[1] .. ' ' .. files[2],
    block = true,
    orphan = true,
  })
end

return M