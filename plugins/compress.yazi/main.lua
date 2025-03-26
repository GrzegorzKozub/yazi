local M = {}

local get_items = ya.sync(function()
  local paths, names, items = {}, {}, {}
  for _, value in pairs(cx.active.selected) do
    paths[#paths + 1] = tostring(value:parent())
    names[#names + 1] = tostring(value:name())
  end
  if #paths == 0 then
    local h = cx.active.current.hovered
    paths[1] = tostring(h.url:parent())
    names[1] = tostring(h.name)
  end
  for index, value in ipairs(names) do
    if not items[paths[index]] then
      items[paths[index]] = {}
    end
    table.insert(items[paths[index]], value)
  end
  return items
end)

local function commands(archive)
  local unix = {
    ['%.7z$'] = { cmd = '7z', args = { 'a' } },
    ['%.tar$'] = { cmd = 'tar', args = { 'rpf' } },
    ['%.tar.gz$'] = { cmd = 'tar', args = { 'rpf' }, fmt = 'gzip' },
    ['%.tar.bz2$'] = { cmd = 'tar', args = { 'rpf' }, fmt = 'bzip2' },
    ['%.tar.xz$'] = { cmd = 'tar', args = { 'rpf' }, fmt = 'xz' },
    ['%.tar.zst$'] = { cmd = 'tar', args = { 'rpf' }, fmt = 'zstd', fmt_args = { '--rm' } },
    ['%.zip$'] = { cmd = 'zip', args = { '-r' } },
  }
  local windows = {
    ['%.7z$'] = { cmd = '7z', args = { 'a' } },
    ['%.tar$'] = { cmd = 'tar', args = { 'rpf' } },
    ['%.tar.bz2$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      fmt = '7z',
      fmt_args = { 'a', '-tbzip2', '-sdel', archive },
    },
    ['%.tar.gz$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      fmt = '7z',
      fmt_args = { 'a', '-tgzip', '-sdel', archive },
    },
    ['%.tar.xz$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      fmt = '7z',
      fmt_args = { 'a', '-txz', '-sdel', archive },
    },
    ['%.tar.zst$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      fmt = 'zstd',
      fmt_args = { '--rm' },
    },
    ['%.zip$'] = { cmd = '7z', args = { 'a', '-tzip' } },
  }
  return ya.target_family() == 'windows' and windows or unix
end

local function command(archive)
  local cmds = commands(archive)
end

M.entry = function()
  ya.manager_emit('escape', { visual = true })
  local items = get_items()
  local archive, event = ya.input { title = 'Create archive', position = { 'center', w = 48 } }
  if event ~= 1 then
    return
  end
  local cmds = command(archive)
  ya.notify {
    content = 'cmprs ' .. archive,
    level = 'info',
    timeout = 3,
    title = 'Compress',
  }
end

return M
