local M = {}

local get_paths = ya.sync(function()
  local paths = {}
  for _, u in pairs(cx.active.selected) do
    paths[#paths + 1] = tostring(u)
  end
  if #paths == 0 then
    if cx.active.current.cwd then
      paths[1] = tostring(cx.active.current.cwd)
    else
      ya.err 'what-size would return nil paths'
    end
  end
  return paths
end)

local get_total_size = function(s)
  local lines = {}
  for line in s:gmatch '[^\n]+' do
    lines[#lines + 1] = line
  end
  local last_line = lines[#lines]
  local last_line_parts = {}
  for part in last_line:gmatch '%S+' do
    last_line_parts[#last_line_parts + 1] = part
  end
  local total_size = last_line_parts[1]
  return total_size
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

M.entry = function(self, job)
  local clipboard = job.args.clipboard or job.args[1] == '-c'
  local items = get_paths()

  local cmd = 'du'
  local output, err = Command(cmd):arg('-scb'):args(items):output()
  if not output then
    ya.err('Failed to run diff, error: ' .. err)
  else
    local total_size = get_total_size(output.stdout)
    local formatted_size = format_size(tonumber(total_size))

    local notification_content = 'Total size: ' .. formatted_size
    if clipboard then
      ya.clipboard(formatted_size)
      notification_content = notification_content .. '\nCopied to clipboard.'
    end

    ya.notify {
      title = 'Size',
      content = notification_content,
      timeout = 10,
    }
  end
end

return M
