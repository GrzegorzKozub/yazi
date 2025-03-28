local M = {}

local windows = ya.target_family() == 'windows'

local function find_packer(archive_name)
  local unix = {
    ['%.7z$'] = { cmd = '7z', args = { 'a' } },
    ['%.tar$'] = { cmd = 'tar', args = { 'rpf' } },
    ['%.tar.gz$'] = { cmd = 'tar', args = { 'rpf' }, compressor = 'gzip' },
    ['%.tar.bz2$'] = { cmd = 'tar', args = { 'rpf' }, compressor = 'bzip2' },
    ['%.tar.xz$'] = { cmd = 'tar', args = { 'rpf' }, compressor = 'xz' },
    ['%.tar.zst$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      compressor = 'zstd',
      compressor_args = { '--rm' },
    },
    ['%.zip$'] = { cmd = 'zip', args = { '-r' } },
  }
  local win = {
    ['%.7z$'] = { cmd = '7z', args = { 'a' } },
    ['%.tar$'] = { cmd = 'tar', args = { 'rpf' } },
    ['%.tar.bz2$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      compressor = '7z',
      compressor_args = { 'a', '-tbzip2', '-sdel', archive_name },
    },
    ['%.tar.gz$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      compressor = '7z',
      compressor_args = { 'a', '-tgzip', '-sdel', archive_name },
    },
    ['%.tar.xz$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      compressor = '7z',
      compressor_args = { 'a', '-txz', '-sdel', archive_name },
    },
    ['%.tar.zst$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      compressor = 'zstd',
      compressor_args = { '--rm' },
    },
    ['%.zip$'] = { cmd = '7z', args = { 'a', '-tzip' } },
  }
  for pattern, packer in pairs(windows and win or unix) do
    if archive_name:match(pattern) then
      return packer
    end
  end
  return nil
end

local function installed(cmd)
  local unix = 'command -v %s >/dev/null 2>&1'
  local win = 'where %s > nul 2>&1'
  return os.execute(string.format(windows and win or unix, cmd))
end

local get_paths = ya.sync(function()
  local paths, names, items = {}, {}, {}
  for _, value in pairs(cx.active.selected) do
    paths[#paths + 1] = tostring(value:parent())
    names[#names + 1] = tostring(value:name())
  end
  if #paths == 0 and cx.active.current.hovered then
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
  return items, tostring(cx.active.current.cwd)
end)

local function join(dir, name)
  return tostring(Url(dir):join(Url(name)))
end

local function exists(path)
  local file = io.open(path, 'r')
  if file ~= nil then
    io.close(file)
    return true
  end
  return false
end

local function get_archive_path(dir, name, packer)
  local path = join(dir, name)
  while true do
    if exists(path) then
      return true, path, name
    end
    if packer.compressor and not name:match '%.tar$' then
      name = name:match '(.*%.tar)'
      path = join(dir, name)
    else
      break
    end
  end
  return false, path, name
end

local function str(table)
  local result = ''
  for i, value in ipairs(table) do
    result = result .. (i == 1 and '' or ' ') .. value
  end
  return result
end

local function error(message)
  ya.notify { content = message, level = 'error', timeout = 3, title = 'Compress' }
end

local function success(cmd, args, status, err)
  if not status or not status.success then
    error(
      string.format(
        'Command %s %s ... failed with exit code %s',
        cmd,
        str(args),
        status and status.code or err
      )
    )
    return false
  end
  return true
end

local function pack(items, packer, archive_path)
  for path, names in pairs(items) do
    local status, err = Command(packer.cmd)
      :args(packer.args or {})
      :arg(archive_path)
      :args(names)
      :cwd(path)
      :spawn()
      :wait()
    if not success(packer.cmd, packer.args or {}, status, err) then
      return false
    end
  end
  return true
end

local function compress(packer, archive_temp, cwd)
  local status, err = Command(packer.compressor)
    :args(packer.compressor_args or {})
    :arg(archive_temp)
    :cwd(cwd)
    :spawn()
    :wait()
  if not success(packer.compressor, packer.compressor_args or {}, status, err) then
    return false
  end
  return true
end

M.entry = function()
  ya.manager_emit('escape', { visual = true })
  local archive_name, event =
    ya.input { title = 'Create archive', position = { 'center', w = 48 } }
  if event ~= 1 then
    return
  end
  local packer = find_packer(archive_name)
  if not packer then
    error 'Format not supported'
    return
  end
  if not installed(packer.cmd) then
    error('Command ' .. packer.cmd .. ' not installed')
    return
  end
  if packer.compressor and not installed(packer.compressor) then
    error('Command ' .. packer.compressor .. ' not installed')
    return
  end
  local items, cwd = get_paths()
  if next(items) == nil then
    return
  end
  local archive_exists, archive_path, archive_temp = get_archive_path(cwd, archive_name, packer)
  if archive_exists then
    error('File ' .. archive_temp .. ' already exists')
    return
  end
  if not pack(items, packer, archive_path) then
    return
  end
  if packer.compressor and not compress(packer, archive_temp, cwd) then
    return
  end
  ya.notify {
    content = 'Created archive ' .. archive_name,
    level = 'info',
    timeout = 3,
    title = 'Compress',
  }
end

return M
