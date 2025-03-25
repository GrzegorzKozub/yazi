local M = {}

local function size_color(size)
  if size < 1024 then
    return 'darkgray'
  elseif size < 1024 ^ 2 then
    return 'gray'
  elseif size < 1024 ^ 3 then
    return 'yellow'
  elseif size < 1024 ^ 4 then
    return 'red'
  else
    return 'brightred'
  end
end

local function size()
  local h = cx.active.current.hovered
  if not h then
    return ui.Span ''
  end
  local s = h:size() or h.cha.len
  return ui.Span(string.format('%7s', ya.readable_size(s))):fg(size_color(s))
end

local function owner_color(owner)
  if owner == 'root' then
    return 'red'
  elseif owner == 'greg' then
    return 'darkgray'
  else
    return 'yellow'
  end
end

local function owner()
  local h = cx.active.current.hovered
  if not h or ya.target_family() ~= 'unix' then
    return ui.Span ''
  end
  local o = ya.user_name(h.cha.uid) or tostring(h.cha.uid)
  return ui.Span(o):fg(owner_color(o))
end

local function permissions()
  local h = cx.active.current.hovered
  if not h or ya.target_family() ~= 'unix' then
    return ui.Span ''
  end
  local perm = h.cha:perm()
  local spans = {}
  for i = 1, #perm do
    local sign, style = perm:sub(i, i), th.status.perm_type
    if sign == 'r' then
      style = th.status.perm_read
    elseif sign == 'w' then
      style = th.status.perm_write
    elseif sign == 'x' then
      style = th.status.perm_exec
    elseif sign == '-' then
      style = th.status.perm_sep
    end
    spans[i] = ui.Span(sign):style(style)
  end
  return ui.Line(spans)
end

local function year(date)
  return tonumber(os.date('%Y', date))
end

local function modified()
  local h = cx.active.current.hovered
  if not h then
    return ui.Span ''
  end
  local m = math.floor(h.cha.mtime)
  local now = math.floor(ya.time())
  local format = year(m) < year(now) and '%d %b  %Y' or '%d %b %H:%M'
  return ui.Span(tostring(os.date(format, m)):lower()):fg 'gray'
end

local function name()
  local h = cx.active.current.hovered
  if not h then
    return ui.Span ''
  end
  local n = h:icon().text .. ' ' .. h.url:name()
  return ui.Span(n):style(h:style())
end

local function link()
  local h = cx.active.current.hovered
  if not h or not h.link_to then
    return ui.Span ''
  end
  local l = '-> ' .. tostring(h.link_to)
  return h.cha.is_orphan and ui.Span(l):fg 'red' or ui.Span(l):style(h:style())
end

local function mode_style(mode)
  if mode.is_select then
    return th.mode.select_main
  elseif mode.is_unset then
    return th.mode.unset_main
  else
    return th.mode.normal_main
  end
end

local function mode()
  local m = tostring(cx.active.mode):sub(1, 1)
  if m == 'n' then
    return ui.Span '    '
  end
  return ui.Span(' ' .. m .. ' '):style(mode_style(cx.active.mode))
end

local function position()
  local cursor = cx.active.current.cursor
  local length = #cx.active.current.files
  return ui.Span(string.format('%2d/%-2d', cursor + 1, length)):fg 'darkgray'
end

local function space()
  return ui.Span ' '
end

M.setup = function()
  for i = 1, 3 do
    Status:children_remove(i, Status.LEFT)
  end
  local left = ya.target_family() == 'windows'
      and {
        size,
        space,
        modified,
        space,
        name,
        space,
        link,
      }
    or {
      permissions,
      size,
      space,
      owner,
      space,
      modified,
      space,
      name,
      space,
      link,
    }
  for i, value in ipairs(left) do
    Status:children_add(value, i, Status.LEFT)
  end
  for i = 4, 6 do
    Status:children_remove(i, Status.RIGHT)
  end
  local right = { mode, space, position }
  for i, value in ipairs(right) do
    Status:children_add(value, i, Status.RIGHT)
  end
end

return M
