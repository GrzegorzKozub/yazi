local M = {}

local windows = ya.target_family() == 'windows'

local get_paths = ya.sync(function()
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
  return items, cx.active.current.cwd
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

local function get_archive_path(dir, name, cmd)
  local path = join(dir, name)
  while true do
    if exists(path) then
      return true, path, name
    end
    if cmd.fmt and not name:match '%.tar$' then
      name = name:match '(.*%.tar)'
      path = join(dir, name)
    else
      break
    end
  end
  return false, path, name
end

local function find_command(archive_name)
  local unix = {
    ['%.7z$'] = { cmd = '7z', args = { 'a' } },
    ['%.tar$'] = { cmd = 'tar', args = { 'rpf' } },
    ['%.tar.gz$'] = { cmd = 'tar', args = { 'rpf' }, fmt = 'gzip' },
    ['%.tar.bz2$'] = { cmd = 'tar', args = { 'rpf' }, fmt = 'bzip2' },
    ['%.tar.xz$'] = { cmd = 'tar', args = { 'rpf' }, fmt = 'xz' },
    ['%.tar.zst$'] = { cmd = 'tar', args = { 'rpf' }, fmt = 'zstd', fmt_args = { '--rm' } },
    ['%.zip$'] = { cmd = 'zip', args = { '-r' } },
  }
  local win = {
    ['%.7z$'] = { cmd = '7z', args = { 'a' } },
    ['%.tar$'] = { cmd = 'tar', args = { 'rpf' } },
    ['%.tar.bz2$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      fmt = '7z',
      fmt_args = { 'a', '-tbzip2', '-sdel', archive_name },
    },
    ['%.tar.gz$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      fmt = '7z',
      fmt_args = { 'a', '-tgzip', '-sdel', archive_name },
    },
    ['%.tar.xz$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      fmt = '7z',
      fmt_args = { 'a', '-txz', '-sdel', archive_name },
    },
    ['%.tar.zst$'] = {
      cmd = 'tar',
      args = { 'rpf' },
      fmt = 'zstd',
      fmt_args = { '--rm' },
    },
    ['%.zip$'] = { cmd = '7z', args = { 'a', '-tzip' } },
  }
  for pattern, cmd in pairs(windows and win or unix) do
    if archive_name:match(pattern) then
      return cmd
    end
  end
  return nil
end

local function installed(cmd)
  local unix = 'command -v %s >/dev/null 2>&1'
  local win = 'where %s > nul 2>&1'
  return os.execute(string.format(windows and win or unix, cmd))
end

local function error(message)
  ya.notify { content = message, level = 'error', timeout = 3, title = 'Compress' }
end

M.entry = function()
  ya.manager_emit('escape', { visual = true })
  local archive_name, event =
    ya.input { title = 'Create archive', position = { 'center', w = 48 } }
  if event ~= 1 then
    return
  end
  local cmd = find_command(archive_name)
  if not cmd then
    error 'Format not supported'
    return
  end
  if not installed(cmd.cmd) then
    error('Command ' .. cmd.cmd .. ' not installed')
    return
  end
  if cmd.fmt and not installed(cmd.fmt) then
    error('Command ' .. cmd.fmt .. ' not installed')
    return
  end
  local items, cwd = get_paths()
  local archive_exists, archive_path
  archive_exists, archive_path, archive_name = get_archive_path(cwd, archive_name, cmd)
  if archive_exists then
    error('File ' .. archive_name .. ' already exists')
    return
  end

  -- Add to output archive in each path, their respective files
  -- for path, names in pairs(path_fnames) do
  -- 	local archive_status, archive_err =
  -- 		Command(archive_cmd):args(archive_args):arg(output_url):args(names):cwd(path):spawn():wait()
  -- 	if not archive_status or not archive_status.success then
  -- 		notify_error(
  -- 			string.format(
  -- 				"%s with selected files failed, exit code %s",
  -- 				archive_args,
  -- 				archive_status and archive_status.code or archive_err
  -- 			),
  -- 			"error"
  -- 		)
  -- 	end
  -- end

  -- Use compress command if needed
  -- if archive_compress then
  -- 	local compress_status, compress_err =
  -- 		Command(archive_compress):args(archive_compress_args):arg(output_name):cwd(output_dir):spawn():wait()
  -- 	if not compress_status or not compress_status.success then
  -- 		notify_error(
  -- 			string.format(
  -- 				"%s with %s failed, exit code %s",
  -- 				archive_compress,
  -- 				output_name,
  -- 				compress_status and compress_status.code or compress_err
  -- 			),
  -- 			"error"
  -- 		)
  -- 	end
  -- end

  ya.notify {
    content = 'cmprs ' .. archive_path,
    level = 'info',
    timeout = 3,
    title = 'Compress',
  }
end

return M
