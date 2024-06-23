local M = {}

function Status:mode()
  return ui.Line { ui.Span(' ' .. tostring(cx.active.mode):sub(1, 1) .. ' '):style(self.style()) }
end

function Status:size()
  local h = cx.active.current.hovered
  if not h then
    return ui.Line {}
  end
  return ui.Line {
    ui.Span(' ' .. ya.readable_size(h:size() or h.cha.length) .. ' '):fg('#32302f'):bg '#514945',
  }
end

function Status:name()
  local h = cx.active.current.hovered
  if not h then
    return ui.Span ''
  end
  local link = h.link_to ~= nil and ' -> ' .. tostring(h.link_to) or ''
  return ui.Span(' ' .. h.name .. link):fg '#7c6f64'
end

function Status:owner()
  local h = cx.active.current.hovered
  if h == nil or ya.target_family() ~= 'unix' then
    return ui.Line {}
  end
  local owner = ya.user_name(h.cha.uid) or tostring(h.cha.uid)
  return ui.Line {
    ui.Span(' ' .. owner .. ' ')
      :fg(owner == 'root' and THEME.notify.title_error.fg or '#7c6f64'),
  }
end

local function permissions_margin()
  return ui.Span(' '):style(THEME.status.permissions_s)
end

function Status:percentage_and_position()
  local percent = 0
  local cursor = cx.active.current.cursor
  local length = #cx.active.current.files
  if cursor ~= 0 and length ~= 0 then
    percent = math.floor((cursor + 1) * 100 / length)
  end
  return ui.Line {
    ui.Span(string.format(' %d%% %d/%d ', percent, cursor + 1, length))
      :style(THEME.status.mode_normal),
  }
end

function Status:render(area)
  self.area = area
  local left = ui.Line { self:mode(), self:size(), self:name() }
  local right = ui.Line {
    self:owner(),
    permissions_margin(),
    self:permissions(),
    permissions_margin(),
    self:percentage_and_position(),
  }
  return {
    ui.Paragraph(area, { left }),
    ui.Paragraph(area, { right }):align(ui.Paragraph.RIGHT),
    table.unpack(Progress:render(area, right:width())),
  }
end

return M
