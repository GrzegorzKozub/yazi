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

function Status:size()
  local h = cx.active.current.hovered
  if not h then
    return ui.Span ''
  end
  local size = h:size() or h.cha.length
  return ui.Span(string.format('%6s', ya.readable_size(size))):fg(size_color(size))
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

function Status:owner()
  local h = cx.active.current.hovered
  if not h or ya.target_family() ~= 'unix' then
    return ui.Span ''
  end
  local owner = ya.user_name(h.cha.uid) or tostring(h.cha.uid)
  return ui.Span(owner):fg(owner_color(owner))
end

local function year(date)
  return tonumber(os.date('%Y', date))
end

function Status:modified()
  local h = cx.active.current.hovered
  if not h then
    return ui.Span ''
  end
  local modified = math.floor(h.cha.modified)
  local now = math.floor(ya.time())
  local format = year(modified) < year(now) and '%d %b  %Y' or '%d %b %H:%M'
  return ui.Span(tostring(os.date(format, modified)):lower()):fg 'gray'
end

function Status:link()
  local h = cx.active.current.hovered
  if not h or not h.link_to then
    return ui.Span ''
  end
  local link = '-> ' .. tostring(h.link_to)
  return ui.Span(link):fg(h.cha.is_orphan and 'red' or 'blue')
end

function Status:mode()
  local mode = tostring(cx.active.mode):sub(1, 1)
  if mode == 'n' then
    return ui.Span '    '
  end
  return ui.Span(' ' .. mode .. ' '):style(self.style())
end

function Status:position()
  local cursor = cx.active.current.cursor
  local length = #cx.active.current.files
  return ui.Span(string.format('%2d/%-2d', cursor + 1, length)):fg 'darkgray'
end

local function space()
  return ui.Span ' '
end

function Status:render(area)
  self.area = area
  local left = ya.target_family() == 'windows'
      and ui.Line {
        self:size(),
        space(),
        self:modified(),
        space(),
        self:link(),
      }
    or ui.Line {
      self:permissions(),
      space(),
      self:size(),
      space(),
      self:owner(),
      space(),
      self:modified(),
      space(),
      self:link(),
    }
  local right = ui.Line {
    self:mode(),
    space(),
    self:position(),
  }
  return {
    ui.Paragraph(area, { left }),
    ui.Paragraph(area, { right }):align(ui.Paragraph.RIGHT),
    table.unpack(Progress:render(area, right:width())),
  }
end

return M
