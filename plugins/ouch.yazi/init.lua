local M = {}

function M:peek()
  local child = Command('ouch')
    :args({ 'list', '--tree', tostring(self.file.url) })
    :stdout(Command.PIPED)
    :stderr(Command.PIPED)
    :spawn()
  local lines = ''
  local count = 1
  local skip = 0
  repeat
    local line, event = child:read_line()
    if event > 0 then
      break
    elseif not line:find('Archive') then
      if skip >= self.skip then
        lines = lines .. line
        count = count + 1
      else
        skip = skip + 1
      end
    end
  until count >= self.area.h
  child:start_kill()
  if self.skip > 0 and count < self.area.h then
    ya.manager_emit('peek', {
      tostring(math.max(0, self.skip - self.area.h - count)),
      only_if = self.file.url,
      upper_bound = '',
    })
  else
    ya.preview_widgets(self, { ui.Paragraph.parse(self.area, lines) })
  end
end

function M:seek(units)
  local h = cx.active.current.hovered
  if h and h.url == self.file.url then
    ya.manager_emit('peek', {
      math.max(0, cx.active.preview.skip + units),
      only_if = self.file.url,
    })
  end
end

return M
