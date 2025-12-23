local M = {}

local function append(count, style, val)
  count[#count + 1] = ui.Span(''):style(style):reverse()
  count[#count + 1] = ui.Span(val):style(style)
  count[#count + 1] = ui.Span(''):style(style):reverse()
end

local function append2(count, style, val)
  count[#count + 1] = ui.Span(''):style(style)
  count[#count + 1] = ui.Span(val):style(style)
  count[#count + 1] = ui.Span(''):style(style)
end

function Header:cwd()
  local cwd1 = { ui.Span(tostring(self._current.cwd)):style(th.mgr.cwd) }

  local cwd = self._current.cwd
  if cwd.is_search then
    append(cwd1, th.mgr.find_position, string.format('search: %s', cwd.domain))
  end
  -- return ui.Line {
  --   ui.Span ' ',
  --   ui.Span(self:flags()):style(th.mgr.cwd),
  -- }
  return ui.Line(cwd1)
end

function Header:flags()
  local cwd = self._current.cwd
  local filter = self._current.files.filter
  local finder = self._tab.finder
  local t = {}
  if cwd.is_search then
    t[#t + 1] = string.format('search: %s', cwd.domain)
  end
  if filter then
    t[#t + 1] = string.format('filter: %s', filter)
  end
  if finder then
    t[#t + 1] = string.format('find: %s', finder)
  end
  return #t == 0 and '--' or ' (' .. table.concat(t, ', ') .. ')'
end

function Header:count()
  local s, y, count = #self._tab.selected, #cx.yanked, {}
  if s > 0 then
    append(count, th.mgr.count_selected, string.format('%d', s))
  end
  if y > 0 then
    count[#count + 1] = ui.Span ' '
    append(
      count,
      cx.yanked.is_cut and th.mgr.count_cut or th.mgr.count_copied,
      string.format('%d', y)
    )
  end
  return ui.Line(count)
end

M.setup = function() end

return M
