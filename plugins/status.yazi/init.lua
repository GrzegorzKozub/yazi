local M = {}

-- todo: icons, size based colors (eza), smart dates (eza)

function Status:size()
  local h = cx.active.current.hovered
  if not h then
    return ui.Span ''
  end
  local size = ya.readable_size(h:size() or h.cha.length)
  return ui.Span(' ' .. string.format('%6s', size)):fg 'gray'
end

function Status:owner()
  local h = cx.active.current.hovered
  if not h or ya.target_family() ~= 'unix' then
    return ui.Span ''
  end
  local owner = ya.user_name(h.cha.uid) or tostring(h.cha.uid)
  return ui.Span(' ' .. owner):fg(owner == 'root' and 'red' or 'darkgray')
end

function Status:modified()
  local h = cx.active.current.hovered
  if not h then
    return ui.Span ''
  end
  local modified = math.floor(h.cha.modified)
  return ui.Span(' ' .. tostring(os.date('%d %b %H:%M', modified)):lower()):fg 'gray'
end

function Status:link()
  local h = cx.active.current.hovered
  if not h or not h.link_to then
    return ui.Span ''
  end
  local link = '-> ' .. tostring(h.link_to)
  return ui.Span(' ' .. link):fg(h.cha.is_orphan and 'red' or 'blue')
end

function Status:mode()
  local mode = tostring(cx.active.mode):sub(1, 1)
  if mode == 'n' then
    return ui.Span '    '
  end
  return ui.Line {
    ui.Span(' ' .. mode .. ' '):style(self.style()),
    ui.Span ' ',
  }
end

function Status:position()
  local cursor = cx.active.current.cursor
  local length = #cx.active.current.files
  return ui.Span(string.format('%2d/%-2d', cursor + 1, length)):fg 'darkgray'
end

function Status:render(area)
  self.area = area
  local left = ui.Line {
    self:permissions(),
    self:size(),
    self:owner(),
    self:modified(),
    self:link(),
  }
  local right = ui.Line {
    self:mode(),
    self:position(),
  }
  return {
    ui.Paragraph(area, { left }),
    ui.Paragraph(area, { right }):align(ui.Paragraph.RIGHT),
    table.unpack(Progress:render(area, right:width())),
  }
end

return M
